import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'app.dart';
import 'core/config/remote_config_client.dart';
import 'core/firebase/firebase_gateway.dart';
import 'core/firebase/firebase_remote_config_client.dart';
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

/// Khóa màn hình dọc (NFR8, AC8.6.1). Android và iOS cũng khóa trong
/// `AndroidManifest.xml` và `Info.plist`.
Future<void> configureSystemUi() {
  return SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);
}

/// Cây widget gốc. Màu theo đá quý lấy trực tiếp từ `GemTheme`, nên không còn
/// Provider theme.
Widget buildRootApp(AppBootstrap bootstrap) {
  return BlockBlastApp(bootstrap: bootstrap);
}
