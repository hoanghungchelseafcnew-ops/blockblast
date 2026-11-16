import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'core/theme/theme_manager.dart';
import 'core/audio/audio_controller.dart';
import 'core/firebase/firebase_gateway.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AudioController.init();
  // Step 1 (CP-1): chỉ khởi tạo Firebase, chưa đụng logic game.
  // Lỗi hoặc quá 1,5s thì chơi offline (BR1.5). AppBootstrap sẽ thay bước này.
  await FirebaseGateway().init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeManager()),
      ],
      child: const BlockBlastApp(),
    ),
  );
}
