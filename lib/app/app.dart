import 'package:flutter/material.dart';

import 'router.dart';
import 'theme.dart';

/// Root widget for Gurukula AI.
///
/// Wires the Material 3 light/dark themes and the go_router configuration.
class GurukulaApp extends StatelessWidget {
  const GurukulaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Gurukula AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      // Follow the device setting; users can override this in Profile later.
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
    );
  }
}
