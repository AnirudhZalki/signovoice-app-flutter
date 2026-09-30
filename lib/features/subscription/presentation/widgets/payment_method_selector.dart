import 'package:flutter/material.dart';

import '../../../../core/utils/l10n_ext.dart';
import '../../domain/payment_method.dart';

/// Google Play vs Razorpay (UPI AutoPay / cards). Only built when Razorpay is enabled.
class PaymentMethodSelector extends StatelessWidget {
  const PaymentMethodSelector({super.key, required this.selected, required this.onChanged, this.enabled = true});
  final PaymentMethod selected;
  final ValueChanged<PaymentMethod> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final text = Theme.of(context).textTheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Semantics(header: true, child: Text(l.payWith, style: text.titleSmall)),
      const SizedBox(height: 8),
      SegmentedButton<PaymentMethod>(
        showSelectedIcon: false,
        segments: [
          ButtonSegment(value: PaymentMethod.googlePlay, icon: const Icon(Icons.shop_rounded), label: Text(l.payGooglePlay)),
          ButtonSegment(value: PaymentMethod.razorpay, icon: const Icon(Icons.account_balance_wallet_rounded), label: Text(l.payRazorpay, maxLines: 2)),
        ],
        selected: {selected},
        onSelectionChanged: enabled ? (s) => onChanged(s.first) : null,
      ),
      AnimatedSize(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.topCenter,
        child: selected == PaymentMethod.razorpay
            ? Padding(padding: const EdgeInsets.only(top: 8), child: Text(l.payRazorpayNote, style: text.bodySmall))
            : const SizedBox(width: double.infinity),
      ),
    ]);
  }
}
