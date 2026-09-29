import 'package:flutter/services.dart';

enum HapticKind { light, selection, success, warning }

class HapticsService {
  HapticsService({this.enabled = true});
  bool enabled;

  Future<void> trigger(HapticKind kind) async {
    if (!enabled) return;
    try {
      switch (kind) {
        case HapticKind.light:
          await HapticFeedback.lightImpact();
        case HapticKind.selection:
          await HapticFeedback.selectionClick();
        case HapticKind.success:
          await HapticFeedback.mediumImpact();
        case HapticKind.warning:
          await HapticFeedback.heavyImpact();
      }
    } catch (_) {}
  }
}
