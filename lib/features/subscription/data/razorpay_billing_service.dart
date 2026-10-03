import 'dart:async';
import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../../core/errors/failure.dart';
import '../../../core/services/api_client.dart';
import '../domain/billing_service.dart';
import '../domain/subscription.dart';

/// Razorpay Subscriptions (UPI AutoPay incl. Google Pay, cards, e-mandate) behind the same
/// [BillingService] contract as Google Play, so the purchase → **backend verification** →
/// entitlement flow, its states and its tests are shared.
///
/// Secrets never live here: the backend creates the subscription with the Razorpay key *secret* and
/// verifies the checkout signature. See docs/PAYMENTS_SETUP.md and docs/BACKEND_CONTRACT.md.
class RazorpayBillingService implements BillingService {
  RazorpayBillingService({required this.api, Razorpay? razorpay}) : _rz = razorpay ?? Razorpay() {
    _rz.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onSuccess, rawMap: true);
    _rz.on(Razorpay.EVENT_PAYMENT_ERROR, _onError, rawMap: true);
    _rz.on(Razorpay.EVENT_EXTERNAL_WALLET, (Object? _) {}, rawMap: true);
  }

  final ApiClient api;
  final Razorpay _rz;
  final _out = StreamController<StorePurchase>.broadcast();
  String? _pendingProductId;

  @override
  StorePlatform get platform => StorePlatform.razorpay;

  @override
  Stream<StorePurchase> get purchases => _out.stream;

  @override
  Future<bool> isAvailable() async => api.isConfigured;

  /// Plans (with real amounts) come from the backend, which owns the Razorpay plan ids.
  @override
  Future<List<StoreProduct>> loadProducts(Set<String> ids) async {
    final data = await api.get('/v1/razorpay/plans');
    final plans = (data is Map<String, dynamic> ? data['plans'] : null) as List<dynamic>? ?? const [];
    final out = <StoreProduct>[];
    for (final raw in plans) {
      final p = raw as Map<String, dynamic>;
      final id = p['productId'] as String;
      if (!ids.contains(id)) continue;
      final currency = (p['currency'] as String?) ?? 'INR';
      final amount = (p['amountPaise'] as num).toInt();
      final fmt = NumberFormat.simpleCurrency(name: currency, locale: 'en_IN', decimalDigits: amount % 100 == 0 ? 0 : 2);
      // Backend sends the plan's real billing cycle: `period` (monthly|yearly) x `interval` (e.g. 6 => every 6 months).
      final interval = (p['interval'] as num?)?.toInt() ?? 1;
      final period = (p['period'] as String?) == 'yearly' ? 'P${interval}Y' : 'P${interval}M';
      final trialDays = (p['trialDays'] as num?)?.toInt() ?? 0;
      out.add(StoreProduct(
        id: id,
        title: (p['title'] as String?) ?? id,
        handle: p['planId'],
        phases: [
          if (trialDays > 0) PricingPhase(billingPeriod: trialDays == 30 ? 'P1M' : 'P${trialDays}D', priceMicros: 0, formattedPrice: fmt.format(0)),
          PricingPhase(billingPeriod: period, priceMicros: amount * 10000, formattedPrice: fmt.format(amount / 100)),
        ],
      ));
    }
    return out;
  }

  @override
  Future<bool> buy(StoreProduct product, {String? accountId}) async {
    final res = await api.post('/v1/razorpay/subscriptions', body: {'productId': product.id});
    if (res is! Map<String, dynamic> || res['subscriptionId'] == null || res['keyId'] == null) {
      throw const Failure(FailureType.serviceUnavailable, debugDetail: 'malformed razorpay subscription');
    }
    _pendingProductId = product.id;
    _rz.open({
      'key': res['keyId'],
      'subscription_id': res['subscriptionId'],
      'name': 'SignoVoice',
      'description': product.title,
      'theme': {'color': '#3157D5'},
      'retry': {'enabled': true, 'max_count': 2},
    });
    return true;
  }

  void _onSuccess(Object? payload) {
    final m = payload is Map ? payload : const {};
    final sub = m['razorpay_subscription_id'];
    final pay = m['razorpay_payment_id'];
    final sig = m['razorpay_signature'];
    final id = _pendingProductId;
    if (id == null || sub == null || pay == null || sig == null) {
      _out.add(StorePurchase(productId: id ?? '', status: PurchaseEventStatus.error, errorCode: 'incomplete-response'));
      return;
    }
    // The backend recomputes HMAC-SHA256(paymentId|subscriptionId, keySecret) and compares.
    _out.add(StorePurchase(
      productId: id,
      status: PurchaseEventStatus.purchased,
      purchaseToken: jsonEncode({'subscriptionId': sub, 'paymentId': pay, 'signature': sig}),
      orderId: '$pay',
    ));
  }

  void _onError(Object? payload) {
    final m = payload is Map ? payload : const {};
    final code = m['code'];
    final id = _pendingProductId ?? '';
    _out.add(StorePurchase(
      productId: id,
      // Razorpay code 0 = the person closed the checkout.
      status: code == Razorpay.PAYMENT_CANCELLED ? PurchaseEventStatus.cancelled : PurchaseEventStatus.error,
      errorCode: '$code',
    ));
  }

  /// Nothing to restore locally: the backend owns the subscription; see `/v1/subscriptions/restore`.
  @override
  Future<void> restore({String? accountId}) async {}

  @override
  Future<void> complete(StorePurchase purchase) async {}

  @override
  Future<void> dispose() async {
    _rz.clear();
    await _out.close();
  }
}
