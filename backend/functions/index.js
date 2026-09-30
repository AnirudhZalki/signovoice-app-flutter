'use strict';
/**
 * SignoVoice reference backend (Firebase Cloud Functions, 2nd gen, Node 20).
 * Implements docs/BACKEND_CONTRACT.md: subscriptions (Google Play + Razorpay), LiveKit tokens.
 * Interpreter matching (/v1/interpreter/*) and /v1/translate are product-specific and not included.
 *
 * Secrets:  firebase functions:secrets:set RAZORPAY_KEY_SECRET RAZORPAY_WEBHOOK_SECRET LIVEKIT_API_SECRET
 * Config (env / .env): RAZORPAY_KEY_ID, RAZORPAY_PLANS, TRIAL_DAYS, PLAY_PACKAGE_NAME, LIVEKIT_URL, LIVEKIT_API_KEY
 */
const admin = require('firebase-admin');
const crypto = require('crypto');
const { onRequest } = require('firebase-functions/v2/https');
const { onMessagePublished } = require('firebase-functions/v2/pubsub');
const { defineSecret } = require('firebase-functions/params');
const { fromRazorpay, fromPlay } = require('./lib/entitlement');
const { verifyOrderSignature, verifyCheckoutSignature, verifyWebhookSignature } = require('./lib/razorpay');
const { requireUser, rateLimit } = require('./lib/auth');

admin.initializeApp();
const db = admin.firestore();

const RAZORPAY_KEY_SECRET = defineSecret('RAZORPAY_KEY_SECRET');
const RAZORPAY_WEBHOOK_SECRET = defineSecret('RAZORPAY_WEBHOOK_SECRET');
const LIVEKIT_API_SECRET = defineSecret('LIVEKIT_API_SECRET');

const env = (k, d = '') => process.env[k] || d;
const plans = () => JSON.parse(env('RAZORPAY_PLANS', '{}')); // {"signovoice_premium_monthly":{"planId":"plan_x","period":"monthly","title":"Premium monthly","totalCount":120}}
const trialDays = () => Number(env('TRIAL_DAYS', '30'));
const packageName = () => env('PLAY_PACKAGE_NAME', 'com.anirudhzalki.signovoice');

const razorpay = () => new (require('razorpay'))({ key_id: env('RAZORPAY_KEY_ID'), key_secret: RAZORPAY_KEY_SECRET.value() });
const entRef = (uid) => db.collection('entitlements').doc(uid);           // client-readable (see firestore.rules)
const refRef = (uid) => db.collection('subscriptionRefs').doc(uid);       // private: provider ids, cancel flags

const FREE = { status: 'free', platform: 'unknown', autoRenewing: false };
const send = (res, code, body) => res.status(code).json(body);

async function saveEntitlement(uid, ent) {
  await entRef(uid).set(ent);
  return ent;
}

// ---------- Razorpay Standard Checkout (one-time orders) ----------
const MIN_PAISE = 100;

/** Create an order. Amount is in paise (integer >= 100). The order is bound to the signed-in user via notes. */
async function orderCreate(uid, body) {
  const amount = Number(body && body.amount);
  const currency = String((body && body.currency) || 'INR').toUpperCase();
  if (!Number.isInteger(amount) || amount < MIN_PAISE) throw Object.assign(new Error(`amount must be an integer >= ${MIN_PAISE} paise`), { status: 400 });
  if (!/^[A-Z]{3}$/.test(currency)) throw Object.assign(new Error('invalid currency'), { status: 400 });
  const receipt = String((body && body.receipt) || `sv_${uid.slice(0, 8)}_${Date.now()}`).slice(0, 40);
  let order;
  try {
    order = await razorpay().orders.create({ amount, currency, receipt, notes: { uid } });
  } catch (e) {
    // Razorpay SDK errors: { statusCode, error: { description } }. Auth failure -> 401, anything else -> 500.
    const code = e && e.statusCode === 401 ? 401 : 500;
    throw Object.assign(new Error((e && e.error && e.error.description) || 'razorpay error'), { status: code });
  }
  await db.collection('razorpayOrders').doc(order.id).set({ uid, amount, currency, receipt, paid: false });
  return { order_id: order.id, amount: order.amount, currency: order.currency, keyId: env('RAZORPAY_KEY_ID') };
}

/** Verify the checkout signature. Marks the order paid only when it matches and belongs to the caller. */
async function orderVerify(uid, body) {
  const { razorpay_order_id: orderId, razorpay_payment_id: paymentId, razorpay_signature: signature } = body || {};
  if (!orderId || !paymentId || !signature) throw Object.assign(new Error('missing fields'), { status: 400 });
  if (!verifyOrderSignature({ orderId, paymentId, signature }, RAZORPAY_KEY_SECRET.value())) {
    throw Object.assign(new Error('signature mismatch'), { status: 400 });
  }
  const ref = db.collection('razorpayOrders').doc(orderId);
  const doc = await ref.get();
  if (!doc.exists || doc.data().uid !== uid) throw Object.assign(new Error('unknown order'), { status: 400 });
  await ref.set({ paid: true, paymentId, paidAt: Date.now() }, { merge: true });
  return { success: true, orderId, paymentId };
}

