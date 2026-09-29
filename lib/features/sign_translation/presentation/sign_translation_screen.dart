import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers.dart';
import '../../../core/routing/routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../shared/camera/camera_preview_frame.dart';
import '../../../shared/camera/camera_session.dart';
import '../../../shared/widgets/buttons.dart';
import '../../../shared/widgets/camera_overlay.dart';
import '../../../shared/widgets/misc_widgets.dart';
import '../../../shared/widgets/record_buttons.dart';
import '../../../shared/widgets/state_widgets.dart';
import '../../../shared/widgets/status_widgets.dart';
import '../../profile/presentation/preferences_controller.dart';
import '../../subscription/presentation/widgets/premium_card.dart';
import '../domain/recognition_engine.dart';
import 'sign_translation_controller.dart';
import 'widgets/translation_panel.dart';
import 'widgets/voice_settings_sheet.dart';

/// Shared by Sign → Text and Sign → Voice (the latter speaks every accepted sign).
class SignTranslationScreen extends ConsumerStatefulWidget {
  const SignTranslationScreen({super.key, required this.mode});
  final SignMode mode;

  @override
  ConsumerState<SignTranslationScreen> createState() =>
      _SignTranslationScreenState();
}

class _SignTranslationScreenState extends ConsumerState<SignTranslationScreen>
    with WidgetsBindingObserver {
  late final CameraSession _camera;
  late final SignTranslationController _controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = ref.read(signTranslationProvider.notifier);
    _camera = CameraSession(
      permissions: ref.read(permissionServiceProvider),
      onImage: _controller.onCameraImage,
    )..addListener(_onCameraChange);
    _camera.start();
  }

  void _onCameraChange() {
    if (_camera.status == CameraStatus.ready) _controller.start(widget.mode);
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
      ..removeListener(_onCameraChange)
      ..disposeSession();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final s = ref.watch(signTranslationProvider);
    final prefs = ref.watch(preferencesProvider);
    final title = widget.mode == SignMode.signToVoice
        ? l.modeSignToVoice
        : l.modeSignToText;

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) _controller.finish();
      },
      child: Semantics(
        scopesRoute: true,
        explicitChildNodes: true,
        namesRoute: true,
        label: title,
        child: Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, c) {
                return Column(
                  children: [
                    Expanded(child: _cameraArea(context, s, title)),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: c.maxHeight * 0.58,
                      ),
                      child: Material(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(AppSpacing.radiusLg),
                        ),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                          child: _panel(context, s, prefs.confidenceThreshold),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // ---- camera area ----
  Widget _cameraArea(
    BuildContext context,
    SignTranslationState s,
    String title,
  ) {
    final l = context.l10n;
    Widget body;
    switch (_camera.status) {
      case CameraStatus.checkingPermission:
      case CameraStatus.initializing:
        body = const LoadingState();
      case CameraStatus.needsPermission:
      case CameraStatus.permanentlyDenied:
        body = ColoredBox(
          color: Theme.of(context).colorScheme.surface,
          child: PermissionCard(
            icon: Icons.photo_camera_outlined,
            title: l.cameraPermTitle,
            explanation: l.cameraPermBody,
            permanentlyDenied: _camera.status == CameraStatus.permanentlyDenied,
            onGrant: _camera.requestPermission,
            onOpenSettings: _camera.openSettings,
          ),
        );
      case CameraStatus.error:
        body = ColoredBox(
          color: Theme.of(context).colorScheme.surface,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.videocam_off_outlined, size: 56),
                  const SizedBox(height: 12),
                  Text(l.cameraInitError, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    label: l.retry,
                    expanded: false,
                    onPressed: _camera.start,
                  ),
                ],
              ),
            ),
          ),
        );
      case CameraStatus.ready:
        final c = _camera.controller!;
        body = Semantics(
          label:
              '${l.navTranslate}. ${s.handVisible ? l.handDetected : l.showHandHint}',
          child: Stack(
            fit: StackFit.expand,
            children: [
              CameraPreviewFrame(
                controller: c,
                children: [
                  Positioned.fill(
                    child: CameraOverlay(
                      overlay: _controller.source?.overlay,
                      scanning: s.ready && !s.handVisible && !s.paused,
                      mirror: _camera.isFront,
                    ),
                  ),
                ],
              ),
              if (s.failure != null)
                ColoredBox(
                  color: Theme.of(context).colorScheme.surface
                      .withValues(alpha: 0.94),
                  child: ErrorState(
                    failure: s.failure!,
                    onRetry: _controller.retry,
                  ),
                ),
              if (s.ready && !s.handVisible && !s.paused)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: _HintPill(
                      icon: Icons.back_hand_outlined,
                      text: l.showHandHint,
                    ),
                  ),
                ),
            ],
          ),
        );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        body,
        Positioned(
          top: 8,
          left: 8,
          right: 8,
          child: _topBar(context, s, title),
        ),
      ],
    );
  }

  Widget _topBar(BuildContext context, SignTranslationState s, String title) {
    final l = context.l10n;
    final (label, tone, icon) = switch (s.engineStatus) {
      EngineStatus.ready when s.requiresInternet => (
        l.signStatusOnline,
        StatusTone.info,
        Icons.cloud_done_outlined,
      ),
      EngineStatus.ready => (
        l.signStatusReady,
        StatusTone.success,
        Icons.memory_rounded,
      ),
      EngineStatus.unavailable => (
        l.signStatusUnavailable,
        StatusTone.error,
        Icons.error_outline,
      ),
      _ => (l.signStatusLoading, StatusTone.info, Icons.hourglass_top_rounded),
    };
    return Row(
      children: [
        _RoundIconButton(
          icon: Icons.arrow_back_rounded,
          tooltip: l.back,
          onPressed: () => context.pop(),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(999),
            ),
            padding: const EdgeInsets.all(2),
            child: StatusBadge(label: label, tone: tone, icon: icon),
          ),
        ),
        const Spacer(),
        if (_camera.canFlash)
          _RoundIconButton(
            icon: _camera.flashOn
                ? Icons.flash_on_rounded
                : Icons.flash_off_rounded,
            tooltip: _camera.flashOn ? l.flashOff : l.flashOn,
            onPressed: _camera.toggleFlash,
          ),
        const SizedBox(width: 8),
        _RoundIconButton(
          icon: Icons.flip_camera_android_rounded,
          tooltip: l.flipCamera,
          onPressed: _camera.flip,
        ),
        const SizedBox(width: 8),
        _RoundIconButton(
          icon: Icons.history_rounded,
          tooltip: l.historyTitle,
          onPressed: () => context.push(Routes.history),
        ),
      ],
    );
  }

  // ---- bottom panel ----
  Widget _panel(
    BuildContext context,
    SignTranslationState s,
    double threshold,
  ) {
    final l = context.l10n;
    final canSave = s.glosses.isNotEmpty && !s.saved;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (s.requiresInternet)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                const Icon(Icons.wifi_rounded, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l.internetRequired,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        if (s.limitReached)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: PremiumCard(
              title: l.limitReachedTitle,
              body: l.limitReachedBody,
            ),
          )
        else if (s.signsRemaining >= 0 && s.signsRemaining <= 20)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: StatusBadge(
              label: l.signsLeftToday('${s.signsRemaining}'),
              tone: StatusTone.warning,
            ),
          ),
        TranslationCard(
          state: s,
          threshold: threshold,
          onLanguage: _controller.setLanguage,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _LabeledAction(
              icon: Icons.delete_outline_rounded,
              label: l.clear,
              onPressed: s.glosses.isEmpty ? null : _controller.clear,
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RecordingButton(
                  active: !s.paused,
                  activeLabel: l.pause,
                  inactiveLabel: l.resume,
                  onPressed: s.ready && !(s.limitReached && s.paused)
                      ? _controller.togglePause
                      : null,
                ),
                const SizedBox(height: 4),
                Text(
                  s.paused ? l.resume : l.pause,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
            _LabeledAction(
              icon: s.speaking ? Icons.stop_rounded : Icons.volume_up_rounded,
              label: s.speaking ? l.stopSpeaking : l.speak,
              onPressed: s.sentence.isEmpty
                  ? null
                  : (s.speaking ? _controller.stopSpeaking : _controller.speak),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 4,
          children: [
            TextButton.icon(
              onPressed: s.sentence.isEmpty
                  ? null
                  : () => copyText(context, s.sentence),
              icon: const Icon(Icons.copy_rounded),
              label: Text(l.copy),
            ),
            TextButton.icon(
              onPressed: s.sentence.isEmpty
                  ? null
                  : () => shareText(s.sentence),
              icon: const Icon(Icons.share_rounded),
              label: Text(l.share),
            ),
            TextButton.icon(
              onPressed: canSave
                  ? () async {
                      final saved = await _controller.saveToHistory();
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            content: Text(
                              saved ? l.savedToHistory : l.historyOffHint,
                            ),
                          ),
                        );
                    }
                  : null,
              icon: Icon(
                s.saved ? Icons.check_rounded : Icons.bookmark_add_outlined,
              ),
              label: Text(s.saved ? l.savedToHistory : l.saveToHistory),
            ),
            if (widget.mode == SignMode.signToVoice)
              TextButton.icon(
                onPressed: () => showVoiceSettingsSheet(context),
                icon: const Icon(Icons.tune_rounded),
                label: Text(l.voiceSettings),
              ),
          ],
        ),
      ],
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => IconButton.filled(
    onPressed: onPressed,
    tooltip: tooltip,
    icon: Icon(icon),
    style: IconButton.styleFrom(
      backgroundColor: Colors.black.withValues(alpha: 0.6),
      foregroundColor: Colors.white,
    ),
  );
}

class _HintPill extends StatelessWidget {
  const _HintPill({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.black.withValues(alpha: 0.65),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 18),
        const SizedBox(width: 8),
        Flexible(
          child: Text(text, style: const TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}

class _LabeledAction extends StatelessWidget {
  const _LabeledAction({
    required this.icon,
    required this.label,
    required this.onPressed,
  });
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      IconButton.filledTonal(
        onPressed: onPressed,
        tooltip: label,
        icon: Icon(icon, size: 28),
        style: IconButton.styleFrom(minimumSize: const Size(60, 60)),
      ),
      const SizedBox(height: 4),
      Text(label, style: Theme.of(context).textTheme.labelMedium),
    ],
  );
}
