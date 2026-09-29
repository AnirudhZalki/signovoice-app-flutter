import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

import '../domain/billing_service.dart';
import '../domain/subscription.dart';

/// Google Play Billing (and StoreKit on iOS) through the official
/// `in_app_purchase` plugin. No third-party payment processor is involved.
class InAppBillingService implements BillingService {
  InAppBillingService([InAppPurchase? iap]) : _iap = iap ?? InAppPurchase.instance {
    _sub = _iap.purchaseStream.listen(_onUpdates, onError: (Object _) {});
  }

  final InAppPurchase _iap;
  late final StreamSubscription<List<PurchaseDetails>> _sub;
  final _out = StreamController<StorePurchase>.broadcast();
  final Map<String, PurchaseDetails> _details = {};

  @override
  StorePlatform get platform => defaultTargetPlatform == TargetPlatform.iOS ? StorePlatform.ios : StorePlatform.android;

  @override
  Stream<StorePurchase> get purchases => _out.stream;

  void _onUpdates(List<PurchaseDetails> list) {
    for (final p in list) {
      final key = '${p.productID}|${p.purchaseID ?? p.verificationData.serverVerificationData.hashCode}';
      _details[key] = p;
      final status = switch (p.status) {
        PurchaseStatus.pending => PurchaseEventStatus.pending,
        PurchaseStatus.purchased => PurchaseEventStatus.purchased,
        PurchaseStatus.restored => PurchaseEventStatus.restored,
        PurchaseStatus.canceled => PurchaseEventStatus.cancelled,
        PurchaseStatus.error => PurchaseEventStatus.error,
      };
      _out.add(StorePurchase(
        productId: p.productID,
        status: status,
        purchaseToken: p.verificationData.serverVerificationData,
        orderId: p.purchaseID,
        handle: p,
        errorCode: p.error?.code,
      ));
    }
  }

  @override
  Future<bool> isAvailable() async {
    try {
      return await _iap.isAvailable();
    } catch (_) {
      return false;
    }
  }

  @override
  Future<List<StoreProduct>> loadProducts(Set<String> ids) async {
    final res = await _iap.queryProductDetails(ids);
    final out = <StoreProduct>[];
    for (final d in res.productDetails) {
      if (d is GooglePlayProductDetails) {
        final offers = d.productDetails.subscriptionOfferDetails;
        final idx = d.subscriptionIndex;
        if (offers != null && idx != null && idx < offers.length) {
          final o = offers[idx];
          out.add(StoreProduct(
            id: d.id,
            title: d.title,
            offerToken: o.offerIdToken,
            handle: d,
            phases: [
              for (final ph in o.pricingPhases)
                PricingPhase(billingPeriod: ph.billingPeriod, priceMicros: ph.priceAmountMicros, formattedPrice: ph.formattedPrice),
            ],
          ));
          continue;
        }
      }
      // StoreKit / non-offer products: single recurring price (trial info comes from the store sheet).
      out.add(StoreProduct(
        id: d.id,
        title: d.title,
        handle: d,
        phases: [PricingPhase(billingPeriod: 'P1M', priceMicros: (d.rawPrice * 1e6).round(), formattedPrice: d.price)],
      ));
    }
    return out;
  }

  @override
  Future<bool> buy(StoreProduct product, {String? accountId}) {
    final d = product.handle as ProductDetails;
    final PurchaseParam param = d is GooglePlayProductDetails
        ? GooglePlayPurchaseParam(productDetails: d, offerToken: product.offerToken, applicationUserName: accountId)
        : PurchaseParam(productDetails: d, applicationUserName: accountId);
    // Subscriptions are non-consumable from the plugin's point of view.
    return _iap.buyNonConsumable(purchaseParam: param);
  }

  @override
  Future<void> restore({String? accountId}) => _iap.restorePurchases(applicationUserName: accountId);

  @override
  Future<void> complete(StorePurchase purchase) async {
    final h = purchase.handle;
    if (h is PurchaseDetails && h.pendingCompletePurchase) {
      await _iap.completePurchase(h);
    }
  }

  @override
  Future<void> dispose() async {
    await _sub.cancel();
    await _out.close();
  }
}
