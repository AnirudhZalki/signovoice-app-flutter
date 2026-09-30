'use strict';
const crypto = require('crypto');

const hmac = (secret, data) => crypto.createHmac('sha256', secret).update(data).digest('hex');
const safeEqual = (a, b) => {
  const x = Buffer.from(String(a)); const y = Buffer.from(String(b));
  return x.length === y.length && crypto.timingSafeEqual(x, y);
};

/** Checkout signature for subscriptions: HMAC_SHA256(paymentId + "|" + subscriptionId, keySecret). */
function verifyCheckoutSignature({ paymentId, subscriptionId, signature }, keySecret) {
  if (!paymentId || !subscriptionId || !signature) return false;
  return safeEqual(hmac(keySecret, `${paymentId}|${subscriptionId}`), signature);
}

/** Webhook signature: HMAC_SHA256(rawBody, webhookSecret) in header X-Razorpay-Signature. */
function verifyWebhookSignature(rawBody, signature, webhookSecret) {
  if (!rawBody || !signature) return false;
  return safeEqual(hmac(webhookSecret, rawBody), signature);
}

module.exports = { verifyCheckoutSignature, verifyWebhookSignature, hmac };
