# Turn Razorpay on — checklist (test mode)

## Your setup, fastest path (backend on https://signovoice-api.onrender.com)
1. **Create the two plans (₹75 / month, ₹200 / 6 months)** — PowerShell, from `backend\functions` (after `git pull`):
   ```
   $env:RAZORPAY_KEY_ID="rzp_test_..."; $env:RAZORPAY_KEY_SECRET="..."; node scripts/create-plans.js
   ```
   It prints a one-line JSON. (If Razorpay says Subscriptions are not enabled: dashboard → Subscriptions → Get started.)
2. **Render → your service → Environment**: set `RAZORPAY_PLANS` = that JSON, plus `RAZORPAY_KEY_ID`, `RAZORPAY_KEY_SECRET`, `RAZORPAY_WEBHOOK_SECRET` (any long random string), `FIREBASE_SERVICE_ACCOUNT`, `LIVEKIT_API_KEY`, `LIVEKIT_API_SECRET`. Save → it redeploys. Check `https://signovoice-api.onrender.com/healthz` → `{"ok":true}`.
3. **Razorpay → Webhooks → Add**: URL `https://signovoice-api.onrender.com/api/razorpay/webhook` (the `/api/...` path works as an alias of `/v1/...`), the same secret as `RAZORPAY_WEBHOOK_SECRET`, events `order.paid`, `subscription.activated`, `subscription.charged`, `subscription.halted`, `subscription.cancelled`, `subscription.completed`, `subscription.paused`, `subscription.resumed`.
4. **Run the app with Razorpay on:** `flutter run --dart-define-from-file=config/razorpay.json` (APK: `flutter build apk --release --dart-define-from-file=config/razorpay.json`). Not for the Play `.aab`.
5. Sign in → Profile → **Get Premium** → UPI, cards & wallets → pick a plan → test with `success@razorpay`.
Prices live in Razorpay: change `PRICE_MONTHLY_RS` / `PRICE_6MONTH_RS` when running `create-plans.js` and update `RAZORPAY_PLANS` with the new plan ids.

---

