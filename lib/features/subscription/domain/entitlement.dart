import 'package:equatable/equatable.dart';

import '../../../core/constants/app_constants.dart';
import 'subscription.dart';
import 'trial_policy.dart';

/// Premium capabilities that genuinely exist in the app. Nothing is listed
/// here unless it is enforced somewhere.
enum PremiumFeature {
  unlimitedSignRecognition,
  fullHistory,
  advancedAiTranslation,
  learningAnalytics,
}

/// What a person may do at a moment in time.
class Entitlement extends Equatable {
  const Entitlement(this.subscription, this.evaluatedAt);

  factory Entitlement.at(Subscription s, DateTime now) => Entitlement(s, now);

  static final Entitlement none = Entitlement(Subscription.free, DateTime.fromMillisecondsSinceEpoch(0));

  final Subscription subscription;
  final DateTime evaluatedAt;

  SubscriptionStatus get status => TrialPolicy.effectiveStatus(subscription, evaluatedAt);
  bool get isPremium => TrialPolicy.hasPremiumAccess(subscription, evaluatedAt);
  bool get isTrial => status == SubscriptionStatus.trial;

  bool allows(PremiumFeature f) => isPremium;

  int get dailySignLimit => isPremium ? -1 : AppConstants.freeDailyTranslations; // -1 = unlimited
  int get historyLimit => isPremium ? -1 : AppConstants.freeHistoryEntries;

  @override
  List<Object?> get props => [subscription, evaluatedAt];
}
