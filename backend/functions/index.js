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
const { isExpired, queuePosition, canTake, publicInterpreter, splitAmount, validateProfile } = require('./lib/interpreters');

admin.initializeApp();
const db = admin.firestore();

const RAZORPAY_KEY_SECRET = defineSecret('RAZORPAY_KEY_SECRET');
const RAZORPAY_WEBHOOK_SECRET = defineSecret('RAZORPAY_WEBHOOK_SECRET');
const LIVEKIT_API_SECRET = defineSecret('LIVEKIT_API_SECRET');

const env = (k, d = '') => process.env[k] || d;
const plans = () => JSON.parse(env('RAZORPAY_PLANS', '{}')); // {"signovoice_premium_6months":{"planId":"plan_x","title":"Premium 6 months","months":6,"totalCount":20}}  (cycle + price come from the Razorpay plan itself)
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
    out.push({ productId, planId: p.planId, title: p.title || productId, period: plan.period || p.period, interval: plan.interval || 1, amountPaise: plan.item.amount, currency: plan.item.currency, trialDays: trialDays() });
  }
  return out;
}

async function razorpayCreate(uid, productId) {
  const p = plans()[productId];
  if (!p) throw Object.assign(new Error('unknown product'), { status: 404 });
  const existing = (await entRef(uid).get()).data();
  const alreadyTrialed = !!(existing && existing.trialStartDate);
  const req = { plan_id: p.planId, total_count: p.totalCount || Math.max(1, Math.floor(120 / Math.max(1, p.months || (p.period === 'yearly' ? 12 : 1)))), quantity: 1, customer_notify: 1, notes: { uid, productId } };
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

async function mintToken({ identity, name, room }) {
  const { AccessToken } = require('livekit-server-sdk');
  const at = new AccessToken(env('LIVEKIT_API_KEY'), LIVEKIT_API_SECRET.value(), { identity, name, ttl: '1h' });
  at.addGrant({ roomJoin: true, room, canPublish: true, canSubscribe: true, canPublishData: true });
  return at.toJwt();
}

// ---------- Interpreter matching + payment ----------
const reqCol = () => db.collection('interpreterRequests');
const interpCol = () => db.collection('interpreters');
const bad = (msg, status = 400) => Object.assign(new Error(msg), { status });
const feePercent = () => Number(env('PLATFORM_FEE_PERCENT', '20'));
const defaultRatePaise = () => Number(env('DEFAULT_RATE_PAISE', '0')); // price of "any interpreter" requests (0 = free)
const PAYMENT_WINDOW_MS = 15 * 60 * 1000;

async function interpreterProfile(uid) {
  const d = await interpCol().doc(uid).get();
  return d.exists ? { id: uid, ...d.data() } : null;
}

async function listInterpreters(language) {
  const snap = await interpCol().where('approved', '==', true).get();
  return snap.docs.map((d) => publicInterpreter(d.id, d.data()))
    .filter((i) => !language || i.languages.length === 0 || i.languages.includes(language))
    .sort((a, b) => (a.status === 'available' ? 0 : 1) - (b.status === 'available' ? 0 : 1));
}

/** Interpreter registers or edits their profile. New profiles need approval (or INTERPRETER_AUTO_APPROVE=true). */
async function saveInterpreterProfile(uid, body) {
  const clean = validateProfile(body);
  const existing = await interpreterProfile(uid);
  const autoApprove = env('INTERPRETER_AUTO_APPROVE', 'false') === 'true';
  const doc = { ...clean, approved: !!(existing && existing.approved) || autoApprove, appliedAt: (existing && existing.appliedAt) || Date.now(), updatedAt: Date.now() };
  if (!existing) Object.assign(doc, { status: 'offline', rating: null, ratingCount: 0, earningsPaise: 0 });
  await interpCol().doc(uid).set(doc, { merge: true });
  return interpreterMe(uid);
}

async function interpreterMe(uid) {
  const p = await interpreterProfile(uid);
  if (!p) return { approved: false, applied: false };
  return { approved: !!p.approved, applied: true, status: p.status || 'offline', name: p.name || '', languages: p.languages || [],
    ratePaise: p.ratePaise || 0, bio: p.bio || '', sessionMinutes: p.sessionMinutes || 30, earningsPaise: p.earningsPaise || 0 };
}

async function adminApprove(uid, targetUid, approved) {
  const admins = env('ADMIN_UIDS', '').split(',').map((s) => s.trim()).filter(Boolean);
  if (!admins.includes(uid)) throw bad('forbidden', 403);
  if (!(await interpreterProfile(targetUid))) throw bad('not found', 404);
  await interpCol().doc(targetUid).set({ approved: !!approved, ...(approved ? {} : { status: 'offline' }) }, { merge: true });
  return { ok: true };
}

async function refundIfPaid(ref, r) {
  if (!r.paid || !r.paymentId || r.refunded) return;
  try {
    await razorpay().payments.refund(r.paymentId, { amount: r.amountPaise, notes: { requestId: ref.id, reason: String(r.status) } });
    await ref.set({ refunded: true, refundedAt: Date.now() }, { merge: true });
  } catch (e) {
    console.error('refund failed', ref.id, e && e.error && e.error.description); // never log keys; retried on next status read
  }
}

async function createRequest(uid, body, name) {
  const mode = body && body.mode;
  const language = String((body && body.language) || '');
  if (!['video', 'audio'].includes(mode)) throw bad('invalid mode');
  if (!/^[a-z]{2,3}$/.test(language)) throw bad('invalid language');
  const interpreterId = (body && body.interpreterId) || null;
  let rate = defaultRatePaise();
  let interpreterName = '';
  if (interpreterId) {
    const p = await interpreterProfile(interpreterId);
    if (!p || !p.approved) throw bad('interpreter not found', 404);
    if (p.status !== 'available') throw bad('interpreter is not available', 409);
    if (interpreterId === uid) throw bad('you cannot request yourself');
    rate = p.ratePaise || 0;
    interpreterName = p.name || '';
  }
  // At most one open request per person; an abandoned unpaid one is simply cancelled, a paid waiting one is refunded.
  const open = await reqCol().where('uid', '==', uid).get();
  for (const d of open.docs) {
    const r = d.data();
    if (r.status === 'waiting' || r.status === 'awaiting_payment') {
      await d.ref.update({ status: 'cancelled' });
      await refundIfPaid(d.ref, r);
    }
  }
  const now = Date.now();
  const ref = reqCol().doc();
  const base = { uid, name: name || '', mode, language, interpreterId, interpreterName, note: String((body && body.note) || '').slice(0, 300), createdAt: now, amountPaise: rate, paid: false };
  if (rate > 0) {
    let order;
    try {
      order = await razorpay().orders.create({ amount: rate, currency: 'INR', receipt: `ir_${ref.id}`.slice(0, 40), notes: { uid, requestId: ref.id } });
    } catch (e) {
      throw bad((e && e.error && e.error.description) || 'payment provider error', e && e.statusCode === 401 ? 401 : 502);
    }
    await ref.set({ ...base, status: 'awaiting_payment', orderId: order.id });
    return { requestId: ref.id, status: 'awaiting_payment', amountPaise: rate,
      order: { order_id: order.id, amount: order.amount, currency: order.currency, keyId: env('RAZORPAY_KEY_ID') } };
  }
  await ref.set({ ...base, status: 'waiting' });
  return { requestId: ref.id, status: 'waiting', position: await positionOf(ref.id, now) };
}

/** Payment done in the app: verify the signature, then the request enters the interpreter's queue (TTL starts now). */
async function payRequest(uid, id, body) {
  const { razorpay_order_id: orderId, razorpay_payment_id: paymentId, razorpay_signature: signature } = body || {};
  const ref = reqCol().doc(id);
  const doc = await ref.get();
  if (!doc.exists || doc.data().uid !== uid) throw bad('not found', 404);
  const r = doc.data();
  if (r.paid) return { requestId: id, status: r.status };
  if (r.status !== 'awaiting_payment') throw bad('request is not awaiting payment', 409);
  if (!orderId || !paymentId || !signature || orderId !== r.orderId) throw bad('missing or wrong payment fields');
  if (!verifyOrderSignature({ orderId, paymentId, signature }, RAZORPAY_KEY_SECRET.value())) throw bad('signature mismatch');
  const now = Date.now();
  await ref.update({ paid: true, paymentId, paidAt: now, status: 'waiting', createdAt: now });
  return { requestId: id, status: 'waiting', position: await positionOf(id, now) };
}

async function positionOf(id, now) {
  const snap = await reqCol().where('status', '==', 'waiting').get();
  return queuePosition(snap.docs.map((d) => ({ id: d.id, ...d.data() })), id, now);
}

async function expireIfStale(ref, r, now) {
  if (isExpired(r, now)) {
    await ref.update({ status: 'expired' });
    await refundIfPaid(ref, { ...r, status: 'expired' });
    return { ...r, status: 'expired' };
  }
  if (r.status === 'awaiting_payment' && now - r.createdAt > PAYMENT_WINDOW_MS) {
    await ref.update({ status: 'expired' });
    return { ...r, status: 'expired' };
  }
  return r;
}

async function requestStatus(uid, id) {
  const ref = reqCol().doc(id);
  const doc = await ref.get();
  if (!doc.exists || doc.data().uid !== uid) throw bad('not found', 404);
  const now = Date.now();
  const r = await expireIfStale(ref, { id, ...doc.data() }, now);
  if (['expired', 'declined', 'cancelled'].includes(r.status) && r.paid && !r.refunded) await refundIfPaid(ref, r);
  if (r.status === 'accepted') {
    const room = r.roomName;
    return { requestId: id, status: 'accepted', session: {
      callId: r.callId, roomName: room, url: env('LIVEKIT_URL'), interpreterName: r.interpreterName || '',
      token: await mintToken({ identity: uid, name: r.name || uid, room }),
    } };
  }
  if (r.status === 'waiting') return { requestId: id, status: 'waiting', position: await positionOf(id, now) };
  return { requestId: id, status: r.status, refunded: !!r.refunded };
}

async function cancelRequest(uid, id) {
  const ref = reqCol().doc(id);
  const doc = await ref.get();
  if (!doc.exists || doc.data().uid !== uid) throw bad('not found', 404);
  const r = doc.data();
  if (r.status === 'waiting' || r.status === 'awaiting_payment') {
    await ref.update({ status: 'cancelled' });
    await refundIfPaid(ref, { ...r, status: 'cancelled' }); // nobody accepted yet: money back
  }
  return { ok: true };
}

// Interpreter side -----------------------------------------------------------
async function requireInterpreter(uid) {
  const p = await interpreterProfile(uid);
  if (!p || !p.approved) throw bad('not an approved interpreter', 403);
  return p;
}

async function interpreterQueue(uid) {
  const me = await requireInterpreter(uid);
  const now = Date.now();
  const snap = await reqCol().where('status', '==', 'waiting').get();
  const out = [];
  for (const d of snap.docs) {
    const r = await expireIfStale(d.ref, { id: d.id, ...d.data() }, now); // also refunds abandoned paid requests
    if (r.status !== 'waiting' || !canTake({ ...me, status: 'available' }, r)) continue;
    out.push(r);
  }
  return out.sort((a, b) => a.createdAt - b.createdAt)
    .map((r) => ({ requestId: r.id, name: r.name, mode: r.mode, language: r.language, note: r.note, waitingSeconds: Math.round((now - r.createdAt) / 1000),
      amountPaise: r.amountPaise || 0, earnPaise: splitAmount(r.amountPaise || 0, feePercent()).interpreterPaise, directed: r.interpreterId === uid }));
}

async function setInterpreterStatus(uid, status) {
  await requireInterpreter(uid);
  if (!['available', 'offline'].includes(status)) throw bad('invalid status');
  await interpCol().doc(uid).set({ status, updatedAt: Date.now() }, { merge: true });
  return { status };
}

async function declineRequest(uid, id) {
  await requireInterpreter(uid);
  const ref = reqCol().doc(id);
  const doc = await ref.get();
  if (!doc.exists) throw bad('not found', 404);
  const r = doc.data();
  if (r.status === 'waiting' && r.interpreterId === uid) { // only a request addressed to this interpreter can be declined
    await ref.update({ status: 'declined' });
    await refundIfPaid(ref, { ...r, status: 'declined' });
  }
  return { ok: true };
}

async function acceptRequest(uid, id, name) {
  const me = await requireInterpreter(uid);
  if (me.status === 'busy') throw bad('already in a call', 409);
  const ref = reqCol().doc(id);
  const callRef = db.collection('interpreterCalls').doc();
  const room = `sv-call-${callRef.id}`;
  await db.runTransaction(async (tx) => {
    const doc = await tx.get(ref);
    if (!doc.exists) throw bad('not found', 404);
    const r = { id, ...doc.data() };
    if (isExpired(r, Date.now())) throw bad('request expired', 410);
    if (r.status !== 'waiting') throw bad('request already taken', 409);
    if (r.amountPaise > 0 && !r.paid) throw bad('request is not paid', 402);
    if (!canTake({ ...me, status: 'available' }, r)) throw bad('cannot take this request', 403);
    const split = splitAmount(r.paid ? r.amountPaise : 0, feePercent());
    tx.update(ref, { status: 'accepted', callId: callRef.id, roomName: room, interpreterId: uid, interpreterName: me.name || name || '', acceptedAt: Date.now() });
    tx.set(callRef, { requestId: id, requesterUid: r.uid, interpreterUid: uid, roomName: room, mode: r.mode, language: r.language, startedAt: Date.now(),
      amountPaise: split.amountPaise, feePaise: split.feePaise, interpreterPaise: split.interpreterPaise, paymentId: r.paymentId || null });
    tx.set(interpCol().doc(uid), { status: 'busy', updatedAt: Date.now(), earningsPaise: (me.earningsPaise || 0) + split.interpreterPaise }, { merge: true });
  });
  return { session: { callId: callRef.id, roomName: room, url: env('LIVEKIT_URL'), token: await mintToken({ identity: uid, name: me.name || name || uid, room }) } };
}

async function endCall(uid, callId) {
  const ref = db.collection('interpreterCalls').doc(callId);
  const doc = await ref.get();
  if (!doc.exists || ![doc.data().interpreterUid, doc.data().requesterUid].includes(uid)) throw bad('not found', 404);
  await ref.set({ endedAt: Date.now() }, { merge: true });
  await interpCol().doc(doc.data().interpreterUid).set({ status: 'available', updatedAt: Date.now() }, { merge: true });
  return { ok: true };
}

async function callNote(uid, callId, kind, body) {
  const ref = db.collection('interpreterCalls').doc(callId);
  const doc = await ref.get();
  if (!doc.exists || doc.data().requesterUid !== uid) throw bad('not found', 404);
  const text = String((body && (body.comment || body.details)) || '').slice(0, 1000);
  if (kind === 'feedback') {
    const rating = Number(body && body.rating);
    if (!Number.isInteger(rating) || rating < 1 || rating > 5) throw bad('rating must be 1-5');
    await ref.collection('feedback').doc(uid).set({ rating, comment: text, at: Date.now() });
    const iref = interpCol().doc(doc.data().interpreterUid);
    await db.runTransaction(async (tx) => {
      const i = (await tx.get(iref)).data() || {};
      const n = (i.ratingCount || 0) + 1;
      tx.set(iref, { ratingCount: n, rating: Math.round((((i.rating || 0) * (n - 1) + rating) / n) * 100) / 100 }, { merge: true });
    });
  } else {
    await ref.collection('reports').add({ uid, category: String((body && body.category) || 'other'), details: text, at: Date.now() });
  }
  return { ok: true };
}

// ---------- HTTP API ----------
exports.api = onRequest({ secrets: [RAZORPAY_KEY_SECRET, RAZORPAY_WEBHOOK_SECRET, LIVEKIT_API_SECRET], cors: false, maxInstances: 20 }, async (req, res) => {
  try {
    // `/api/...` is an alias of `/v1/...` (e.g. the webhook URL https://host/api/razorpay/webhook).
    const path = req.path.replace(/\/+$/, '').replace(/^\/api(?=\/)/, '/v1');
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
    const m = path.match(/^\/v1\/interpreter\/(requests|queue|calls)\/([A-Za-z0-9_-]+)(?:\/(accept|decline|pay|end|feedback|report))?$/);
    if (req.method === 'GET' && path === '/v1/interpreters') return send(res, 200, { interpreters: await listInterpreters(req.query.language) });
    if (req.method === 'POST' && path === '/v1/interpreter/requests') return send(res, 200, await createRequest(uid, req.body, user.name));
    if (req.method === 'GET' && path === '/v1/interpreter/me') return send(res, 200, await interpreterMe(uid));
    if (req.method === 'PUT' && path === '/v1/interpreter/me') return send(res, 200, await saveInterpreterProfile(uid, req.body));
    const adm = path.match(/^\/v1\/admin\/interpreters\/([A-Za-z0-9_-]+)\/(approve|revoke)$/);
    if (adm && req.method === 'POST') return send(res, 200, await adminApprove(uid, adm[1], adm[2] === 'approve'));
    if (req.method === 'POST' && path === '/v1/interpreter/me/status') return send(res, 200, await setInterpreterStatus(uid, req.body && req.body.status));
    if (req.method === 'GET' && path === '/v1/interpreter/queue') return send(res, 200, { requests: await interpreterQueue(uid) });
    if (m && m[1] === 'requests' && !m[3] && req.method === 'GET') return send(res, 200, await requestStatus(uid, m[2]));
    if (m && m[1] === 'requests' && !m[3] && req.method === 'DELETE') return send(res, 200, await cancelRequest(uid, m[2]));
    if (m && m[1] === 'requests' && m[3] === 'pay' && req.method === 'POST') return send(res, 200, await payRequest(uid, m[2], req.body));
    if (m && m[1] === 'queue' && m[3] === 'decline' && req.method === 'POST') return send(res, 200, await declineRequest(uid, m[2]));
    if (m && m[1] === 'queue' && m[3] === 'accept' && req.method === 'POST') return send(res, 200, await acceptRequest(uid, m[2], user.name));
    if (m && m[1] === 'calls' && m[3] === 'end' && req.method === 'POST') return send(res, 200, await endCall(uid, m[2]));
    if (m && m[1] === 'calls' && (m[3] === 'feedback' || m[3] === 'report') && req.method === 'POST') return send(res, 200, await callNote(uid, m[2], m[3], req.body));
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
  // Interpreter session paid (order.paid): queue the request even if the app died before calling /pay.
  const order = req.body && req.body.event === 'order.paid' && req.body.payload && req.body.payload.order && req.body.payload.order.entity;
  const payment = req.body && req.body.payload && req.body.payload.payment && req.body.payload.payment.entity;
  if (order && order.id) {
    const snap = await reqCol().where('orderId', '==', order.id).limit(1).get();
    if (!snap.empty) {
      const d = snap.docs[0];
      const r = d.data();
      if (!r.paid && order.amount_paid >= r.amountPaise) {
        if (r.status === 'awaiting_payment') await d.ref.update({ paid: true, paymentId: payment ? payment.id : null, paidAt: Date.now(), status: 'waiting', createdAt: Date.now() });
        else if (['expired', 'cancelled'].includes(r.status)) { // paid after we gave up: refund it
          await d.ref.update({ paid: true, paymentId: payment ? payment.id : null });
          await refundIfPaid(d.ref, { ...r, paid: true, paymentId: payment ? payment.id : null });
        }
      }
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