Already in the repo (don't re-create): order create + signature verify + subscriptions + webhook in `backend/functions`, checkout in the app
(`razorpay_order_checkout.dart`, `razorpay_billing_service.dart`, interpreter payments). What's left is **running the backend and building the app with Razorpay enabled**.

## 1. Check your keys (30 s, on your computer)
**Windows PowerShell** (no files needed — type your own key id and secret):
```
cd backend\functions
npm install
$env:RAZORPAY_KEY_ID = "rzp_test_XXXXXXXX"
$env:RAZORPAY_KEY_SECRET = "YOUR_SECRET"
node scripts/check-razorpay.js
```
**Mac / Linux:** `RAZORPAY_KEY_ID=rzp_test_XXXX RAZORPAY_KEY_SECRET=YOUR_SECRET node scripts/check-razorpay.js`
(`npm install` warnings about Node version or "moderate vulnerabilities" are harmless here. `printf` does not exist in PowerShell; use the lines above.)
Expect `order created: order_…` and `OK: keys work`. A 401 means the key id and secret are not a matching pair (copy both again from Razorpay → Settings → API Keys, same mode: Test or Live).
Never paste the secret into chats or commit it; if you did, **regenerate** it in the dashboard.

## 2. Run the backend on Render (free)
1. Render → **New → Blueprint** → pick this repo (it reads `render.yaml`).
2. Set the environment variables (Render never stores them in git): `RAZORPAY_KEY_ID`, `RAZORPAY_KEY_SECRET`, `RAZORPAY_WEBHOOK_SECRET` (any long random string you also paste into step 3), `RAZORPAY_PLANS` (see `docs/PAYMENTS_SETUP.md`), `LIVEKIT_API_KEY`, `LIVEKIT_API_SECRET`, `FIREBASE_SERVICE_ACCOUNT` (Firebase → Project settings → Service accounts → Generate key, pasted on one line).
3. After deploy, open `https://<your-service>.onrender.com/healthz` → `{"ok":true}`. This URL is your **`API_BASE_URL`**.

## 3. Razorpay dashboard
- **Webhooks → Add**: URL `https://<your-service>.onrender.com/v1/razorpay/webhook`, secret = `RAZORPAY_WEBHOOK_SECRET`, events: `order.paid`, `subscription.activated`, `subscription.charged`, `subscription.halted`, `subscription.cancelled`, `subscription.completed`, `subscription.paused`, `subscription.resumed`.
- **Subscriptions → Plans**: create ₹75 monthly and ₹200 every-6-months plans; put their `plan_…` ids in `RAZORPAY_PLANS`. Enable UPI AutoPay under Payment methods.

## 4. Build the app with Razorpay on (APK / non-Play builds only)
Put this in `config/dev.json` (copy of `config/dev.example.json`):
```
"API_BASE_URL": "https://<your-service>.onrender.com",
"ENABLE_RAZORPAY": true,
"PAYMENT_METHOD": "razorpay"
```
Run: `flutter run --dart-define-from-file=config/dev.json` · APK for friends/testers: `flutter build apk --release --dart-define-from-file=config/dev.json`.
**Play Store `.aab`:** use `config/prod.json` with `"ENABLE_RAZORPAY": false` (Play requires Google Play Billing for in-app subscriptions).

## 5. Test
1. Sign in (guests can't pay) → Profile → **Get Premium** → choose **UPI, cards & wallets** → pick a plan → **Start free trial**.
2. Razorpay test UPI id `success@razorpay` (failure: `failure@razorpay`); test card `4111 1111 1111 1111`, any future expiry/CVV.
3. A debug build also shows **Test payment ₹1** on the Premium page: it runs the one-time order → verify path.
4. After success the entitlement flips to Premium only after the backend verified the signature.

## Troubleshooting: "I can't pay on my phone"
Work top to bottom — the first failing item is the cause.
1. **Is the backend up and configured?** Open `https://signovoice-api.onrender.com/healthz` in the phone's browser (first load can take up to a minute: free Render sleeps). You should see `{"ok":true,"config":{…}}` with `razorpayKeyId`, `razorpayKeySecret`, `razorpayWebhookSecret`, `firebaseServiceAccount` all `true` and `razorpayPlans: 2`, `razorpayPlansValidJson: true`. Any `false`/`0` is a missing Render environment variable.
2. **Was the app built with Razorpay on?** It must be built with `--dart-define-from-file=config/razorpay.json`. Without it there is no "UPI, cards & wallets" option and no backend URL ("Online payments aren't set up on this build yet").
3. **Are you signed in?** Guests cannot pay (button says "Sign in to start your free trial"). Sign-in needs `google-services.json` in the build (see `docs/FIREBASE_SETUP.md`); the backend also needs `FIREBASE_SERVICE_ACCOUNT` to verify your login.
4. **Read the error line.** The Premium page now ends failures with a short reason in brackets:
   - `(timeout)` / `(offline)` – server asleep or no internet. Wait ~1 min and tap **Retry** (the app now wakes the server when the page opens and waits up to 60 s).
   - `(unauthorized · 401)` – the backend rejected your login: Firebase service account missing/for another project on Render, or you are not signed in.
   - `(serviceUnavailable · 500)` – server error: open Render → Logs. Typical: `RAZORPAY_PLANS` missing/invalid JSON, wrong key id/secret pair, plans created in the other mode (test vs live).
   - `(notFound · 404)` – wrong `API_BASE_URL` (must be the Render URL with no trailing path).
5. **Razorpay sheet opens but payment fails:** use test UPI `success@razorpay` or test card `4111 1111 1111 1111`. Real UPI apps do not work with Test keys.
6. **Paid but Premium did not unlock:** the backend verifies the payment; check Render logs and that `RAZORPAY_KEY_SECRET` on Render matches the key id the app received.

### "Please sign in again to continue" while signed in (no plans shown, Start free trial greyed out)
This is the server answering **401**: it could not verify your Firebase login. The usual cause is that Render's `FIREBASE_SERVICE_ACCOUNT` belongs to a **different Firebase project** than the app's `google-services.json`, or is missing/malformed JSON.
1. Open `https://signovoice-api.onrender.com/healthz` → note `firebaseProjectId` and `firebaseServiceAccountValid`.
2. In your app's `android/app/google-services.json` look at `"project_id"`. The two **must be identical**. If not: Firebase console (the app's project) → Project settings → Service accounts → **Generate new private key**, paste the whole JSON (one line) into Render's `FIREBASE_SERVICE_ACCOUNT`, save.
3. `firebaseServiceAccountValid` must be `true`. Then sign out and in again in the app and reopen Premium.
Render → Logs shows the exact reason as `verifyIdToken failed: …`.

### Easiest way to set the Firebase service account on Render (survives copy/paste)
1. Firebase console → Project settings → Service accounts → **Generate new private key** → save the `.json` file.
2. PowerShell (put the real file name): `[Convert]::ToBase64String([IO.File]::ReadAllBytes("C:\path\to\your-key.json")) | Set-Clipboard`
3. Render → Environment → add **`FIREBASE_SERVICE_ACCOUNT_BASE64`** = paste (Ctrl+V). Delete the old `FIREBASE_SERVICE_ACCOUNT` entry. Save.
4. `/healthz` must now show `"firebaseServiceAccountValid":true` and a `firebaseProjectId` equal to `project_id` in the app's `google-services.json`.
Also fix: `RAZORPAY_PLANS` (run `node scripts/create-plans.js`, paste the printed JSON line) and `RAZORPAY_WEBHOOK_SECRET` (any long random text, same as in the Razorpay webhook).

## What the app does per Razorpay's Android Standard Checkout steps
| Razorpay step | In this repo |
|---|---|
| Add the SDK | `razorpay_flutter` (wraps the Android Checkout SDK) in `pubspec.yaml`; Android needs minSdk ≥ 19 (app uses 24) |
| Create an order / subscription on **your server** | `POST /v1/razorpay/subscriptions` and `/v1/razorpay/orders` (Key *secret* stays on the server) |
| Open Checkout with key id + order/subscription id | `razorpay_billing_service.dart`, `order_checkout_runner.dart`, options in `razorpay_options.dart` |
| Payment methods | UPI shown first (UPI intent opens Google Pay / PhonePe / Paytm; UPI AutoPay for subscriptions), then cards, netbanking, wallets — `config.display` in `razorpay_options.dart`; edit there to hide/reorder methods or enable more in the Razorpay dashboard (Settings → Payment methods) |
| Android 11+ UPI apps visible | `<queries>` for `upi://pay` / `upi://mandate` in `AndroidManifest.xml` |
| ProGuard/R8 for release | `android/app/proguard-rules.pro` (Razorpay keep rules) |
| Handle success / error / external wallet | `EVENT_PAYMENT_SUCCESS` / `EVENT_PAYMENT_ERROR` / `EVENT_EXTERNAL_WALLET` handlers |
| **Verify the signature on your server** | `/v1/subscriptions/verify` and `/v1/razorpay/orders/verify` (HMAC-SHA256); webhook as the safety net |
| Prefill customer | email / phone / name of the signed-in user |
The checkout never works until the backend answers — see the troubleshooting section above (`/healthz` must show a valid Firebase service account, 2 plans and the webhook secret).
