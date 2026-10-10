# Premium subscription & auto-pay setup

## Plans: Free, Premium ₹75 / month, Premium ₹200 / 6 months — both with a 1-month free trial
The app already has the **Free** plan (daily recognition/history limits) and **Premium** (unlimited). Two paid products, ids:
`signovoice_premium_monthly` (₹75 every month) and `signovoice_premium_6months` (₹200 every 6 months; the app shows a "Save N%" badge computed from the real prices, ≈56%).
Prices are **never hard-coded**: the app shows what Google Play / Razorpay return, so you set ₹75 / ₹200 in those two places. The 6-month plan is pre-selected.

### Google Play (Play Store builds — Play autopay)
Create **two subscriptions** (Monetize with Play → Products → Subscriptions → Create subscription):
| Product ID | Base plan | Price |
|---|---|---|
| `signovoice_premium_monthly` | Auto-renewing, billing period **Monthly** | **₹75** (India) |
| `signovoice_premium_6months` | Auto-renewing, billing period **Every 6 months** | **₹200** (India) |
For each: grace period 7 days, account hold 30 days, resubscribe allowed. Then **Add offer** on the base plan → *New customer acquisition*, phase **Free trial, 1 month**, and **activate** the offer and the base plan.
To stop a person getting a free month on *each* plan, set the offer's eligibility to the option that excludes anyone who ever had **any subscription in this app** when Play offers it (otherwise "never had this subscription" lets someone trial both once).
Then: turn on **Real-time developer notifications** (Pub/Sub), deploy the backend (section A), upload a build to **Internal testing**, add **license testers** (Setup → License testing) and install from the Play link — billing never works in a sideloaded APK (that is the "plans couldn't be loaded" error). Play renews automatically; users cancel in Play › Subscriptions (the app's *Manage subscription* opens it).

### Razorpay (APK / website builds — UPI AutoPay, cards, e-mandate)
1. Dashboard (Test mode first) → **Subscriptions → Plans → Create Plan**, twice:
   - "Premium monthly": billing frequency **Monthly**, every **1**, amount **75** (7500 paise).
   - "Premium 6 months": **Monthly**, every **6**, amount **200** (20000 paise).
   Copy both `plan_…` ids.
2. Settings → **Payment methods**: enable UPI (AutoPay), cards, e-mandate (amounts ≤ ₹15,000 need no extra OTP after the first mandate approval).
3. Backend env `RAZORPAY_PLANS`:
   `{"signovoice_premium_monthly":{"planId":"plan_AAA","title":"Premium monthly","months":1,"totalCount":120},"signovoice_premium_6months":{"planId":"plan_BBB","title":"Premium 6 months","months":6,"totalCount":20}}`
   (`totalCount` = number of billing cycles; cycle and price are read from the Razorpay plan, so a price change = new plan + new id here.)
4. Free month: the backend starts the first charge after `TRIAL_DAYS=30` and gives **one trial per account** across both plans (it remembers `trialStartDate`). The user still approves the mandate up front.
5. Build with `--dart-define=ENABLE_RAZORPAY=true` (+ `PAYMENT_METHOD=razorpay` to make it the default). **Never in the Google Play build** — Play requires Play Billing for in-app subscriptions.
6. Go live: Live keys, recreate both plans in Live mode, update `RAZORPAY_KEY_ID/SECRET`, `RAZORPAY_PLANS` and the webhook secret.

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
# functions/.env: RAZORPAY_KEY_ID, RAZORPAY_PLANS, TRIAL_DAYS=30, PLAY_PACKAGE_NAME=com.anirudhzalki.signovoiceapp, LIVEKIT_URL, LIVEKIT_API_KEY
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
