'use strict';
/**
 * Runs the same API as a plain Node server (e.g. on Render) instead of Firebase Cloud Functions:
 *   node server.js        (PORT is provided by the host)
 * Env: FIREBASE_SERVICE_ACCOUNT (service-account JSON, one line) + the variables listed in index.js
 * (RAZORPAY_KEY_ID/SECRET, RAZORPAY_WEBHOOK_SECRET, RAZORPAY_PLANS, LIVEKIT_URL/API_KEY/API_SECRET, ...).
 */
const fs = require('fs');
const os = require('os');
const path = require('path');

/** Service-account JSON from FIREBASE_SERVICE_ACCOUNT_BASE64 (recommended: survives copy/paste) or FIREBASE_SERVICE_ACCOUNT (raw JSON). */
function readServiceAccount() {
  let raw = process.env.FIREBASE_SERVICE_ACCOUNT_BASE64
    ? Buffer.from(process.env.FIREBASE_SERVICE_ACCOUNT_BASE64.trim(), 'base64').toString('utf8')
    : (process.env.FIREBASE_SERVICE_ACCOUNT || '');
  raw = raw.trim();
  if (raw.length > 1 && raw.startsWith('"') && raw.endsWith('"')) raw = raw.slice(1, -1).replace(/\\"/g, '"'); // pasted with wrapping quotes
  try {
    const sa = JSON.parse(raw);
    return sa && sa.client_email && sa.private_key ? { sa, raw } : null;
  } catch (_) {
    return null;
  }
}

const serviceAccount = readServiceAccount();
if (serviceAccount && !process.env.GOOGLE_APPLICATION_CREDENTIALS) {
  const file = path.join(os.tmpdir(), 'firebase-sa.json');
  fs.writeFileSync(file, JSON.stringify(serviceAccount.sa), { mode: 0o600 });
  process.env.GOOGLE_APPLICATION_CREDENTIALS = file;
}

const express = require('express');
const { api } = require('./index');

const app = express();
app.disable('x-powered-by');
// Firebase's onRequest handler expects the body to be parsed already (Cloud Functions does that for it; a plain
// Node server does not). Without this every POST sees req.body === undefined. rawBody is needed for webhook signatures.
app.use(express.json({ limit: '256kb', verify: (req, _res, buf) => { req.rawBody = buf; } }));
// Shows which settings are present (never their values) so a missing variable is easy to spot from a browser.
app.get('/healthz', (_req, res) => {
  const has = (k) => !!process.env[k];
  let plans = 0;
  let plansOk = true;
  try { plans = Object.keys(JSON.parse(process.env.RAZORPAY_PLANS || '{}')).length; } catch (_) { plansOk = false; }
  const projectId = serviceAccount ? serviceAccount.sa.project_id || null : null; // not a secret: must equal "project_id" in the app's google-services.json
  const saValid = !!serviceAccount;
  res.json({
    ok: true,
    firebaseProjectId: projectId,
    firebaseServiceAccountValid: saValid,
    config: {
      razorpayKeyId: has('RAZORPAY_KEY_ID'), razorpayKeySecret: has('RAZORPAY_KEY_SECRET'), razorpayWebhookSecret: has('RAZORPAY_WEBHOOK_SECRET'),
      razorpayPlans: plans, razorpayPlansValidJson: plansOk,
      firebaseServiceAccountSet: has('FIREBASE_SERVICE_ACCOUNT') || has('FIREBASE_SERVICE_ACCOUNT_BASE64') || has('GOOGLE_APPLICATION_CREDENTIALS'),
      livekitUrl: has('LIVEKIT_URL'), livekitKey: has('LIVEKIT_API_KEY'), livekitSecret: has('LIVEKIT_API_SECRET'),
    },
  });
});
app.all(/.*/, (req, res) => api(req, res));

const port = Number(process.env.PORT) || 8080;
app.listen(port, () => console.log(`SignoVoice API listening on ${port}`));
