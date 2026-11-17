import 'package:flutter/material.dart';

import '../../../core/constants/colors.dart';
import '../../home/screens/home_screen.dart';
import '../../journey/services/app_bootstrap.dart';

/// Màn chờ bootstrap tối đa 3,5 giây rồi chuyển sang Home (WF1).
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.bootstrap});

  final AppBootstrap bootstrap;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    final result = await widget.bootstrap.run();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => HomeScreen(services: result.services),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.backgroundStart,
              AppColors.backgroundMiddle,
              AppColors.backgroundEnd,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/icon.png',
                key: const Key('splash-logo'),
                width: 140,
                height: 140,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.extension, size: 96, color: Colors.white),
              ),
              const SizedBox(height: 32),
              const CircularProgressIndicator(
                key: Key('splash-progress'),
                color: AppColors.accent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
