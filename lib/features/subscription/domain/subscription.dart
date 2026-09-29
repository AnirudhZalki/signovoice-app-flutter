import 'package:equatable/equatable.dart';

enum SubscriptionStatus { free, trial, premium, expired, cancelled }

enum StorePlatform { android, ios, unknown }

/// What the backend has verified about a person's subscription. This is data,
/// not a flag: access is *derived* from it by [TrialPolicy] at a given time.
class Subscription extends Equatable {
  const Subscription({
    this.status = SubscriptionStatus.free,
    this.trialStartDate,
    this.trialEndDate,
    this.subscriptionStartDate,
    this.subscriptionEndDate,
    this.productId,
    this.platform = StorePlatform.unknown,
    this.autoRenewing = false,
    this.purchaseToken,
    this.verifiedAt,
  });

  static const free = Subscription();

  final SubscriptionStatus status;
  final DateTime? trialStartDate;
  final DateTime? trialEndDate;
  final DateTime? subscriptionStartDate;
  final DateTime? subscriptionEndDate;
  final String? productId;
  final StorePlatform platform;
  final bool autoRenewing;

  /// Store purchase token / transaction id. Sensitive: never log or analytics.
  final String? purchaseToken;

  /// When the backend last confirmed this record. Null = never verified.
  final DateTime? verifiedAt;

  bool get hasEverTrialed => trialStartDate != null;

  Subscription copyWith({
    SubscriptionStatus? status,
    DateTime? trialStartDate,
    DateTime? trialEndDate,
    DateTime? subscriptionStartDate,
    DateTime? subscriptionEndDate,
    String? productId,
    StorePlatform? platform,
    bool? autoRenewing,
    String? purchaseToken,
    DateTime? verifiedAt,
  }) =>
      Subscription(
        status: status ?? this.status,
        trialStartDate: trialStartDate ?? this.trialStartDate,
        trialEndDate: trialEndDate ?? this.trialEndDate,
        subscriptionStartDate: subscriptionStartDate ?? this.subscriptionStartDate,
        subscriptionEndDate: subscriptionEndDate ?? this.subscriptionEndDate,
        productId: productId ?? this.productId,
        platform: platform ?? this.platform,
        autoRenewing: autoRenewing ?? this.autoRenewing,
        purchaseToken: purchaseToken ?? this.purchaseToken,
        verifiedAt: verifiedAt ?? this.verifiedAt,
      );

  Map<String, dynamic> toJson() => {
        'status': status.name,
        'trialStartDate': trialStartDate?.toIso8601String(),
        'trialEndDate': trialEndDate?.toIso8601String(),
        'subscriptionStartDate': subscriptionStartDate?.toIso8601String(),
        'subscriptionEndDate': subscriptionEndDate?.toIso8601String(),
        'productId': productId,
        'platform': platform.name,
        'autoRenewing': autoRenewing,
        'purchaseToken': purchaseToken,
        'verifiedAt': verifiedAt?.toIso8601String(),
      };

  factory Subscription.fromJson(Map<String, dynamic> j) {
    DateTime? d(String k) => DateTime.tryParse((j[k] as String?) ?? '');
    return Subscription(
      status: SubscriptionStatus.values.firstWhere((s) => s.name == j['status'], orElse: () => SubscriptionStatus.free),
      trialStartDate: d('trialStartDate'),
      trialEndDate: d('trialEndDate'),
      subscriptionStartDate: d('subscriptionStartDate'),
      subscriptionEndDate: d('subscriptionEndDate'),
      productId: j['productId'] as String?,
      platform: StorePlatform.values.firstWhere((s) => s.name == j['platform'], orElse: () => StorePlatform.unknown),
      autoRenewing: j['autoRenewing'] as bool? ?? false,
      purchaseToken: j['purchaseToken'] as String?,
      verifiedAt: d('verifiedAt'),
    );
  }

  @override
  List<Object?> get props => [
        status,
        trialStartDate,
        trialEndDate,
        subscriptionStartDate,
        subscriptionEndDate,
        productId,
        platform,
        autoRenewing,
        purchaseToken,
        verifiedAt,
      ];
}
