import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/journey/services/app_bootstrap.dart';
import 'features/splash/screens/splash_screen.dart';

class BlockBlastApp extends StatelessWidget {
  const BlockBlastApp({super.key, required this.bootstrap});

  /// Khởi động app; Splash chờ kết quả rồi chuyển sang Home (WF1).
  final AppBootstrap bootstrap;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Block Crush',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: SplashScreen(bootstrap: bootstrap),
    );
  }
}
