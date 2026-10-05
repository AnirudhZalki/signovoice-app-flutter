'use strict';
const admin = require('firebase-admin');

/** Verifies `Authorization: Bearer <Firebase ID token>`; returns the decoded token or throws {status}. */
async function requireUser(req) {
  const h = req.get('authorization') || '';
  const m = h.match(/^Bearer (.+)$/i);
  if (!m) throw Object.assign(new Error('missing token'), { status: 401 });
  try {
    return await admin.auth().verifyIdToken(m[1]);
  } catch (e) {
    // Logged for Render's log viewer (reason only, never the token). Typical causes:
    //  - auth/argument-error: not a Firebase ID token; auth/id-token-expired
    //  - "incorrect aud/iss": the app's Firebase project differs from the service account's project
    //  - app/invalid-credential: FIREBASE_SERVICE_ACCOUNT missing or malformed
    console.error('verifyIdToken failed:', (e && (e.code || e.errorInfo && e.errorInfo.code)) || 'unknown', String((e && e.message) || '').slice(0, 160));
    throw Object.assign(new Error('invalid token'), { status: 401 });
  }
}

// Per-instance sliding-window limiter. For real traffic use Firebase App Check + a shared limiter (Redis/Cloud Armor).
const hits = new Map();
function rateLimit(key, max, windowMs = 60_000) {
  const now = Date.now();
  const arr = (hits.get(key) || []).filter((t) => now - t < windowMs);
  if (arr.length >= max) throw Object.assign(new Error('rate limited'), { status: 429 });
  arr.push(now);
  hits.set(key, arr);
}

module.exports = { requireUser, rateLimit };
