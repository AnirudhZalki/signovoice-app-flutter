import 'dart:async';

import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../domain/interpreter_models.dart';

enum CheckoutOutcome { success, cancelled, failed }

class CheckoutResult {
  const CheckoutResult(this.outcome, {this.orderId, this.paymentId, this.signature, this.message});
  final CheckoutOutcome outcome;
  final String? orderId;
  final String? paymentId;
  final String? signature;
  final String? message;
}

/// Opens the payment sheet for an order the backend created. Abstract so tests can fake it.
abstract class OrderCheckoutRunner {
  Future<CheckoutResult> run(PaymentOrder order, {String? description});
}

/// Razorpay Standard Checkout. Only the public key id is used here; the backend verifies the signature.
class RazorpayCheckoutRunner implements OrderCheckoutRunner {
  @override
  Future<CheckoutResult> run(PaymentOrder order, {String? description}) {
    final rz = Razorpay();
    final done = Completer<CheckoutResult>();
    void finish(CheckoutResult r) {
      if (!done.isCompleted) done.complete(r);
    }

    rz.on(Razorpay.EVENT_PAYMENT_SUCCESS, (Object? p) {
      final m = p is Map ? p : const {};
      finish(CheckoutResult(CheckoutOutcome.success,
          orderId: '${m['razorpay_order_id']}', paymentId: '${m['razorpay_payment_id']}', signature: '${m['razorpay_signature']}'));
    }, rawMap: true);
    rz.on(Razorpay.EVENT_PAYMENT_ERROR, (Object? p) {
      final m = p is Map ? p : const {};
      finish(CheckoutResult(m['code'] == Razorpay.PAYMENT_CANCELLED ? CheckoutOutcome.cancelled : CheckoutOutcome.failed, message: '${m['message'] ?? ''}'));
    }, rawMap: true);
    rz.on(Razorpay.EVENT_EXTERNAL_WALLET, (Object? _) {}, rawMap: true);

    rz.open({
      'key': order.keyId,
      'order_id': order.orderId,
      'amount': order.amountPaise,
      'currency': order.currency,
      'name': 'SignoVoice',
      'description': description,
      'theme': {'color': '#3157D5'},
      'retry': {'enabled': true, 'max_count': 2},
    });
    return done.future.whenComplete(rz.clear);
  }
}
