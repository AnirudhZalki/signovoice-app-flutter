# Turn Razorpay on — checklist (test mode)

Already in the repo (don't re-create): order create + signature verify + subscriptions + webhook in `backend/functions`, checkout in the app
(`razorpay_order_checkout.dart`, `razorpay_billing_service.dart`, interpreter payments). What's left is **running the backend and building the app with Razorpay enabled**.

## 1. Check your keys (30 s, on your computer)
```
cd backend/functions && npm install
printf 'RAZORPAY_KEY_ID=rzp_test_TiILQgKZAz7bSM\n' > .env
printf 'RAZORPAY_KEY_SECRET=<your key secret>\n' > .secret.local     # both files are git-ignored
node scripts/check-razorpay.js
```
Expect `order created: order_…` and `OK: keys work`. A 401 means the key id/secret pair is wrong. (The secret was pasted in a chat — **regenerate it** in Razorpay → Settings → API Keys before going live.)

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
