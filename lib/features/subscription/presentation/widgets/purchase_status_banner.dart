import 'package:flutter/material.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../shared/widgets/failure_message.dart';
import '../../domain/payment_method.dart';
import '../purchase_flow_controller.dart';

/// Text + icon explanation of the current purchase state, with retry where useful.
class PurchaseStatusBanner extends StatelessWidget {
  const PurchaseStatusBanner({super.key, required this.state, this.onRetryVerification, this.onRetryLoad, this.method = PaymentMethod.googlePlay});
  final PaymentMethod method;
  final PurchaseFlowState state;
  final VoidCallback? onRetryVerification;
  final VoidCallback? onRetryLoad;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    String? msg;
    IconData icon = Icons.info_outline;
    var error = false;
    VoidCallback? retry;

    switch (state.stage) {
      case PurchaseStage.pending:
        msg = l.purchasePending;
        icon = Icons.schedule_rounded;
      case PurchaseStage.verifying:
        msg = l.purchaseVerifying;
        icon = Icons.verified_user_outlined;
      case PurchaseStage.success:
        msg = l.purchaseSuccess;
        icon = Icons.check_circle_outline_rounded;
      case PurchaseStage.cancelled:
        msg = l.purchaseCancelled;
        icon = Icons.cancel_outlined;
      case PurchaseStage.billingUnavailable:
        msg = method == PaymentMethod.razorpay ? l.razorpayUnavailableMsg : l.billingUnavailableMsg;
        icon = Icons.shopping_bag_outlined;
        error = true;
      case PurchaseStage.productsUnavailable:
        msg = method == PaymentMethod.razorpay ? l.razorpayPlansUnavailableMsg : l.productsUnavailableMsg;
        icon = Icons.inventory_2_outlined;
        error = true;
        retry = onRetryLoad;
      case PurchaseStage.restoreNothing:
        msg = l.restoreNone;
      case PurchaseStage.failed:
        error = true;
        icon = Icons.error_outline;
        if (state.needsVerification) {
          msg = state.failure?.type == FailureType.notConfigured ? '${l.purchaseNeedsVerification}\n${l.failureNotConfigured}' : l.purchaseNeedsVerification;
          retry = onRetryVerification;
        } else {
          msg = failureMessage(l, state.failure ?? const Failure(FailureType.unknown));
        }
      default:
        break;
    }
    if (msg == null) return const SizedBox.shrink();

    return Semantics(
      liveRegion: true,
      container: true,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: error ? scheme.errorContainer : scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: error ? scheme.onErrorContainer : scheme.onSurface),
          const SizedBox(width: 10),
          Expanded(child: Text(msg, style: TextStyle(color: error ? scheme.onErrorContainer : scheme.onSurface))),
          if (retry != null) TextButton(onPressed: retry, child: Text(l.retry)),
        ]),
      ),
    );
  }
}
