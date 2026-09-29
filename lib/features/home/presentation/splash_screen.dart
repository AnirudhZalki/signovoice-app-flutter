import 'package:flutter/material.dart';

import '../../../core/utils/l10n_ext.dart';
import '../../../shared/widgets/brand.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      body: Center(
        child: Semantics(
          label: '${l.appName}. ${l.tagline}',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const BrandMark(size: 112),
              const SizedBox(height: 20),
              Text(l.appName, style: Theme.of(context).textTheme.displaySmall),
              const SizedBox(height: 4),
              Text(l.tagline, style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
        ),
      ),
    );
  }
}
