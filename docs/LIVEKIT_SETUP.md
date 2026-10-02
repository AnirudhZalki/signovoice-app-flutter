# Live interpretation with LiveKit

Two ways the app gets a LiveKit token (the API *secret* never lives in the app):

1. **Token server (Render)** — `LIVEKIT_TOKEN_URL` (default `https://signovoice-livekkit-server.onrender.com/token`) with `LIVEKIT_URL=wss://signovoice-kki1ealv.livekit.cloud`.
   Live screen → **Join a live room** → both people enter the same room code → Video/Audio.
   Your server (`SignoVoice-livekkit-server`) takes `POST /token` with `{roomId, identity}` and replies `{token}` (no URL, so the app uses `LIVEKIT_URL`, which now defaults to `wss://signovoice-kki1ealv.livekit.cloud`).
   The app sends `POST {url}` JSON `{roomId, room, roomName, identity, name}` (falls back to `GET {url}?room=…&identity=…&name=…` on 404/405) and accepts
   `{token}` / `{accessToken}` / `{jwt}` (optionally `url`/`serverUrl`/`wsUrl`) or a bare JWT string. If your server uses another path or shape,
   set `LIVEKIT_TOKEN_URL` to the right full URL (e.g. `…/getToken`) or tell me the response format.
2. **Backend interpreter matching** — `POST /v1/interpreter/*` + `/v1/livekit/token` in `backend/functions` (needs `API_BASE_URL`).

Render's free tier sleeps: the first request can take ~60 s, so the app waits up to 75 s.
Quick server check: `curl -X POST https://signovoice-livekkit-server.onrender.com/token -H 'content-type: application/json' -d '{"room":"test","identity":"me"}'` should return a token.
The LiveKit server itself must have the same API key/secret as the project at `signovoice-kki1ealv.livekit.cloud`.

## Interpreter calls (matching + tokens) — `backend/functions`
The app's **Request an interpreter** flow and the **Interpreter desk** use `/v1/interpreter/*` and `/v1/interpreters` from the reference backend.
The backend mints LiveKit tokens itself with `LIVEKIT_API_KEY` / `LIVEKIT_API_SECRET` (server-side only), so it does not need the Render token server.

**Host it on Render (free, same place as your token server):** the repo has `render.yaml`. In Render → New → Blueprint → this repo, then set the secret env vars:
`LIVEKIT_API_KEY`, `LIVEKIT_API_SECRET`, `FIREBASE_SERVICE_ACCOUNT` (Firebase console → Project settings → Service accounts → Generate key; paste the JSON on one line), and optionally the Razorpay variables.
Use the service URL as `API_BASE_URL` in the app. (Or deploy to Firebase Functions instead: `firebase deploy --only functions`.)

**Make someone an interpreter:** in Firestore create `interpreters/<their Firebase uid>` with
`{ approved: true, name: "Ravi", languages: ["en","hi"], status: "offline", rating: null, ratingCount: 0 }`.
They then see an **Interpreter desk** tile on the Live screen: go online → accept waiting requests → joins the call room.
Flow: person taps *Request* → request waits (3 min max) → an online interpreter who speaks the language accepts → both get tokens for room `sv-call-<id>` → call.
Rotate the LiveKit API secret if it was ever shared in chat or committed.
