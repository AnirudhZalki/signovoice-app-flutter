# Premium subscription & auto-pay setup

The app supports two payment methods behind one verified flow (purchase → **backend verification** → entitlement; the client never grants Premium by itself):

| Method | Use for | Auto-pay |
|---|---|---|
| **Google Play Billing** | Builds distributed on Google Play (**mandatory** there for digital subscriptions) | Play renews automatically |
| **Razorpay** (UPI AutoPay incl. Google Pay/PhonePe/Paytm, cards, e-mandate) | Direct APK / website / non-Play distribution in India | Razorpay Subscriptions charge each cycle |

> Google Play policy requires Play Billing for in-app digital subscriptions in Play builds. Keep `ENABLE_RAZORPAY` **off** for the Play Store build; turn it on for side-loaded/other-store builds. "Google Pay" is a UPI app: you accept it through Razorpay's UPI (there is no separate Google Pay subscription SDK for this).

## A. Backend (required for both)
The reference implementation is in `backend/functions` (Firebase Cloud Functions, Node 20). It implements the contract in `docs/BACKEND_CONTRACT.md`.
```
cd backend/functions && npm install && node --test test/*.test.js
firebase functions:secrets:set RAZORPAY_KEY_SECRET RAZORPAY_WEBHOOK_SECRET LIVEKIT_API_SECRET
# functions/.env: RAZORPAY_KEY_ID, RAZORPAY_PLANS, TRIAL_DAYS=30, PLAY_PACKAGE_NAME=com.anirudhzalki.signovoice, LIVEKIT_URL, LIVEKIT_API_KEY
firebase deploy --only functions
```
Set the app's `API_BASE_URL` to the deployed function URL (Firebase ID token is sent as `Authorization: Bearer`).

## B. Razorpay (UPI AutoPay / cards)
1. Create a Razorpay account, complete KYC, and enable **Subscriptions** (and UPI AutoPay) in *Settings → Payment methods*.
2. Use **Test mode** first. *Subscriptions → Plans → Create plan*: monthly (`period=monthly, interval=1`) and yearly. Note each `plan_…` id and your price in paise.
3. *Settings → API keys*: copy **Key ID** (public, goes in the app and backend config) and **Key Secret** (backend secret only — never in the app).
4. Backend `RAZORPAY_PLANS`, e.g.
   `{"signovoice_premium_monthly":{"planId":"plan_XXXX","period":"monthly","title":"Premium monthly","totalCount":120},"signovoice_premium_yearly":{"planId":"plan_YYYY","period":"yearly","title":"Premium yearly","totalCount":10}}`.
   The free month is implemented by the backend setting the subscription `start_at` = now + `TRIAL_DAYS`, so the first charge happens after the trial (UPI AutoPay still asks for mandate approval up front).
5. *Webhooks → Add*: URL `https://<your-functions-host>/v1/razorpay/webhook`, secret = `RAZORPAY_WEBHOOK_SECRET`, events: `subscription.activated, subscription.charged, subscription.halted, subscription.cancelled, subscription.completed, subscription.paused, subscription.resumed`.
6. Build the app with `--dart-define=ENABLE_RAZORPAY=true` (and optionally `PAYMENT_METHOD=razorpay`). The Premium page then shows a **Pay with** selector; Manage subscription shows **Cancel auto-renew** for Razorpay subscriptions (cancels at cycle end).
7. Test with Razorpay test UPI ids (`success@razorpay`) before switching to Live keys.

## C. Google Play Billing
1. Play Console → your app → *Monetize → Products → Subscriptions*: create `signovoice_premium_monthly` and `signovoice_premium_yearly` (ids must match `IAP_MONTHLY_ID` / `IAP_YEARLY_ID`), add a base plan (auto-renewing) and an **offer** with a **1 month free trial** for new customers.
2. Upload a build to an internal-testing track, add license testers (*Setup → License testing*).
3. Service account for verification: Google Cloud → create service account, grant it access in Play Console *Users and permissions* ("View financial data" + "Manage orders and subscriptions"), and use it as the Cloud Functions runtime identity (or set `GOOGLE_APPLICATION_CREDENTIALS`).
4. Real-time notifications: Play Console *Monetization setup → Real-time developer notifications* → Pub/Sub topic; the `playRtdn` function subscribes to it.

## D. Checklist before release
- [ ] Backend deployed, `/v1/subscription` returns the entitlement for a test user.
- [ ] Razorpay test payment → webhook received → Premium unlocks; cancel → auto-renew off, access until period end.
- [ ] Play test purchase with free trial → verified → Premium; refund/cancel reflected via RTDN.
- [ ] Play build has `ENABLE_RAZORPAY` off.
