#!/usr/bin/env node
'use strict';
/**
 * Creates the two SignoVoice subscription plans in your Razorpay account and prints the RAZORPAY_PLANS value:
 *   Premium monthly   Rs 75   every 1 month   -> signovoice_premium_monthly
 *   Premium 6 months  Rs 200  every 6 months  -> signovoice_premium_6months
 *
 * PowerShell:
 *   $env:RAZORPAY_KEY_ID="rzp_test_..."; $env:RAZORPAY_KEY_SECRET="..."; node scripts/create-plans.js
 * Run once per mode (Test first, then Live with Live keys). Re-running creates NEW plans (Razorpay plans are immutable).
 * Amounts can be changed with PRICE_MONTHLY_RS / PRICE_6MONTH_RS.
 */
const Razorpay = require('razorpay');

const { RAZORPAY_KEY_ID: id, RAZORPAY_KEY_SECRET: secret } = process.env;
if (!id || !secret) { console.error('Set RAZORPAY_KEY_ID and RAZORPAY_KEY_SECRET first.'); process.exit(1); }
const monthlyRs = Number(process.env.PRICE_MONTHLY_RS || 75);
const sixRs = Number(process.env.PRICE_6MONTH_RS || 200);

const defs = [
  { productId: 'signovoice_premium_monthly', title: 'Premium monthly', interval: 1, months: 1, rupees: monthlyRs, totalCount: 120 },
  { productId: 'signovoice_premium_6months', title: 'Premium 6 months', interval: 6, months: 6, rupees: sixRs, totalCount: 20 },
];

(async () => {
  const rz = new Razorpay({ key_id: id, key_secret: secret });
  const out = {};
  for (const d of defs) {
    const plan = await rz.plans.create({
      period: 'monthly',
      interval: d.interval,
      item: { name: `SignoVoice ${d.title}`, amount: Math.round(d.rupees * 100), currency: 'INR', description: `${d.title} (auto-renewing)` },
      notes: { productId: d.productId },
    });
    console.log(`created ${plan.id}: ${d.title} = Rs ${d.rupees} every ${d.interval} month(s)`);
    out[d.productId] = { planId: plan.id, title: d.title, months: d.months, totalCount: d.totalCount };
  }
  console.log('\nSet this on Render as the RAZORPAY_PLANS environment variable (one line):\n');
  console.log(JSON.stringify(out));
})().catch((e) => {
  console.error('FAILED:', (e && e.error && e.error.description) || e.message, e && e.statusCode === 401 ? '(key id/secret mismatch)' : '');
  console.error('If it says Subscriptions are not enabled, enable them in the Razorpay dashboard first (Subscriptions → Get started).');
  process.exit(1);
});
