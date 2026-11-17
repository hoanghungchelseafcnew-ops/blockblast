import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/config/remote_config_client.dart';
import 'core/firebase/firebase_gateway.dart';
import 'core/firebase/firebase_remote_config_client.dart';
import 'core/theme/theme_manager.dart';
import 'features/journey/services/app_bootstrap.dart';
import 'features/journey/services/progress_repository.dart';
import 'features/journey/services/progress_store.dart';

/// Dựng [AppBootstrap] với các service thật của app.
///
/// Không có I/O lúc dựng: Firebase, Remote Config và tiến trình chỉ được khởi
/// động khi Splash gọi `run()`, trong hạn chót 3,5 giây (WF1, BR1.8). Các
/// tham số chỉ dùng để test thay thế từng phần.
AppBootstrap createAppBootstrap({
  FirebaseGateway? gateway,
  RemoteConfigClient Function()? remoteConfigFactory,
  ProgressStore? progressStore,
}) {
  return AppBootstrap(
    gateway: gateway ?? FirebaseGateway(),
    remoteConfigFactory:
        remoteConfigFactory ?? () => FirebaseRemoteConfigClient(),
    progress: ProgressRepository(
      progressStore ?? SharedPreferencesProgressStore(),
    ),
  );
}

/// Cây widget gốc: Provider của theme bọc [BlockBlastApp].
Widget buildRootApp(AppBootstrap bootstrap) {
  return MultiProvider(
    providers: [ChangeNotifierProvider(create: (_) => ThemeManager())],
    child: BlockBlastApp(bootstrap: bootstrap),
  );
}
