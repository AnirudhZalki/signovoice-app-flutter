# Backend contract

The app never holds secrets. Everything below is implemented **by your backend** (Cloud Functions, Cloud Run, any HTTPS service). The Flutter code that calls each endpoint is named so you can read both sides together.

All endpoints:
- **HTTPS only**, JSON.
- `Authorization: Bearer <Firebase ID token>` — verify it with the Firebase Admin SDK on every request.
- Return `401/403` for auth problems, `404` if not found, `429` when rate limited, `5xx` for outages. The app maps these to human-readable messages (`lib/core/errors/failure_mapper.dart`).
- Apply **per-user rate limits** (recommended: 60 req/min general, 10/min for `/v1/subscriptions/*`, 5/min for `/v1/interpreter/requests`).

## Subscriptions (`lib/features/subscription/data/subscription_repository_impl.dart`)

Google Play billing → **the backend verifies, the app never trusts a purchase event alone**.

### `POST /v1/subscriptions/verify`
```json
{ "productId": "signovoice_premium_monthly", "purchaseToken": "…", "platform": "android", "orderId": "GPA.1234-…" }
```
1. Call Google Play Developer API `purchases.subscriptionsv2.get` with the token (service account with *Play Console → Users → Financial data / Manage orders* permission).
2. Check `productId` ∈ your products, `subscriptionState`, `acknowledgementState`.
3. **Acknowledge** the purchase (`purchases.subscriptions.acknowledge`) if not yet acknowledged (must happen within 3 days or Google refunds).
4. Bind the token to the caller's `uid` (reject tokens already bound to another uid).
5. Write `entitlements/{uid}` in Firestore (Admin SDK) and return the same object:

```json
{
  "status": "trial",                       // free | trial | premium | expired | cancelled
  "trialStartDate": "2026-06-01T10:00:00Z",
  "trialEndDate": "2026-07-01T10:00:00Z",
  "subscriptionStartDate": null,
  "subscriptionEndDate": "2026-07-01T10:00:00Z",   // current period end (renewal date)
  "productId": "signovoice_premium_monthly",
  "platform": "android",
  "autoRenewing": true,
  "purchaseToken": "…",                    // optional echo
  "verifiedAt": "2026-06-01T10:00:05Z"
}
```
Map Google's `subscriptionState`: `SUBSCRIPTION_STATE_ACTIVE` + free-trial offer phase → `trial`; `ACTIVE` → `premium`; `CANCELED` (still within period) → `cancelled`; `EXPIRED`/`ON_HOLD` → `expired`.

### `GET /v1/subscription`
Returns the caller's current entitlement (same shape). Used on app start and "Refresh status".

### `POST /v1/subscriptions/restore`
Body `{ "platform": "android" }`. Look up purchases previously bound to the caller (and/or re-query Play for stored tokens) and return the entitlement. Return `status: "free"` if none.

### Real-time updates (required for cancel / renewal / expiry)
Enable **Google Play Real-time developer notifications** (Pub/Sub) → a backend function that re-verifies the token and updates `entitlements/{uid}`. The app reads the change on next refresh; time-based expiry is also enforced client-side from the dates (`TrialPolicy`), so an old cached "trial" can never unlock access after its end date.

## AI translation (premium) — `lib/features/sign_translation/data/remote_translation_engine.dart`
`POST /v1/translate` `{ "glosses": ["WHERE","HOSPITAL"], "language": "en" }` → `{ "text": "Where is the hospital?" }`.
Your model/API keys live on the server. Enforce premium by reading `entitlements/{uid}`. The app falls back to on-device rules if this fails or the user isn't entitled.

## Remote recognition (optional) — `lib/features/sign_translation/data/remote_recognition_engine.dart`
`POST <REMOTE_RECOGNITION_URL>` with `{ "landmarks": [[63 floats] × 30], "modelVersion": 1 }` (hand-landmark coordinates only, **never images**) → `{ "probabilities": [ … ] }` in label order of `assets/models/labels.json`, or `{ "label": "Hello", "confidence": 0.93 }`.

## Sign dictionary pack (optional, scales to thousands of signs) — `lib/features/dictionary/data/sign_asset_repository.dart`
`GET /v1/dictionary?since=<version>` → same JSON schema as `assets/data/sign_dictionary.json` with a higher `version`. Media paths may be `https://…` URLs. Cached on device.

## Interpreters (`lib/features/interpreter/data/http_interpreter_repository.dart`)
| Endpoint | Body / result |
|---|---|
| `GET /v1/interpreters?language=hi` | `{ "interpreters": [ { "id", "name", "languages": ["en","hi"], "rating": 4.8, "ratingCount": 120, "status": "available|busy|offline", "photoUrl" } ] }` |
| `POST /v1/interpreter/requests` | `{ "mode": "video|audio", "language": "hi", "interpreterId"?: "…", "note"?: "…" }` → `{ "requestId": "…", "status": "waiting", "position": 2 }` |
| `GET /v1/interpreter/requests/{id}` | `{ "status": "waiting|accepted|declined|expired|cancelled", "position"?: 1, "session"?: { "callId", "token", "roomName", "url"?: "wss://…", "interpreterName" } }` |
| `DELETE /v1/interpreter/requests/{id}` | cancel a waiting request |
| `POST /v1/interpreter/calls/{callId}/feedback` | `{ "rating": 1-5, "comment"?: "…" }` |
| `POST /v1/interpreter/calls/{callId}/report` | `{ "category": "audio|video|interpreter|connection|other", "details"?: "…" }` |

**LiveKit token:** when a request is accepted, mint a short-lived (≤ 1 h) LiveKit access token server-side (`LIVEKIT_API_KEY/SECRET` stay on the server) granting join to `roomName` only, with identity = the caller's `uid`. Return it in `session.token`. The app connects with `LIVEKIT_URL` (or `session.url`). Chat uses the LiveKit data channel, topic `chat`, payload `{"id","text"}`.

## Firestore (`firestore.rules`)
| Path | Written by | Notes |
|---|---|---|
| `users/{uid}` | app (owner) | profile fields only, validated by rules |
| `users/{uid}/devices/{fcmToken}` | app (owner) | push registration |
| `entitlements/{uid}` | **backend only** | clients read-only |
| `deletionRequests/{uid}` | app creates once | backend processes: delete Firestore + Storage data for `uid`, revoke sessions, and if `deleteAccount` also remove the Auth user if the client didn't; then set `status: "done"` |

Account deletion order in the app: (1) create `deletionRequests/{uid}` (2) delete the Firebase Auth user (3) wipe local data. If (1) or (2) fails nothing local is removed and the person can retry.

## Push notifications (FCM)
Send `notification` payloads with optional `data.kind = "interpreter" | "system"`. Interpreter-request updates should be sent server-side when a request changes state.
