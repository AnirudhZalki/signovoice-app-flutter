#!/usr/bin/env node
'use strict';
/**
 * Verifies your Razorpay keys end to end from your own machine:
 *   cd backend/functions && npm install && node scripts/check-razorpay.js
 * Reads RAZORPAY_KEY_ID / RAZORPAY_KEY_SECRET from the environment or backend/functions/.env + .secret.local.
 * Creates a Rs 1 TEST order, then checks the signature logic with a locally computed signature.
 */
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

for (const f of ['.env', '.secret.local']) {
  const p = path.join(__dirname, '..', f);
  if (!fs.existsSync(p)) continue;
  for (const line of fs.readFileSync(p, 'utf8').split('\n')) {
    const m = line.match(/^\s*([A-Z0-9_]+)\s*=\s*(.*)\s*$/);
    if (m && !process.env[m[1]]) process.env[m[1]] = m[2];
  }
}
const { RAZORPAY_KEY_ID: id, RAZORPAY_KEY_SECRET: secret } = process.env;
if (!id || !secret) { console.error('Missing RAZORPAY_KEY_ID / RAZORPAY_KEY_SECRET'); process.exit(1); }
if (!id.startsWith('rzp_test_')) console.warn('NOTE: this is not a test key (rzp_test_...). A live key creates real orders.');

const Razorpay = require('razorpay');
const { verifyOrderSignature, hmac } = require('../lib/razorpay');

(async () => {
  const rz = new Razorpay({ key_id: id, key_secret: secret });
  const order = await rz.orders.create({ amount: 100, currency: 'INR', receipt: `check_${Date.now()}` });
  console.log('1. order created:', order.id, order.amount, order.currency);
  const sig = hmac(secret, `${order.id}|pay_FAKE123`);
  console.log('2. signature check (valid):', verifyOrderSignature({ orderId: order.id, paymentId: 'pay_FAKE123', signature: sig }, secret));
  console.log('3. signature check (tampered):', verifyOrderSignature({ orderId: order.id, paymentId: 'pay_OTHER', signature: sig }, secret));
  console.log('OK: keys work. Next: deploy the backend and set API_BASE_URL (docs/RAZORPAY_ENABLE.md).');
})().catch((e) => {
  const d = (e && e.error && e.error.description) || e.message;
  console.error('FAILED:', d, e && e.statusCode === 401 ? '(authentication failed: check the key id/secret pair)' : '');
  process.exit(1);
});
