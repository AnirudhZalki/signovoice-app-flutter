'use strict';
const test = require('node:test');
const assert = require('node:assert/strict');
const { fromRazorpay, fromPlay } = require('../lib/entitlement');
const { verifyOrderSignature, verifyCheckoutSignature, verifyWebhookSignature, hmac } = require('../lib/razorpay');

const NOW = Date.parse('2026-06-10T00:00:00Z');
const sec = (iso) => Math.floor(Date.parse(iso) / 1000);

test('razorpay checkout signature: valid, tampered, missing', () => {
  const secret = 'shh';
  const sig = hmac(secret, 'pay_1|sub_1');
  assert.equal(verifyCheckoutSignature({ paymentId: 'pay_1', subscriptionId: 'sub_1', signature: sig }, secret), true);
  assert.equal(verifyCheckoutSignature({ paymentId: 'pay_2', subscriptionId: 'sub_1', signature: sig }, secret), false);
  assert.equal(verifyCheckoutSignature({ paymentId: 'pay_1', subscriptionId: 'sub_1', signature: sig }, 'other'), false);
  assert.equal(verifyCheckoutSignature({ paymentId: 'pay_1', subscriptionId: 'sub_1' }, secret), false);
});

test('razorpay webhook signature', () => {
  const body = '{"event":"subscription.charged"}';
  assert.equal(verifyWebhookSignature(body, hmac('w', body), 'w'), true);
  assert.equal(verifyWebhookSignature(body + ' ', hmac('w', body), 'w'), false);
});

test('razorpay: authenticated with future start_at is a free trial', () => {
  const e = fromRazorpay({ status: 'authenticated', start_at: sec('2026-07-01T00:00:00Z'), paid_count: 0 }, { trialStart: NOW }, NOW, 'signovoice_premium_monthly');
  assert.equal(e.status, 'trial');
  assert.equal(e.trialEndDate, '2026-07-01T00:00:00.000Z');
  assert.equal(e.autoRenewing, true);
});

test('razorpay: after the first charge it is premium until current_end', () => {
  const e = fromRazorpay({ status: 'active', start_at: sec('2026-06-01T00:00:00Z'), paid_count: 1, current_start: sec('2026-06-01T00:00:00Z'), current_end: sec('2026-07-01T00:00:00Z') }, {}, NOW);
  assert.equal(e.status, 'premium');
  assert.equal(e.subscriptionEndDate, '2026-07-01T00:00:00.000Z');
});

test('razorpay: cancel requested keeps access until period end, then expires', () => {
  const sub = { status: 'active', paid_count: 2, current_end: sec('2026-06-20T00:00:00Z') };
  assert.equal(fromRazorpay(sub, { cancelRequested: true }, NOW).status, 'cancelled');
  assert.equal(fromRazorpay({ ...sub, status: 'cancelled' }, {}, Date.parse('2026-06-25T00:00:00Z')).status, 'expired');
});

test('razorpay: halted/pending/created', () => {
  assert.equal(fromRazorpay({ status: 'halted', current_end: sec('2026-06-01T00:00:00Z') }, {}, NOW).status, 'expired');
  assert.equal(fromRazorpay({ status: 'created' }, {}, NOW).status, 'free');
});

test('play: first order with an offer inside 32 days is the trial', () => {
  const p = { subscriptionState: 'SUBSCRIPTION_STATE_ACTIVE', startTime: '2026-06-01T00:00:00Z', latestOrderId: 'GPA.1111-2222',
    lineItems: [{ productId: 'signovoice_premium_monthly', expiryTime: '2026-07-01T00:00:00Z', autoRenewingPlan: { autoRenewEnabled: true }, offerDetails: { offerId: 'trial' } }] };
  const e = fromPlay(p, NOW, 'tok');
  assert.equal(e.status, 'trial');
  assert.equal(e.autoRenewing, true);
  assert.equal(e.purchaseToken, 'tok');
});

test('play: renewal order id means premium; canceled keeps access to expiry', () => {
  const li = { productId: 'signovoice_premium_monthly', expiryTime: '2026-06-20T00:00:00Z', autoRenewingPlan: { autoRenewEnabled: false }, offerDetails: { offerId: 'trial' } };
  const renewed = fromPlay({ subscriptionState: 'SUBSCRIPTION_STATE_ACTIVE', startTime: '2026-05-01T00:00:00Z', latestOrderId: 'GPA.1111-2222..0', lineItems: [li] }, NOW);
  assert.equal(renewed.status, 'premium');
  const canceled = fromPlay({ subscriptionState: 'SUBSCRIPTION_STATE_CANCELED', startTime: '2026-05-01T00:00:00Z', latestOrderId: 'GPA.1..0', lineItems: [li] }, NOW);
  assert.equal(canceled.status, 'cancelled');
  assert.equal(fromPlay({ subscriptionState: 'SUBSCRIPTION_STATE_EXPIRED', lineItems: [li] }, NOW).status, 'expired');
});

