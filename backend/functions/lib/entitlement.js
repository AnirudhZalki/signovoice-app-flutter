'use strict';
// Pure functions (no I/O) that turn provider data into the entitlement document the app reads.
// Shape == lib/features/subscription/domain/subscription.dart (Subscription.fromJson).

const DAY = 24 * 3600 * 1000;
const iso = (ms) => (ms == null ? null : new Date(ms).toISOString());

/** Razorpay subscription entity -> entitlement. `state` = what we stored ({trialStart, cancelRequested}). */
function fromRazorpay(sub, state = {}, nowMs = Date.now(), productId = null) {
  const startAt = sub.start_at ? sub.start_at * 1000 : null; // first charge (end of trial)
  const currentEnd = sub.current_end ? sub.current_end * 1000 : null;
  const paid = Number(sub.paid_count || 0);
  const base = {
    productId,
    platform: 'razorpay',
    autoRenewing: false,
    purchaseToken: null,
    verifiedAt: iso(nowMs),
    trialStartDate: iso(state.trialStart ?? null),
    trialEndDate: null,
    subscriptionStartDate: null,
    subscriptionEndDate: null,
  };
  switch (sub.status) {
    case 'authenticated': // mandate authorised, first charge scheduled at start_at => free trial
    case 'active': {
      if (paid === 0 && startAt && startAt > nowMs) {
        return { ...base, status: 'trial', trialStartDate: iso(state.trialStart ?? nowMs), trialEndDate: iso(startAt),
          subscriptionEndDate: iso(startAt), autoRenewing: !state.cancelRequested };
      }
      const end = currentEnd ?? startAt;
      if (state.cancelRequested) return { ...base, status: 'cancelled', subscriptionEndDate: iso(end), subscriptionStartDate: iso(sub.current_start ? sub.current_start * 1000 : null) };
      return { ...base, status: end && end > nowMs ? 'premium' : 'expired', autoRenewing: true,
        subscriptionStartDate: iso(sub.current_start ? sub.current_start * 1000 : null), subscriptionEndDate: iso(end) };
    }
    case 'pending': // a renewal charge failed and is being retried
    case 'halted':
      return { ...base, status: currentEnd && currentEnd > nowMs ? 'cancelled' : 'expired', subscriptionEndDate: iso(currentEnd) };
    case 'cancelled':
    case 'completed':
    case 'expired':
      return { ...base, status: currentEnd && currentEnd > nowMs ? 'cancelled' : 'expired', subscriptionEndDate: iso(currentEnd) };
    default: // created / paused
      return { ...base, status: 'free' };
  }
}

/** Google Play SubscriptionPurchaseV2 -> entitlement. */
function fromPlay(p, nowMs = Date.now(), purchaseToken = null) {
  const li = (p.lineItems || [])[0] || {};
  const expiry = li.expiryTime ? Date.parse(li.expiryTime) : null;
  const start = p.startTime ? Date.parse(p.startTime) : null;
  const autoRenew = !!(li.autoRenewingPlan && li.autoRenewingPlan.autoRenewEnabled);
  // First order id has no ".."; renewals are GPA.xxxx..0, ..1 ...  A first period with an offer is the free trial.
  const firstPeriod = p.latestOrderId ? !String(p.latestOrderId).includes('..') : false;
  const inTrial = firstPeriod && !!(li.offerDetails && li.offerDetails.offerId) && start && expiry && expiry - start <= 32 * DAY;
  const base = {
    productId: li.productId || null, platform: 'android', autoRenewing: autoRenew, purchaseToken,
    verifiedAt: iso(nowMs), trialStartDate: inTrial ? iso(start) : null, trialEndDate: inTrial ? iso(expiry) : null,
    subscriptionStartDate: iso(start), subscriptionEndDate: iso(expiry),
  };
  switch (p.subscriptionState) {
    case 'SUBSCRIPTION_STATE_ACTIVE':
    case 'SUBSCRIPTION_STATE_IN_GRACE_PERIOD':
      return { ...base, status: inTrial ? 'trial' : 'premium' };
    case 'SUBSCRIPTION_STATE_CANCELED':
      return { ...base, status: expiry && expiry > nowMs ? 'cancelled' : 'expired', autoRenewing: false };
    case 'SUBSCRIPTION_STATE_ON_HOLD':
    case 'SUBSCRIPTION_STATE_PAUSED':
    case 'SUBSCRIPTION_STATE_EXPIRED':
      return { ...base, status: 'expired', autoRenewing: false };
    default:
      return { ...base, status: 'free', autoRenewing: false };
  }
}

module.exports = { fromRazorpay, fromPlay };
