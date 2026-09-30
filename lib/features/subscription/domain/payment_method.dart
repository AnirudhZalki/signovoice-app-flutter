/// How a subscription is paid for.
enum PaymentMethod {
  /// Google Play Billing (required for Play-distributed builds).
  googlePlay,

  /// Razorpay Subscriptions: UPI AutoPay (Google Pay, PhonePe, …), cards, e-mandate.
  razorpay,
}
