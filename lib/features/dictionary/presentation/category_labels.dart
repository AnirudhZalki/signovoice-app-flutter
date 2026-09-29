import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

/// Localised topic names; unknown (remote-added) categories fall back to a
/// readable form of their id.
String categoryName(AppLocalizations l, String id) => switch (id) {
      'alphabet' => l.catAlphabet,
      'numbers' => l.catNumbers,
      'greetings' => l.catGreetings,
      'daily' => l.catDaily,
      'family' => l.catFamily,
      'food' => l.catFood,
      'education' => l.catEducation,
      'healthcare' => l.catHealthcare,
      'travel' => l.catTravel,
      'emergency' => l.catEmergency,
      'workplace' => l.catWorkplace,
      'phrases' => l.catPhrases,
      _ => id.isEmpty ? id : '${id[0].toUpperCase()}${id.substring(1).replaceAll('_', ' ')}',
    };

IconData categoryIcon(String key) => switch (key) {
      'abc' => Icons.abc_rounded,
      'pin' => Icons.pin_outlined,
      'waving_hand' => Icons.waving_hand_outlined,
      'chat' => Icons.chat_bubble_outline_rounded,
      'family' => Icons.family_restroom_rounded,
      'restaurant' => Icons.restaurant_rounded,
      'school' => Icons.school_outlined,
      'local_hospital' => Icons.local_hospital_outlined,
      'directions_bus' => Icons.directions_bus_outlined,
      'emergency' => Icons.emergency_outlined,
      'work' => Icons.work_outline_rounded,
      'forum' => Icons.forum_outlined,
      _ => Icons.category_outlined,
    };
