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
app.get('/healthz', (_req, res) => res.json({ ok: true }));
app.all(/.*/, (req, res) => api(req, res));

const port = Number(process.env.PORT) || 8080;
app.listen(port, () => console.log(`SignoVoice API listening on ${port}`));