test('razorpay order signature: order_id|payment_id', () => {
  const secret = 'shh';
  const sig = hmac(secret, 'order_1|pay_1');
  assert.equal(verifyOrderSignature({ orderId: 'order_1', paymentId: 'pay_1', signature: sig }, secret), true);
  assert.equal(verifyOrderSignature({ orderId: 'order_2', paymentId: 'pay_1', signature: sig }, secret), false);
  assert.equal(verifyOrderSignature({ orderId: 'order_1', paymentId: 'pay_1', signature: 'x' }, secret), false);
  assert.equal(verifyOrderSignature({ orderId: 'order_1', paymentId: 'pay_1' }, secret), false);
});

const { isAdmin, splitAmount, validateProfile, isExpired, queuePosition, canTake, publicInterpreter, REQUEST_TTL_MS } = require('../lib/interpreters');

test('interpreter queue: oldest first, expired requests do not count', () => {
  const now = 1_000_000_000;
  const reqs = [
    { id: 'b', status: 'waiting', createdAt: now - 20_000 },
    { id: 'a', status: 'waiting', createdAt: now - 60_000 },
    { id: 'old', status: 'waiting', createdAt: now - REQUEST_TTL_MS - 1 },
    { id: 'done', status: 'accepted', createdAt: now - 90_000 },
  ];
  assert.equal(queuePosition(reqs, 'a', now), 1);
  assert.equal(queuePosition(reqs, 'b', now), 2);
  assert.equal(queuePosition(reqs, 'old', now), null);
  assert.equal(queuePosition(reqs, 'done', now), null);
  assert.equal(isExpired(reqs[2], now), true);
});

test('interpreter eligibility: approved, available, language and named-interpreter checks', () => {
  const i = { id: 'i1', approved: true, status: 'available', languages: ['en', 'hi'] };
  assert.equal(canTake(i, { language: 'hi' }), true);
  assert.equal(canTake(i, { language: 'kn' }), false);
  assert.equal(canTake(i, { language: 'hi', interpreterId: 'other' }), false);
  assert.equal(canTake({ ...i, status: 'busy' }, { language: 'hi' }), false);
  assert.equal(canTake({ ...i, approved: false }, { language: 'hi' }), false);
  assert.equal(canTake(null, { language: 'hi' }), false);
  assert.equal(publicInterpreter('x', { name: 'N', status: 'weird' }).status, 'offline');
});

test('platform fee split keeps every paisa and rounds the fee up', () => {
  assert.deepEqual(splitAmount(20000, 20), { amountPaise: 20000, feePaise: 4000, interpreterPaise: 16000 });
  const odd = splitAmount(101, 20);
  assert.equal(odd.feePaise + odd.interpreterPaise, 101);
  assert.deepEqual(splitAmount(5000, 0), { amountPaise: 5000, feePaise: 0, interpreterPaise: 5000 });
  assert.equal(splitAmount(5000, 150).interpreterPaise, 0); // fee capped at 100%
});

test('interpreter profile validation', () => {
  const ok = validateProfile({ name: ' Ravi ', languages: ['EN', 'hi', 'en'], ratePaise: 15000, bio: 'x' });
  assert.deepEqual([ok.name, ok.languages, ok.ratePaise], ['Ravi', ['en', 'hi'], 15000]);
  assert.equal(validateProfile({ name: 'Ravi', languages: ['en'] }).ratePaise, 0); // free is allowed
  for (const bad of [{ name: 'R', languages: ['en'] }, { name: 'Ravi', languages: [] }, { name: 'Ravi', languages: ['english'] },
    { name: 'Ravi', languages: ['en'], ratePaise: 50 }, { name: 'Ravi', languages: ['en'], ratePaise: 99999999 }, { name: 'Ravi', languages: ['en'], ratePaise: 10.5 }]) {
    assert.throws(() => validateProfile(bad), (e) => e.status === 400);
  }
});

test('admin check: verified e-mail or listed uid only', () => {
  const cfg = { emails: ['Owner@Gmail.com'], uids: ['uid_admin'] };
  assert.equal(isAdmin({ uid: 'x', email: 'owner@gmail.com', email_verified: true }, cfg), true); // case-insensitive
  assert.equal(isAdmin({ uid: 'x', email: 'owner@gmail.com', email_verified: false }, cfg), false); // unverified e-mail is never trusted
  assert.equal(isAdmin({ uid: 'x', email: 'owner@gmail.com' }, cfg), false);
  assert.equal(isAdmin({ uid: 'uid_admin' }, cfg), true);
  assert.equal(isAdmin({ uid: 'other', email: 'other@gmail.com', email_verified: true }, cfg), false);
  assert.equal(isAdmin(null, cfg), false);
  assert.equal(isAdmin({ uid: 'x', email: 'a@b.c', email_verified: true }, {}), false);
});
