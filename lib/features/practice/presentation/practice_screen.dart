import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/failure_mapper.dart';
import '../../../core/providers.dart';
import '../../../core/routing/routes.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../shared/camera/camera_preview_frame.dart';
import '../../../shared/camera/camera_session.dart';
import '../../../shared/widgets/buttons.dart';
import '../../../shared/widgets/camera_overlay.dart';
import '../../../shared/widgets/misc_widgets.dart';
import '../../../shared/widgets/state_widgets.dart';
import '../../../shared/widgets/status_widgets.dart';
import '../../dictionary/domain/sign_dictionary.dart';
import '../../dictionary/presentation/dictionary_providers.dart';
import '../../dictionary/presentation/widgets/sign_media_view.dart';
import '../../profile/presentation/preferences_controller.dart';
import '../domain/practice_evaluator.dart';
import 'practice_controller.dart';

class PracticeScreen extends ConsumerWidget {
  const PracticeScreen({super.key, required this.signId});
  final String signId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    return ref.watch(dictionaryProvider).when(
          loading: () => const Scaffold(body: LoadingState()),
          error: (e, _) => Scaffold(appBar: AppBar(), body: ErrorState(failure: toFailure(e), onRetry: () => ref.invalidate(dictionaryProvider))),
          data: (dict) {
            final entry = dict.byId[signId];
            if (entry == null || !entry.isPracticeable) {
              return Scaffold(appBar: AppBar(), body: EmptyState(icon: Icons.search_off_rounded, title: l.entryNotFound));
            }
            return _PracticeView(entry: entry, dict: dict);
          },
        );
  }
}

class _PracticeView extends ConsumerStatefulWidget {
  const _PracticeView({required this.entry, required this.dict});
  final SignEntry entry;
  final SignDictionary dict;

  @override
  ConsumerState<_PracticeView> createState() => _PracticeViewState();
}

class _PracticeViewState extends ConsumerState<_PracticeView> with WidgetsBindingObserver {
  late final CameraSession _camera;
  late final PracticeController _controller;
  bool _showReference = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = ref.read(practiceProvider.notifier);
    _camera = CameraSession(permissions: ref.read(permissionServiceProvider), onImage: _controller.onCameraImage)..addListener(_onCamera);
    _camera.start();
  }

  void _onCamera() {
    if (_camera.status == CameraStatus.ready) {
      _controller.start(signId: widget.entry.id, label: widget.entry.practiceLabel!);
    }
    if (mounted) setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState s) {
    if (s == AppLifecycleState.inactive || s == AppLifecycleState.paused) {
      _camera.pause();
    } else if (s == AppLifecycleState.resumed) {
      _camera.resume();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _camera
      ..removeListener(_onCamera)
      ..disposeSession();
    super.dispose();
  }

  SignEntry? _nextSign() {
    final signs = widget.dict.entries.where((e) => e.isPracticeable).toList();
    final i = signs.indexWhere((e) => e.id == widget.entry.id);
    return signs.isEmpty ? null : signs[(i + 1) % signs.length];
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final s = ref.watch(practiceProvider);
    final scheme = Theme.of(context).colorScheme;
    final threshold = ref.watch(preferencesProvider).confidenceThreshold;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: Stack(fit: StackFit.expand, children: [
              _camera.status == CameraStatus.ready
                  ? CameraPreviewFrame(controller: _camera.controller!, children: [
                      Positioned.fill(
                        child: CameraOverlay(
                          overlay: _controller.source?.overlay,
                          scanning: s.phase == PracticePhase.idle && !s.handVisible,
                          mirror: _camera.isFront,
                        ),
                      ),
                    ])
                  : ColoredBox(color: scheme.surface, child: _cameraFallback(context)),
              if (s.phase == PracticePhase.countdown)
                _BigLabel(text: '${s.countdown}', caption: l.getReady),
              if (s.phase == PracticePhase.capturing)
                _BigLabel(text: l.signNow, caption: null, progress: s.captureProgress),
              if (s.phase == PracticePhase.error && s.failure != null)
                ColoredBox(color: scheme.surface, child: ErrorState(failure: s.failure!, onRetry: _controller.retryEngine)),
              Positioned(
                top: 8,
                left: 8,
                child: IconButton.filled(
                  tooltip: l.back,
                  onPressed: () => context.pop(),
                  style: IconButton.styleFrom(backgroundColor: Colors.black.withValues(alpha: 0.6), foregroundColor: Colors.white),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton.filled(
                  tooltip: l.flipCamera,
                  onPressed: _camera.flip,
                  style: IconButton.styleFrom(backgroundColor: Colors.black.withValues(alpha: 0.6), foregroundColor: Colors.white),
                  icon: const Icon(Icons.flip_camera_android_rounded),
                ),
              ),
            ]),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.5),
            child: Material(
              color: scheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _panel(context, s, threshold),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _cameraFallback(BuildContext context) {
    final l = context.l10n;
    switch (_camera.status) {
      case CameraStatus.needsPermission:
      case CameraStatus.permanentlyDenied:
        return PermissionCard(
          icon: Icons.photo_camera_outlined,
          title: l.cameraPermTitle,
          explanation: l.cameraPermBody,
          permanentlyDenied: _camera.status == CameraStatus.permanentlyDenied,
          onGrant: _camera.requestPermission,
          onOpenSettings: _camera.openSettings,
        );
      case CameraStatus.error:
        return Center(
            child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(l.cameraInitError, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  PrimaryButton(label: l.retry, expanded: false, onPressed: _camera.start),
                ])));
      default:
        return const LoadingState();
    }
  }

  Widget _panel(BuildContext context, PracticeState s, double threshold) {
    final l = context.l10n;
    final text = Theme.of(context).textTheme;
    final e = widget.entry;
    final r = s.result;

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Semantics(header: true, liveRegion: true, child: Text(l.practicePrompt(e.word), style: text.headlineSmall)),
      const SizedBox(height: 8),
      if (e.hasMedia)
        TextButton.icon(
          onPressed: () => setState(() => _showReference = !_showReference),
          icon: Icon(_showReference ? Icons.expand_less_rounded : Icons.play_circle_outline_rounded),
          label: Text(l.watchReference),
        ),
      if (_showReference) ...[SignMediaView(entry: e), const SizedBox(height: 12)],
      if (r != null) ...[
        _ResultCard(result: r, xp: s.xpEarned, threshold: threshold),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: SecondaryButton(label: l.resultTryAgain, icon: Icons.refresh_rounded, onPressed: _controller.begin)),
          const SizedBox(width: 12),
          Expanded(
            child: PrimaryButton(
              label: l.nextSign,
              icon: Icons.arrow_forward_rounded,
              onPressed: () {
                final n = _nextSign();
                if (n != null) context.pushReplacement(Routes.practice(n.id));
              },
            ),
          ),
        ]),
      ] else
        PrimaryButton(
          label: l.startPractice,
          icon: Icons.play_arrow_rounded,
          onPressed: s.phase == PracticePhase.idle ? _controller.begin : null,
          loading: s.phase == PracticePhase.loading,
        ),
    ]);
  }
}

