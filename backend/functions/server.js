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

if (process.env.FIREBASE_SERVICE_ACCOUNT && !process.env.GOOGLE_APPLICATION_CREDENTIALS) {
  const file = path.join(os.tmpdir(), 'firebase-sa.json');
  fs.writeFileSync(file, process.env.FIREBASE_SERVICE_ACCOUNT, { mode: 0o600 });
  process.env.GOOGLE_APPLICATION_CREDENTIALS = file;
}

const express = require('express');
const { api } = require('./index');

const app = express();
app.disable('x-powered-by');
// Shows which settings are present (never their values) so a missing variable is easy to spot from a browser.
app.get('/healthz', (_req, res) => {
  const has = (k) => !!process.env[k];
  let plans = 0;
  let plansOk = true;
  try { plans = Object.keys(JSON.parse(process.env.RAZORPAY_PLANS || '{}')).length; } catch (_) { plansOk = false; }
  let projectId = null;
  let saValid = false;
  try {
    const sa = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT || '');
    projectId = sa.project_id || null; // not a secret: compare it with the Firebase project of the app's google-services.json
    saValid = !!(sa.client_email && sa.private_key);
  } catch (_) { /* leave null */ }
  res.json({
    ok: true,
    firebaseProjectId: projectId,
    firebaseServiceAccountValid: saValid,
    config: {
      razorpayKeyId: has('RAZORPAY_KEY_ID'), razorpayKeySecret: has('RAZORPAY_KEY_SECRET'), razorpayWebhookSecret: has('RAZORPAY_WEBHOOK_SECRET'),
      razorpayPlans: plans, razorpayPlansValidJson: plansOk,
      firebaseServiceAccount: has('FIREBASE_SERVICE_ACCOUNT') || has('GOOGLE_APPLICATION_CREDENTIALS'),
      livekitUrl: has('LIVEKIT_URL'), livekitKey: has('LIVEKIT_API_KEY'), livekitSecret: has('LIVEKIT_API_SECRET'),
    },
  });
});
app.all(/.*/, (req, res) => api(req, res));

const port = Number(process.env.PORT) || 8080;
app.listen(port, () => console.log(`SignoVoice API listening on ${port}`));
