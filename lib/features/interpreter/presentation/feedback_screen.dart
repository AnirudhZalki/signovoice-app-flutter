import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/failure_mapper.dart';
import '../../../core/routing/routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../shared/widgets/buttons.dart';
import '../../../shared/widgets/failure_message.dart';
import 'call_controller.dart';
import 'call_screen.dart';
import 'interpreter_providers.dart';

/// Post-call rating + optional report.
class FeedbackScreen extends ConsumerStatefulWidget {
  const FeedbackScreen({super.key, required this.callId});
  final String callId;

  @override
  ConsumerState<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends ConsumerState<FeedbackScreen> {
  int _rating = 0;
  final _comment = TextEditingController();
  bool _busy = false;
  bool _done = false;
  String? _error;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  void _leave() {
    ref.read(callControllerProvider.notifier).reset();
    context.go(Routes.live);
  }

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(interpreterRepositoryProvider).submitFeedback(callId: widget.callId, rating: _rating, comment: _comment.text);
      if (mounted) setState(() => _done = true);
    } catch (e) {
      if (mounted) setState(() => _error = failureMessageWithReason(context.l10n, toFailure(e)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final elapsed = ref.read(callControllerProvider).elapsed;
    return Scaffold(
      appBar: AppBar(title: Text(l.callEnded), automaticallyImplyLeading: false),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(l.callDuration(formatDuration(elapsed)), style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            if (_done) ...[
              Icon(Icons.check_circle_outline_rounded, size: 64, color: scheme.secondary),
              const SizedBox(height: 12),
              Text(l.feedbackThanks, style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              PrimaryButton(label: l.done, onPressed: _leave),
            ] else ...[
              Text(l.feedbackTitle, style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                for (var i = 1; i <= 5; i++)
                  Semantics(
                    button: true,
                    selected: _rating == i,
                    label: l.feedbackStars('$i'),
                    excludeSemantics: true,
                    child: IconButton(
                      iconSize: 40,
                      constraints: const BoxConstraints(minWidth: 52, minHeight: 52),
                      onPressed: () => setState(() => _rating = i),
                      icon: Icon(i <= _rating ? Icons.star_rounded : Icons.star_outline_rounded, color: i <= _rating ? scheme.primary : scheme.onSurfaceVariant),
                    ),
                  ),
              ]),
              if (_rating > 0) Text(l.feedbackStars('$_rating'), textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 16),
              TextField(controller: _comment, maxLines: 3, maxLength: 500, decoration: InputDecoration(labelText: l.feedbackComment)),
              if (_error != null)
                Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [
                  Icon(Icons.error_outline, color: scheme.error),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_error!, style: TextStyle(color: scheme.error))),
                ])),
              PrimaryButton(label: l.submitFeedback, loading: _busy, onPressed: _rating == 0 ? null : _submit),
              const SizedBox(height: 8),
              TextButton.icon(
                icon: const Icon(Icons.flag_outlined),
                label: Text(l.reportIssue),
                onPressed: () => showModalBottomSheet<void>(context: context, isScrollControlled: true, builder: (_) => ReportIssueSheet(callId: widget.callId)),
              ),
              TextButton(onPressed: _leave, child: Text(l.skipFeedback)),
            ],
          ]),
        ),
      ),
    );
  }
}
