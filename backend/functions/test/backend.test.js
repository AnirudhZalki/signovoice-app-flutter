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