// ---------- Razorpay ----------
async function razorpayPlans() {
  const rz = razorpay();
  const out = [];
  for (const [productId, p] of Object.entries(plans())) {
    const plan = await rz.plans.fetch(p.planId);
    out.push({ productId, planId: p.planId, title: p.title || productId, period: p.period, amountPaise: plan.item.amount, currency: plan.item.currency, trialDays: trialDays() });
  }
  return out;
}

async function razorpayCreate(uid, productId) {
  const p = plans()[productId];
  if (!p) throw Object.assign(new Error('unknown product'), { status: 404 });
  const existing = (await entRef(uid).get()).data();
  const alreadyTrialed = !!(existing && existing.trialStartDate);
  const req = { plan_id: p.planId, total_count: p.totalCount || (p.period === 'yearly' ? 10 : 120), quantity: 1, customer_notify: 1, notes: { uid, productId } };
  // Free trial: authorise the mandate now, first charge after the trial (UPI AutoPay / e-mandate).
  if (!alreadyTrialed && trialDays() > 0) req.start_at = Math.floor(Date.now() / 1000) + trialDays() * 86400;
  const sub = await razorpay().subscriptions.create(req);
  await refRef(uid).set({ razorpaySubscriptionId: sub.id, productId, trialStart: alreadyTrialed ? null : Date.now(), cancelRequested: false }, { merge: true });
  await db.collection('razorpaySubscriptions').doc(sub.id).set({ uid, productId });
  return { subscriptionId: sub.id, keyId: env('RAZORPAY_KEY_ID') };
}

async function razorpayRefresh(uid, subId) {
  const ref = (await refRef(uid).get()).data() || {};
  const sub = await razorpay().subscriptions.fetch(subId);
  return saveEntitlement(uid, fromRazorpay(sub, { trialStart: ref.trialStart, cancelRequested: ref.cancelRequested }, Date.now(), ref.productId));
}

async function razorpayVerify(uid, token) {
  const t = typeof token === 'string' ? JSON.parse(token) : token;
  if (!verifyCheckoutSignature(t, RAZORPAY_KEY_SECRET.value())) throw Object.assign(new Error('bad signature'), { status: 403 });
  const sub = await razorpay().subscriptions.fetch(t.subscriptionId);
  if (!sub.notes || sub.notes.uid !== uid) throw Object.assign(new Error('subscription belongs to another user'), { status: 403 });
  return razorpayRefresh(uid, t.subscriptionId);
}

async function razorpayCancel(uid) {
  const ref = (await refRef(uid).get()).data();
  if (!ref || !ref.razorpaySubscriptionId) throw Object.assign(new Error('no subscription'), { status: 404 });
  await razorpay().subscriptions.cancel(ref.razorpaySubscriptionId, true); // at cycle end
  await refRef(uid).set({ cancelRequested: true }, { merge: true });
  return razorpayRefresh(uid, ref.razorpaySubscriptionId);
}

// ---------- Google Play ----------
async function playClient() {
  const { google } = require('googleapis');
  const auth = new google.auth.GoogleAuth({ scopes: ['https://www.googleapis.com/auth/androidpublisher'] }); // runtime service account
  return google.androidpublisher({ version: 'v3', auth });
}

async function playVerify(uid, productId, token) {
  const tokenHash = crypto.createHash('sha256').update(token).digest('hex');
  const bound = await db.collection('playTokens').doc(tokenHash).get();
  if (bound.exists && bound.data().uid !== uid) throw Object.assign(new Error('token belongs to another user'), { status: 403 });
  const api = await playClient();
  const { data } = await api.purchases.subscriptionsv2.get({ packageName: packageName(), token });
  const line = (data.lineItems || []).find((l) => l.productId === productId);
  if (!line || !Object.keys(plans()).concat(env('PLAY_PRODUCTS', '').split(',')).filter(Boolean).length) {
    throw Object.assign(new Error('product mismatch'), { status: 400 });
  }
  if (data.acknowledgementState === 'ACKNOWLEDGEMENT_STATE_PENDING') {
    await api.purchases.subscriptions.acknowledge({ packageName: packageName(), subscriptionId: productId, token, requestBody: {} });
  }
  await db.collection('playTokens').doc(tokenHash).set({ uid, token, productId });
  return saveEntitlement(uid, fromPlay(data, Date.now(), token));
}

