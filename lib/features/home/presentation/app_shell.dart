import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/l10n_ext.dart';

/// Bottom-navigation shell (Home · Translate · Learn · Live · Profile).
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final items = <(IconData, IconData, String)>[
      (Icons.home_outlined, Icons.home_rounded, l.navHome),
      (Icons.translate_rounded, Icons.translate_rounded, l.navTranslate),
      (Icons.school_outlined, Icons.school_rounded, l.navLearn),
      (Icons.video_call_outlined, Icons.video_call_rounded, l.navLive),
    ];
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
        destinations: [
          for (final (icon, selected, label) in items)
            NavigationDestination(icon: Icon(icon), selectedIcon: Icon(selected), label: label),
        ],
      ),
    );
  }
}
