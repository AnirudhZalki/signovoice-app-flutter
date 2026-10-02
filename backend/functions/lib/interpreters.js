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
});

const validRoom = (s) => /^sv-[A-Za-z0-9_-]{4,64}$/.test(s || '');

module.exports = { REQUEST_TTL_MS, isExpired, queuePosition, canTake, publicInterpreter, validRoom };
