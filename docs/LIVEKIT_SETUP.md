# Live interpretation with LiveKit

Two ways the app gets a LiveKit token (the API *secret* never lives in the app):

1. **Token server (Render)** — `LIVEKIT_TOKEN_URL` (default `https://signovoice-livekkit-server.onrender.com/token`) with `LIVEKIT_URL=wss://signovoice-kki1ealv.livekit.cloud`.
   Live screen → **Join a live room** → both people enter the same room code → Video/Audio.
   The app sends `POST {url}` JSON `{room, roomName, identity, name}` (falls back to `GET {url}?room=…&identity=…&name=…` on 404/405) and accepts
   `{token}` / `{accessToken}` / `{jwt}` (optionally `url`/`serverUrl`/`wsUrl`) or a bare JWT string. If your server uses another path or shape,
   set `LIVEKIT_TOKEN_URL` to the right full URL (e.g. `…/getToken`) or tell me the response format.
2. **Backend interpreter matching** — `POST /v1/interpreter/*` + `/v1/livekit/token` in `backend/functions` (needs `API_BASE_URL`).

Render's free tier sleeps: the first request can take ~60 s, so the app waits up to 75 s.
Quick server check: `curl -X POST https://signovoice-livekkit-server.onrender.com/token -H 'content-type: application/json' -d '{"room":"test","identity":"me"}'` should return a token.
The LiveKit server itself must have the same API key/secret as the project at `signovoice-kki1ealv.livekit.cloud`.