class _BigLabel extends StatelessWidget {
  const _BigLabel({required this.text, this.caption, this.progress});
  final String text;
  final String? caption;
  final double? progress;

  @override
  Widget build(BuildContext context) => Center(
        child: Semantics(
          liveRegion: true,
          label: caption == null ? text : '$caption $text',
          child: ExcludeSemantics(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
              decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.65), borderRadius: BorderRadius.circular(24)),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                if (caption != null) Text(caption!, style: const TextStyle(color: Colors.white, fontSize: 18)),
                Text(text, style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w700)),
                if (progress != null) ...[
                  const SizedBox(height: 10),
                  SizedBox(width: 160, child: LinearProgressIndicator(value: progress, minHeight: 8)),
                ],
              ]),
            ),
          ),
        ),
      );
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result, required this.xp, required this.threshold});
  final PracticeResult result;
  final int xp;
  final double threshold;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final text = Theme.of(context).textTheme;
    final tone = result.correct ? StatusTone.success : StatusTone.warning;
    return Semantics(
      liveRegion: true,
      container: true,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        StatusBadge(
          label: result.correct ? l.resultCorrect : l.resultTryAgain,
          tone: tone,
          icon: result.correct ? Icons.check_circle_outline : Icons.refresh_rounded,
        ),
        const SizedBox(height: 10),
        if (result.noHand)
          Text(l.resultNoHand, style: text.bodyMedium)
        else ...[
          Row(children: [
            Text('${l.recognisedLabel}: ', style: text.labelLarge),
            Text(result.recognized ?? '-', style: text.titleLarge),
          ]),
          const SizedBox(height: 8),
          ConfidenceIndicator(confidence: result.confidence, threshold: threshold),
        ],
        if (xp > 0) ...[
          const SizedBox(height: 8),
          Text(l.xpEarned('$xp'), style: text.labelLarge),
        ],
      ]),
    );
  }
}
