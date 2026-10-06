'use strict';
/** Pure helpers for interpreter matching (unit-tested; no Firebase / network). */

const REQUEST_TTL_MS = 3 * 60 * 1000; // a waiting request expires after 3 minutes

const isExpired = (req, now) => req.status === 'waiting' && now - req.createdAt > REQUEST_TTL_MS;

/** 1-based place in the queue among waiting, unexpired requests (oldest first), or null if not waiting. */
function queuePosition(requests, id, now) {
  const waiting = requests.filter((r) => r.status === 'waiting' && !isExpired(r, now)).sort((a, b) => a.createdAt - b.createdAt);
  const i = waiting.findIndex((r) => r.id === id);
  return i < 0 ? null : i + 1;
}

/** Can this interpreter take this request? (approved, online, speaks the language, and not a different named interpreter). */
function canTake(interpreter, req) {
  if (!interpreter || !interpreter.approved || interpreter.status !== 'available') return false;
  if (req.interpreterId && req.interpreterId !== interpreter.id) return false;
  const langs = interpreter.languages || [];
  return langs.length === 0 || langs.includes(req.language);
}

const publicInterpreter = (id, d) => ({
  id, name: d.name || '', languages: d.languages || [], rating: d.rating ?? null, ratingCount: d.ratingCount || 0,
  status: ['available', 'busy', 'offline'].includes(d.status) ? d.status : 'offline', photoUrl: d.photoUrl || null,
  ratePaise: d.ratePaise || 0, sessionMinutes: d.sessionMinutes || DEFAULT_SESSION_MINUTES, bio: d.bio || '',
});

const DEFAULT_SESSION_MINUTES = 30;
const MIN_RATE_PAISE = 100;     // Razorpay minimum order
const MAX_RATE_PAISE = 500000;  // Rs 5,000 per session

/** Interpreter's share of a paid session after the platform fee (integer paise; fee rounded to the platform's favour). */
function splitAmount(amountPaise, feePercent) {
  const pct = Math.min(100, Math.max(0, Number(feePercent) || 0));
  const fee = Math.ceil((amountPaise * pct) / 100);
  return { amountPaise, feePaise: fee, interpreterPaise: amountPaise - fee };
}

/** Validates the profile an interpreter submits; returns the cleaned fields or throws {status:400}. */
function validateProfile(body) {
  const bad = (m) => Object.assign(new Error(m), { status: 400 });
  const b = body || {};
  const name = String(b.name || '').trim();
  if (name.length < 2 || name.length > 60) throw bad('name must be 2-60 characters');
  const languages = [...new Set((Array.isArray(b.languages) ? b.languages : []).map((x) => String(x).toLowerCase()))];
  if (languages.length === 0 || languages.length > 8 || languages.some((x) => !/^[a-z]{2,3}$/.test(x))) throw bad('choose 1-8 languages');
  const rate = Number(b.ratePaise ?? 0);
  if (!Number.isInteger(rate) || (rate !== 0 && (rate < MIN_RATE_PAISE || rate > MAX_RATE_PAISE))) {
    throw bad(`rate must be 0 (free) or between ${MIN_RATE_PAISE} and ${MAX_RATE_PAISE} paise`);
  }
  const bio = String(b.bio || '').trim().slice(0, 300);
  return { name, languages, ratePaise: rate, bio, sessionMinutes: DEFAULT_SESSION_MINUTES };
}

const validRoom = (s) => /^sv-[A-Za-z0-9_-]{4,64}$/.test(s || '');

/** Admin = a listed Firebase uid, or a listed e-mail address that Firebase has VERIFIED (never trust an unverified e-mail). */
function isAdmin(decoded, { emails = [], uids = [] } = {}) {
  if (!decoded) return false;
  if (decoded.uid && uids.includes(decoded.uid)) return true;
  const mail = String(decoded.email || '').trim().toLowerCase();
  return !!mail && decoded.email_verified === true && emails.map((e) => e.trim().toLowerCase()).includes(mail);
}

module.exports = { isAdmin, splitAmount, validateProfile, DEFAULT_SESSION_MINUTES, REQUEST_TTL_MS, isExpired, queuePosition, canTake, publicInterpreter, validRoom };