// ---------- LiveKit ----------
async function livekitToken(uid, room) {
  const { AccessToken } = require('livekit-server-sdk');
  const name = /^sv-[A-Za-z0-9_-]{4,64}$/.test(room || '') ? room : `sv-${uid.slice(0, 12)}`;
  const at = new AccessToken(env('LIVEKIT_API_KEY'), LIVEKIT_API_SECRET.value(), { identity: uid, ttl: '1h' });
  at.addGrant({ roomJoin: true, room: name, canPublish: true, canSubscribe: true, canPublishData: true });
  return { url: env('LIVEKIT_URL'), token: await at.toJwt(), roomName: name };
}

// ---------- HTTP API ----------
exports.api = onRequest({ secrets: [RAZORPAY_KEY_SECRET, RAZORPAY_WEBHOOK_SECRET, LIVEKIT_API_SECRET], cors: false, maxInstances: 20 }, async (req, res) => {
  try {
    const path = req.path.replace(/\/+$/, '');
    if (req.method === 'POST' && path === '/v1/razorpay/webhook') return webhook(req, res); // Razorpay -> us (signature, no user token)

    const user = await requireUser(req);
    const uid = user.uid;
    rateLimit(`${uid}:${path.startsWith('/v1/subscriptions') || path.startsWith('/v1/razorpay') ? 'pay' : 'gen'}`, path.startsWith('/v1/razorpay') || path.startsWith('/v1/subscriptions') ? 10 : 60);

    if (req.method === 'GET' && path === '/v1/subscription') return send(res, 200, (await entRef(uid).get()).data() || FREE);
    if (req.method === 'GET' && path === '/v1/razorpay/plans') return send(res, 200, { plans: await razorpayPlans() });
    if (req.method === 'POST' && path === '/v1/razorpay/subscriptions') return send(res, 200, await razorpayCreate(uid, req.body.productId));
    if (req.method === 'POST' && path === '/v1/razorpay/orders') return send(res, 200, await orderCreate(uid, req.body));
    if (req.method === 'POST' && path === '/v1/razorpay/orders/verify') return send(res, 200, await orderVerify(uid, req.body));
    if (req.method === 'POST' && path === '/v1/razorpay/cancel') return send(res, 200, await razorpayCancel(uid));
    if (req.method === 'POST' && path === '/v1/subscriptions/verify') {
      const { platform, productId, purchaseToken } = req.body || {};
      if (platform === 'razorpay') return send(res, 200, await razorpayVerify(uid, purchaseToken));
      if (platform === 'android') return send(res, 200, await playVerify(uid, productId, purchaseToken));
      return send(res, 400, { error: 'unsupported platform' });
    }
    if (req.method === 'POST' && path === '/v1/subscriptions/restore') {
      const ref = (await refRef(uid).get()).data();
      if (req.body && req.body.platform === 'razorpay' && ref && ref.razorpaySubscriptionId) return send(res, 200, await razorpayRefresh(uid, ref.razorpaySubscriptionId));
      const snap = await db.collection('playTokens').where('uid', '==', uid).limit(1).get();
      if (!snap.empty) { const d = snap.docs[0].data(); return send(res, 200, await playVerify(uid, d.productId, d.token)); }
      return send(res, 200, (await entRef(uid).get()).data() || FREE);
    }
    if (req.method === 'POST' && path === '/v1/livekit/token') return send(res, 200, await livekitToken(uid, req.body && req.body.room));
    return send(res, 404, { error: 'not found' });
  } catch (e) {
    const status = e.status || (e.statusCode && e.statusCode >= 400 && e.statusCode < 500 ? 400 : 500);
    if (status >= 500) console.error(e); // never log tokens/signatures
    return send(res, status, { error: status >= 500 ? 'server error' : e.message });
  }
});

async function webhook(req, res) {
  if (!verifyWebhookSignature(req.rawBody && req.rawBody.toString('utf8'), req.get('x-razorpay-signature'), RAZORPAY_WEBHOOK_SECRET.value())) return send(res, 400, { error: 'bad signature' });
  const sub = req.body && req.body.payload && req.body.payload.subscription && req.body.payload.subscription.entity;
  if (sub) {
    const map = (await db.collection('razorpaySubscriptions').doc(sub.id).get()).data();
    if (map) {
      const ref = (await refRef(map.uid).get()).data() || {};
      await saveEntitlement(map.uid, fromRazorpay(sub, { trialStart: ref.trialStart, cancelRequested: ref.cancelRequested }, Date.now(), map.productId));
    }
  }
  return send(res, 200, { ok: true });
}

/** Google Play real-time developer notifications (Pub/Sub topic "play-rtdn"). */
exports.playRtdn = onMessagePublished('play-rtdn', async (event) => {
  const msg = event.data.message.json;
  const n = msg && msg.subscriptionNotification;
  if (!n) return;
  const hash = crypto.createHash('sha256').update(n.purchaseToken).digest('hex');
  const bound = (await db.collection('playTokens').doc(hash).get()).data();
  if (bound) await playVerify(bound.uid, n.subscriptionId, n.purchaseToken);
});
