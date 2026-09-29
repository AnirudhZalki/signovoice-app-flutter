import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

String planTitle(AppLocalizations l, String productId) =>
    productId.contains('year') ? l.planYearly : l.planMonthly;
