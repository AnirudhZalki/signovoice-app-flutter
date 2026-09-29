import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/notifications/presentation/notification_providers.dart';
import 'features/profile/domain/user_preferences.dart';
import 'features/subscription/presentation/purchase_flow_controller.dart';
import 'features/profile/presentation/preferences_controller.dart';
import 'l10n/app_localizations.dart';
import 'shared/widgets/state_widgets.dart';

class SignoVoiceApp extends ConsumerWidget {
  const SignoVoiceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(preferencesProvider);
    final router = ref.watch(routerProvider);
    ref.watch(purchaseListenerProvider); // receive store purchases for the whole session
    ref.watch(notificationSyncProvider); // keep local reminders in step with settings/plan
    ref.watch(pushSyncProvider); // push registration when signed in

    return MaterialApp.router(
      title: 'SignoVoice',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: AppTheme.light(highContrast: prefs.highContrast, reduceMotion: prefs.reduceMotion),
      darkTheme: AppTheme.dark(highContrast: prefs.highContrast, reduceMotion: prefs.reduceMotion),
      themeMode: switch (prefs.themeMode) {
        AppThemeMode.system => ThemeMode.system,
        AppThemeMode.light => ThemeMode.light,
        AppThemeMode.dark => ThemeMode.dark,
      },
      locale: prefs.localeCode == null ? null : Locale(prefs.localeCode!),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        // In-app text size multiplies the system font scale (both respected).
        final scaler = TextScaler.linear((mq.textScaler.scale(1.0) * prefs.textScale).clamp(0.8, 2.4));
        return MediaQuery(
          data: mq.copyWith(
            textScaler: scaler,
            disableAnimations: mq.disableAnimations || prefs.reduceMotion,
            highContrast: mq.highContrast || prefs.highContrast,
          ),
          child: Column(
            children: [
              const SafeArea(bottom: false, child: OfflineBanner()),
              Expanded(child: child ?? const SizedBox.shrink()),
            ],
          ),
        );
      },
    );
  }
}
