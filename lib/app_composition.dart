import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'app.dart';
import 'core/config/remote_config_client.dart';
import 'core/firebase/firebase_gateway.dart';
import 'core/firebase/firebase_remote_config_client.dart';
import 'features/ads/models/ads_settings.dart';
import 'features/ads/services/ad_counters.dart';
import 'features/ads/services/ad_mediator.dart';
import 'features/ads/services/admob_adapter.dart';
import 'features/ads/services/applovin_adapter.dart';
import 'features/ads/services/consent_service.dart';
import 'features/ads/services/pending_loss_store.dart';
import 'features/ads/services/unity_adapter.dart';
import 'features/journey/services/app_bootstrap.dart';
import 'features/journey/services/progress_repository.dart';
import 'features/journey/services/progress_store.dart';
import 'features/update/services/app_update_checker.dart';

/// Dựng [AppBootstrap] với các service thật của app.
///
/// Không có I/O lúc dựng: Firebase, Remote Config và tiến trình chỉ được khởi
/// động khi Splash gọi `run()`, trong hạn chót 3,5 giây (WF1, BR1.8). Các
/// tham số chỉ dùng để test thay thế từng phần.
AppBootstrap createAppBootstrap({
  FirebaseGateway? gateway,
  RemoteConfigClient Function()? remoteConfigFactory,
  ProgressStore? progressStore,
  AdsService Function(AdsSettings settings)? adsFactory,
  ProgressStore? pendingLossStore,
}) {
  return AppBootstrap(
    gateway: gateway ?? FirebaseGateway(),
    remoteConfigFactory:
        remoteConfigFactory ?? () => FirebaseRemoteConfigClient(),
    progress: ProgressRepository(
      progressStore ?? SharedPreferencesProgressStore(),
    ),
    adsFactory: adsFactory ?? createAdsService,
    // Dấu lần thua chưa ghi nhận của reward ads (u2-reward-ads, BR6.7).
    pendingLoss: PendingLossStore(
      pendingLossStore ?? SharedPreferencesProgressStore(),
    ),
    // Popup cập nhật (u4-update-and-share). Chỉ đọc phiên bản khi Home gọi.
    updateCheckerFactory: (settings) => AppUpdateChecker(settings: settings),
  );
}

/// Quảng cáo thật (u1-ads-core). Không có I/O lúc dựng: SDK chỉ khởi tạo khi
/// Home gọi `AdsService.start()` (NFR1.1).
AdsService createAdsService(AdsSettings settings) {
  return AdMediator(
    settings: settings,
    counters: AdCounters(SharedPreferencesProgressStore()),
    consent: ConsentService(const PlatformConsentGateway()),
    adapters: [AdmobAdapter(), UnityAdapter(), ApplovinAdapter()],
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
