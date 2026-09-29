import 'package:equatable/equatable.dart';

import 'subscription.dart';

class PricingPhase extends Equatable {
  const PricingPhase({required this.billingPeriod, required this.priceMicros, required this.formattedPrice});

  /// ISO-8601 period, e.g. `P1M`, `P1Y`, `P7D`.
  final String billingPeriod;
  final int priceMicros;
  final String formattedPrice;

  bool get isFree => priceMicros == 0;

  @override
  List<Object?> get props => [billingPeriod, priceMicros, formattedPrice];
}

/// A purchasable subscription offer as reported by the store. Prices are
/// always the store's own (localised, tax-inclusive) — never hard-coded.
class StoreProduct extends Equatable {
  const StoreProduct({
    required this.id,
    required this.title,
    required this.phases,
    this.offerToken,
    this.handle,
  });

  final String id;
  final String title;

  /// Pricing phases in order: optional free trial, then the recurring price.
  final List<PricingPhase> phases;
  final String? offerToken;

  /// Opaque platform object used to start the purchase.
  final Object? handle;

  bool get hasFreeTrial => phases.length > 1 && phases.first.isFree;
  PricingPhase? get trialPhase => hasFreeTrial ? phases.first : null;

  /// The recurring (post-trial) phase.
  PricingPhase get recurring => phases.last;

  @override
  List<Object?> get props => [id, title, phases, offerToken];
}

/// Chooses the offer to present for one product id: prefer a free-trial offer
/// (the store only returns offers the account is eligible for), otherwise the
/// plain base plan (the offer with the fewest phases).
StoreProduct? pickBestOffer(List<StoreProduct> variants) {
  if (variants.isEmpty) return null;
  final trial = variants.where((v) => v.hasFreeTrial).toList();
  if (trial.isNotEmpty) return trial.first;
  final sorted = [...variants]..sort((a, b) => a.phases.length.compareTo(b.phases.length));
  return sorted.first;
}

/// Human period from an ISO-8601 duration: `P1M` -> month, `P1Y` -> year.
enum BillingUnit { day, week, month, year, unknown }

({int count, BillingUnit unit}) parseBillingPeriod(String iso) {
  final m = RegExp(r'^P(?:(\d+)Y)?(?:(\d+)M)?(?:(\d+)W)?(?:(\d+)D)?$').firstMatch(iso);
  if (m == null) return (count: 1, unit: BillingUnit.unknown);
  final y = int.tryParse(m.group(1) ?? '');
  final mo = int.tryParse(m.group(2) ?? '');
  final w = int.tryParse(m.group(3) ?? '');
  final d = int.tryParse(m.group(4) ?? '');
  if (y != null) return (count: y, unit: BillingUnit.year);
  if (mo != null) return (count: mo, unit: BillingUnit.month);
  if (w != null) return (count: w, unit: BillingUnit.week);
  if (d != null) return (count: d, unit: BillingUnit.day);
  return (count: 1, unit: BillingUnit.unknown);
}

enum PurchaseEventStatus { pending, purchased, restored, error, cancelled }

class StorePurchase extends Equatable {
  const StorePurchase({
    required this.productId,
    required this.status,
    this.purchaseToken,
    this.orderId,
    this.handle,
    this.errorCode,
  });

  final String productId;
  final PurchaseEventStatus status;

  /// Sensitive; sent to the backend only. Never logged.
  final String? purchaseToken;
  final String? orderId;
  final Object? handle;
  final String? errorCode;

  @override
  List<Object?> get props => [productId, status, purchaseToken, orderId, errorCode];
}

abstract class BillingService {
  StorePlatform get platform;
  Future<bool> isAvailable();

  /// One entry per (product, offer). Use [pickBestOffer] per id.
  Future<List<StoreProduct>> loadProducts(Set<String> ids);

  /// Starts the store's purchase sheet. Returns false if it couldn't start.
  Future<bool> buy(StoreProduct product, {String? accountId});
  Future<void> restore({String? accountId});

  /// Purchase updates. Must be subscribed to for the whole app lifetime so
  /// pending / interrupted purchases are delivered.
  Stream<StorePurchase> get purchases;

  /// Acknowledge/finish a purchase — only after the backend verified it.
  Future<void> complete(StorePurchase purchase);
  Future<void> dispose();
}
