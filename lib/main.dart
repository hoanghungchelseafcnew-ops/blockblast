import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/audio/audio_controller.dart';
import 'core/firebase/firebase_gateway.dart';
import 'core/firebase/firebase_remote_config_client.dart';
import 'core/theme/theme_manager.dart';
import 'features/journey/services/app_bootstrap.dart';
import 'features/journey/services/progress_repository.dart';
import 'features/journey/services/progress_store.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AudioController.init();

  // Firebase, Remote Config và tiến trình được khởi động trong Splash, với
  // hạn chót 3,5 giây (WF1, BR1.8). Không có bước nào chặn runApp.
  final bootstrap = AppBootstrap(
    gateway: FirebaseGateway(),
    remoteConfigFactory: () => FirebaseRemoteConfigClient(),
    progress: ProgressRepository(SharedPreferencesProgressStore()),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeManager()),
      ],
      child: BlockBlastApp(bootstrap: bootstrap),
    ),
  );
}
