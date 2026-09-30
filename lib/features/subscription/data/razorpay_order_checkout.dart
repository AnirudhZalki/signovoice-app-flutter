import 'dart:async';

import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../../core/errors/failure.dart';
import '../../../core/services/api_client.dart';

enum OrderPaymentOutcome { success, cancelled, failed }

class OrderPaymentResult {
  const OrderPaymentResult(this.outcome, {this.paymentId, this.message});
  final OrderPaymentOutcome outcome;
  final String? paymentId;
  final String? message;
}

/// Razorpay Standard Checkout for a one-time payment: backend creates the order, the SDK opens the
/// checkout with `order_id`, and the backend verifies the returned signature. The key *secret* never
/// reaches the app; only the public key id returned by the backend is used.
class RazorpayOrderCheckout {
  RazorpayOrderCheckout({required this.api, Razorpay? razorpay}) : _rz = razorpay ?? Razorpay() {
    _rz.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onSuccess, rawMap: true);
    _rz.on(Razorpay.EVENT_PAYMENT_ERROR, _onError, rawMap: true);
    _rz.on(Razorpay.EVENT_EXTERNAL_WALLET, (Object? _) {}, rawMap: true);
  }

  final ApiClient api;
  final Razorpay _rz;
  Completer<OrderPaymentResult>? _pending;

  /// Amount in paise (minimum 100).
  Future<OrderPaymentResult> pay({required int amountPaise, String currency = 'INR', String name = 'SignoVoice', String? description}) async {
    if (_pending != null) throw const Failure(FailureType.unknown, debugDetail: 'payment already in progress');
    final order = await api.post('/v1/razorpay/orders', body: {'amount': amountPaise, 'currency': currency});
    if (order is! Map<String, dynamic> || order['order_id'] == null || order['keyId'] == null) {
      throw const Failure(FailureType.serviceUnavailable, debugDetail: 'malformed order response');
    }
    final c = _pending = Completer<OrderPaymentResult>();
    _rz.open({
      'key': order['keyId'],
      'order_id': order['order_id'],
      'amount': order['amount'],
      'currency': order['currency'],
      'name': name,
      'description': description,
      'theme': {'color': '#3157D5'},
      'retry': {'enabled': true, 'max_count': 2},
    });
    return c.future;
  }

  Future<void> _onSuccess(Object? payload) async {
    final m = payload is Map ? payload : const {};
    final c = _pending;
    if (c == null) return;
    try {
      final res = await api.post('/v1/razorpay/orders/verify', body: {
        'razorpay_order_id': m['razorpay_order_id'],
        'razorpay_payment_id': m['razorpay_payment_id'],
        'razorpay_signature': m['razorpay_signature'],
      });
      final ok = res is Map && res['success'] == true;
      _finish(OrderPaymentResult(ok ? OrderPaymentOutcome.success : OrderPaymentOutcome.failed, paymentId: '${m['razorpay_payment_id']}'));
    } catch (e) {
      // Paid at Razorpay but not verified: never treat as paid.
      _finish(OrderPaymentResult(OrderPaymentOutcome.failed, message: '$e'));
    }
  }

  void _onError(Object? payload) {
    final m = payload is Map ? payload : const {};
    final cancelled = m['code'] == Razorpay.PAYMENT_CANCELLED;
    _finish(OrderPaymentResult(cancelled ? OrderPaymentOutcome.cancelled : OrderPaymentOutcome.failed, message: '${m['message'] ?? ''}'));
  }

  void _finish(OrderPaymentResult r) {
    final c = _pending;
    _pending = null;
    if (c != null && !c.isCompleted) c.complete(r);
  }

  void dispose() => _rz.clear();
}
