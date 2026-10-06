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

## Interpreter marketplace: register, go online, get paid
**Flow.** A person registers as an interpreter (Live screen → *Become an interpreter*: name, languages, rate per 30-min session, bio) → an admin approves →
the interpreter opens the **Interpreter desk** and switches **online/offline** → online interpreters appear in everyone's *Find an interpreter* list with their rate →
the user taps one → *Pay ₹X and connect* → Razorpay checkout → the backend verifies the payment signature → the request lands in **that interpreter's** queue →
they **Accept** (or **Decline**) → both join a private LiveKit room `sv-call-<id>`. Free interpreters set rate 0 (no payment step).

**Refunds are automatic** while nobody has accepted: user cancels while waiting, request expires (3 min), or the interpreter declines → Razorpay refund of the full amount.
If the app dies right after paying, the Razorpay `order.paid` **webhook** still queues the request (enable the `order.paid` event on your webhook, URL `…/v1/razorpay/webhook`).

**Backend settings** (Render env / functions config):
| Variable | Meaning |
|---|---|
| `RAZORPAY_KEY_ID`, `RAZORPAY_KEY_SECRET`, `RAZORPAY_WEBHOOK_SECRET` | payments (secrets never in the app) |
| `PLATFORM_FEE_PERCENT` | your cut of each paid session (default `20`); the rest is credited to the interpreter's `earningsPaise` |
| `INTERPRETER_AUTO_APPROVE` | `true` = anyone who registers is approved immediately (testing only); default `false` |
| `ADMIN_EMAILS` | comma-separated admin e-mails (default `zalkianirudh@gmail.com`). Counts only when Firebase marks the e-mail **verified** (Google sign-in does) |
| `ADMIN_UIDS` | comma-separated Firebase uids allowed to call `POST /v1/admin/interpreters/<uid>/approve` (or `/revoke`) |
| `DEFAULT_RATE_PAISE` | price of the generic *Request an interpreter* button (0 = free) |

**Approving an interpreter** — either call the admin endpoint with your own ID token (uid in `ADMIN_UIDS`), or in Firestore set `interpreters/<uid>.approved = true`.

**Payouts.** The app records each interpreter's share (`interpreterCalls/<id>.interpreterPaise`, running total `interpreters/<uid>.earningsPaise`). Money lands in **your** Razorpay account; paying interpreters out is manual (bank/UPI) or via Razorpay Route/RazorpayX once you set up linked accounts and KYC for them — not automated yet.

**Compliance notes — please check before launch.** Taking payments for a *human service* delivered through the app is treated differently from digital goods, but Google Play's payments policy and your Razorpay account terms apply; verify that live interpretation fits Play's "real-world services" rules for your listing. You are also responsible for GST/TDS and for interpreter KYC. Do not enable this in production until your backend, webhook and Razorpay Live keys are set up.

**Admin screen.** Signed in as an admin (e.g. zalkianirudh@gmail.com via Google), the **Live** tab shows an **Admin: interpreters** card → *Pending* / *Approved* tabs with **Approve** and **Remove approval** buttons. The server enforces admin rights; the app only hides the card from everyone else.

### Testing "Pay ₹X and connect" (needs TWO accounts)
1. Phone/account **A** (interpreter): registered, **approved** (admin screen), Interpreter desk → **Online**.
2. Phone/account **B** (user): Live → Find an interpreter → A appears with the rate → **Pay ₹50 and connect** → pay with `success@razorpay`.
3. A's desk shows the paid request → **Accept and join** → both are in the call.
You cannot book yourself (your own profile is hidden from your list). If the button is greyed, A is offline. Errors show the server's reason under the red message (e.g. "interpreter is not available" 409, "you cannot book yourself" 400, a Razorpay message 502).
