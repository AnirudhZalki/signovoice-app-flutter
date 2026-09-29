import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../domain/learning_progress.dart';

String badgeName(AppLocalizations l, LearningBadge b) => switch (b) {
      LearningBadge.firstSign => l.badgeFirstSign,
      LearningBadge.tenSigns => l.badgeTenSigns,
      LearningBadge.firstCorrect => l.badgeFirstCorrect,
      LearningBadge.tenCorrect => l.badgeTenCorrect,
      LearningBadge.streak3 => l.badgeStreak3,
      LearningBadge.streak7 => l.badgeStreak7,
    };

IconData badgeIcon(LearningBadge b) => switch (b) {
      LearningBadge.firstSign => Icons.looks_one_rounded,
      LearningBadge.tenSigns => Icons.filter_9_plus_rounded,
      LearningBadge.firstCorrect => Icons.check_circle_rounded,
      LearningBadge.tenCorrect => Icons.verified_rounded,
      LearningBadge.streak3 => Icons.local_fire_department_outlined,
      LearningBadge.streak7 => Icons.local_fire_department_rounded,
    };
