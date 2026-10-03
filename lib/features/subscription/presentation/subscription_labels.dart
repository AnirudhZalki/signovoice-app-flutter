import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/config/app_config.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/status_widgets.dart';
import '../domain/billing_service.dart';
import '../domain/subscription.dart';

String periodWord(AppLocalizations l, String iso) => switch (parseBillingPeriod(iso).unit) {
      BillingUnit.year => l.periodYear,
      BillingUnit.month => l.periodMonth,
      BillingUnit.week => l.periodWeek,
      BillingUnit.day => l.periodDay,
      BillingUnit.unknown => l.periodMonth,
    };

/// "month", "year", or "6 months" for multi-month periods (so prices read "₹200 / 6 months", not "/ month").
String periodLabel(AppLocalizations l, String iso) {
  final p = parseBillingPeriod(iso);
  if (p.unit == BillingUnit.month && p.count > 1) return l.periodMonths('${p.count}');
  if (p.unit == BillingUnit.year && p.count > 1) return l.periodYears('${p.count}');
  return periodWord(l, iso);
}

String statusLabel(AppLocalizations l, SubscriptionStatus s) => switch (s) {
      SubscriptionStatus.free => l.statusFree,
      SubscriptionStatus.trial => l.statusTrial,
      SubscriptionStatus.premium => l.statusPremium,
      SubscriptionStatus.expired => l.statusExpired,
      SubscriptionStatus.cancelled => l.statusCancelled,
    };

(StatusTone, IconData) statusStyle(SubscriptionStatus s) => switch (s) {
      SubscriptionStatus.free => (StatusTone.neutral, Icons.person_outline_rounded),
      SubscriptionStatus.trial => (StatusTone.info, Icons.hourglass_top_rounded),
      SubscriptionStatus.premium => (StatusTone.success, Icons.workspace_premium_rounded),
      SubscriptionStatus.expired => (StatusTone.error, Icons.error_outline),
      SubscriptionStatus.cancelled => (StatusTone.warning, Icons.event_busy_rounded),
    };

String formatDate(BuildContext context, DateTime d) =>
    DateFormat.yMMMd(Localizations.localeOf(context).toString()).format(d);

String planTitle(AppLocalizations l, String productId) {
  if (productId.contains('year')) return l.planYearly;
  if (productId == AppConfig.sixMonthProductId || productId.contains('6month') || productId.contains('half')) return l.planSixMonth;
  return l.planMonthly;
}
