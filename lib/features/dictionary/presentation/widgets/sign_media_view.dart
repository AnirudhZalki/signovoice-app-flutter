import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../profile/presentation/preferences_controller.dart';
import '../../domain/sign_dictionary.dart';

/// Plays a sign's clip (bundled asset or https URL). If the sign has no media
/// it says so plainly — nothing is faked.
class SignMediaView extends ConsumerStatefulWidget {
  const SignMediaView({super.key, required this.entry, this.compact = false});
  final SignEntry entry;
  final bool compact;

  @override
  ConsumerState<SignMediaView> createState() => _SignMediaViewState();
}

class _SignMediaViewState extends ConsumerState<SignMediaView> {
  VideoPlayerController? _c;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void didUpdateWidget(covariant SignMediaView old) {
    super.didUpdateWidget(old);
    if (old.entry.videoPath != widget.entry.videoPath) {
      _dispose();
      _init();
    }
  }

  Future<void> _init() async {
    final path = widget.entry.videoPath;
    if (path == null) return;
    final c = path.startsWith('http') ? VideoPlayerController.networkUrl(Uri.parse(path)) : VideoPlayerController.asset(path);
    _c = c;
    try {
      await c.initialize();
      await c.setLooping(true);
      await c.setVolume(0);
      // Reduced-motion users get a paused clip they start themselves.
      final reduce = ref.read(preferencesProvider).reduceMotion;
      if (mounted && !reduce) await c.play();
      if (mounted) setState(() {});
    } catch (_) {
      if (mounted) setState(() => _error = true);
    }
  }

  void _dispose() {
    _c?.dispose();
    _c = null;
    _error = false;
  }

  @override
  void dispose() {
    _dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(AppSpacing.radiusMd);

    if (widget.entry.videoPath == null) {
      return Semantics(
        label: '${l.signVideoUnavailable}. ${l.signVideoUnavailableBody}',
        child: Container(
          decoration: BoxDecoration(color: scheme.surfaceContainerHigh, borderRadius: radius, border: Border.all(color: scheme.outlineVariant)),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: widget.compact
              ? Row(children: [
                  Icon(Icons.videocam_off_outlined, color: scheme.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Expanded(child: Text(l.signVideoUnavailable, style: Theme.of(context).textTheme.bodySmall)),
                ])
              : Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.videocam_off_outlined, size: 40, color: scheme.onSurfaceVariant),
                  const SizedBox(height: 8),
                  Text(l.signVideoUnavailable, style: Theme.of(context).textTheme.titleSmall, textAlign: TextAlign.center),
                  const SizedBox(height: 4),
                  Text(l.signVideoUnavailableBody, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
                ]),
        ),
      );
    }

    final c = _c;
    if (_error) {
      return Container(
        decoration: BoxDecoration(color: scheme.errorContainer, borderRadius: radius),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(children: [
          Icon(Icons.error_outline, color: scheme.onErrorContainer),
          const SizedBox(width: 8),
          Expanded(child: Text(l.videoError, style: TextStyle(color: scheme.onErrorContainer))),
        ]),
      );
    }
    if (c == null || !c.value.isInitialized) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: DecoratedBox(
          decoration: BoxDecoration(color: scheme.surfaceContainerHigh, borderRadius: radius),
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }
    final playing = c.value.isPlaying;
    return Semantics(
      label: widget.entry.word,
      child: ClipRRect(
        borderRadius: radius,
        child: AspectRatio(
          aspectRatio: c.value.aspectRatio,
          child: Stack(alignment: Alignment.center, children: [
            VideoPlayer(c),
            Positioned(
              right: 8,
              bottom: 8,
              child: IconButton.filled(
                tooltip: playing ? l.pauseVideo : l.playVideo,
                style: IconButton.styleFrom(backgroundColor: Colors.black.withValues(alpha: 0.6), foregroundColor: Colors.white),
                icon: Icon(playing ? Icons.pause_rounded : Icons.play_arrow_rounded),
                onPressed: () async {
                  playing ? await c.pause() : await c.play();
                  if (mounted) setState(() {});
                },
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
