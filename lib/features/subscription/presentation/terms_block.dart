import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/routes.dart';
import '../../../core/utils/l10n_ext.dart';
import '../domain/billing_service.dart';
import '../domain/payment_method.dart';
import 'subscription_labels.dart';

/// The clear renewal terms shown before any purchase: trial length, price
/// after trial, billing period, auto-renewal and how to cancel.
class TermsBlock extends StatelessWidget {
  const TermsBlock({super.key, required this.product, this.method = PaymentMethod.googlePlay});
  final StoreProduct? product;
  final PaymentMethod method;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final p = product;

    final List<(IconData, String)> bullets;
    final String paragraph;
    if (p == null) {
      bullets = [(Icons.autorenew_rounded, l.renewsAutomatically), (Icons.event_available_outlined, l.cancelAnytime)];
      paragraph = l.priceShownAtCheckout;
    } else {
      final price = p.recurring.formattedPrice;
      final period = periodWord(l, p.recurring.billingPeriod);
      bullets = [
        if (p.hasFreeTrial) (Icons.card_giftcard_rounded, l.trialOneMonthFree),
        (Icons.payments_outlined, l.trialThenPrice(price, period)),
        (Icons.autorenew_rounded, l.renewsAutomatically),
        (Icons.event_available_outlined, l.cancelAnytime),
      ];
      paragraph = method == PaymentMethod.razorpay
          ? l.razorpayTerms
          : (p.hasFreeTrial ? l.trialTerms(price, period) : l.subscribeTerms(price, period));
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      for (final b in bullets)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(children: [
            Icon(b.$1, size: 20, color: scheme.secondary),
            const SizedBox(width: 10),
            Expanded(child: Text(b.$2, style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w600))),
          ]),
        ),
      const SizedBox(height: 8),
      Text(paragraph, style: text.bodySmall),
      const SizedBox(height: 4),
      Wrap(children: [
        TextButton(onPressed: () => context.push(Routes.legalTerms), child: Text(l.termsOfService)),
        TextButton(onPressed: () => context.push(Routes.legalPrivacy), child: Text(l.privacyPolicy)),
      ]),
    ]);
  }
}
