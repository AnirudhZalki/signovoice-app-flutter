import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signovoice/core/config/app_config.dart';
import 'package:signovoice/core/services/api_client.dart';
import 'package:signovoice/features/subscription/data/razorpay_billing_service.dart';
import 'package:signovoice/features/subscription/domain/billing_service.dart';

class _Adapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(RequestOptions o, Stream<Uint8List>? s, Future<void>? c) async => ResponseBody.fromString(
        jsonEncode({
          'plans': [
            {'productId': AppConfig.sixMonthProductId, 'planId': 'plan_6', 'title': 'Premium 6 months', 'period': 'monthly', 'interval': 6, 'amountPaise': 20000, 'currency': 'INR', 'trialDays': 30},
          ],
        }),
        200,
        headers: {Headers.contentTypeHeader: ['application/json']},
      );

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('a Rs 200 / 6-month Razorpay plan with a 30-day trial maps to P6M and shows the real price', () async {
    final api = ApiClient(tokenProvider: () async => null, baseUrl: 'https://api.test', dio: Dio()..httpClientAdapter = _Adapter());
    final products = await RazorpayBillingService(api: api).loadProducts(AppConfig.subscriptionProductIds);
    expect(products, hasLength(1));
    final p = products.single;
    expect(p.hasFreeTrial, isTrue);
    expect(p.recurring.billingPeriod, 'P6M');
    expect(p.recurring.formattedPrice, contains('200'));
    final parsed = parseBillingPeriod(p.recurring.billingPeriod);
    expect((parsed.count, parsed.unit), (6, BillingUnit.month));
  });
}
