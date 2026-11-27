## Developer Code Scan Results

Lần quét tập trung (focused scan) cho intent 261125-ads-remote-config. Người quét: conductor, tự thực hiện vì các agent được giao việc không có công cụ đọc và ghi file trong phiên này (bạn đã chọn cách này).

### Scan Coverage
- **Analyzed deeply**:
  - lib/
  - test/
  - pubspec.yaml
  - android/app/src/main/AndroidManifest.xml
  - android/app/build.gradle.kts
  - ios/Runner/Info.plist
- **Skimmed only**:
  - analysis_options.yaml
  - android/app/src/main/res/
  - ios/Runner/Base.lproj/LaunchScreen.storyboard
  - README.md
  - assets/
  - web/
  - linux/
  - macos/
  - windows/
  - coverage/
  - backup/
  - screenshots/

### Packages Found
- block_blast — Flutter app (một package) — Dart (sdk ^3.9.2) — game xếp khối tên hiển thị "Block Jewel", version 1.0.0+1
- Cấu trúc feature-first: `lib/features/{endless,game,home,journey,splash,victory}`, `lib/core/{analytics,audio,config,constants,firebase,log,theme,utils}`, `lib/shared/widgets`

### Build System
- **Type**: Flutter / Gradle (Android, Kotlin DSL) / Xcode (iOS)
- **Config Files**: pubspec.yaml, android/app/build.gradle.kts, ios/Runner/Info.plist, analysis_options.yaml
- **Build Dependencies**: Android `namespace` và `applicationId` là `com.h2.game.block_blast`, `minSdk` và `targetSdk` lấy từ Flutter, iOS deployment target 13.0

### APIs Discovered
- Remote Config — `lib/core/config/remote_config_client.dart` — khóa duy nhất `level_config` (JSON), cổng `RemoteConfigClient` với `configure`, `fetchAndActivate`, `readLevelConfig`
- Firebase Analytics — `lib/core/analytics/analytics_service.dart` — 5 phương thức: `logLevelStart`, `logLevelComplete`, `logLevelFail`, `logGameSession`, `setConfigSource` (cộng thuộc tính tiến độ)
- Chia sẻ — `lib/features/game/services/score_share_service.dart` — chụp ảnh màn hình rồi `Share.shareXFiles`, văn bản "I scored $score in Block Jewel!" và "I cleared $levelName with $score points in Block Jewel!"
- Chưa có API quảng cáo nào

### Frameworks & Libraries
- flutter, provider ^6.1.2 — state qua ChangeNotifier
- firebase_core ^3.15.0, firebase_remote_config ^5.4.0, firebase_analytics ^11.6.0
- shared_preferences ^2.2.3 — lưu tiến trình
- share_plus ^10.1.3, screenshot ^3.0.0, path_provider ^2.1.5 — chia sẻ ảnh
- audioplayers ^6.0.0, flutter_animate ^4.5.0, google_fonts ^6.2.1, cached_network_image ^3.4.1
- Không có thư viện quảng cáo (google_mobile_ads, Unity, AppLovin) trong `pubspec.yaml`

### Test Coverage
- **Test Directories**: test/ (core, features, shared, ui, simulation, fakes)
- **Test Frameworks**: flutter_test, khoảng 508 ca kiểm thử (đếm `test(` và `testWidgets`)
- **Coverage Config**: có thư mục `coverage/` với `lcov.info`, chưa thấy ngưỡng được cấu hình trong repo

### Code Quality Indicators
- **Linting**: flutter_lints ^5.0.0, `analysis_options.yaml` loại trừ build, android, ios, web, windows, macos, linux
- **CI/CD**: không có (không có thư mục `.github`), phù hợp quy ước nhóm build và upload thủ công
- **Documentation**: nhiều chú thích `///` bằng tiếng Việt, có tham chiếu mã yêu cầu như FR, NFR, BR, WF

### Technical Debt Signals
- Các tệp `lib/shared/widgets/game_button.dart`, `score_panel.dart` và `lib/core/utils/game_helpers.dart` chỉ có 1 dòng, có vẻ là phần còn sót
- `pubspec.yaml` còn `description: "A new Flutter project."`
- Màn chơi dùng hằng cố định cho thời hạn bootstrap (3,5 giây), nên việc thêm khởi tạo quảng cáo vào bootstrap phải nằm trong ngân sách này

## Handoff Summary
- **Intent-relevant finding**:
  - Thua ván được xử lý ngay khi hết nước đi: `LevelGameController._resolve` xóa phiên đã lưu (`saveLevelSession(null)`) và gọi `JourneyController.onLevelLost`, hàm này lưu tiến trình đã bị hạ về level đầu của viên đá hiện tại (`returnLevelFor` rồi `firstSubOf(gemId)`) trước cả khi lớp phủ Game Over hiện (`lib/features/journey/controllers/level_game_controller.dart`, `lib/features/journey/controllers/journey_controller.dart`). Reward ads "xóa sạch ô và chơi tiếp" phải chen vào trước bước lưu tổn thất này, hoặc hoàn tác nó.
  - Lớp phủ Game Over hiện có ba nút: PLAY AGAIN (`playAgain` bắt đầu level trả về), SHARE SCORE, BACK TO MENU, và dòng "You will return to <tên level>" (`lib/features/game/widgets/game_over_overlay.dart`). Nút reward sẽ nằm cạnh các nút này. Đây cũng là nơi hiển thị `GameOverOverlay.endless` cho chế độ endless.
  - Màn chơi là `Stack` gồm nền, một `Column` trong `SafeArea` (header, vùng combo cao 44, `Expanded` chứa bảng và khay) và các lớp phủ (`lib/features/game/screens/game_screen.dart`). Banner dưới cùng có thể thêm vào cuối `Column` mà không đổi bảng.
  - Nút bấm PLAY ở Home gọi `_startGame`, tạo `LevelGameController` rồi `start(level, resumeSaved: true)` (`lib/features/home/screens/home_screen.dart`). Đây là điểm đếm "lần bấm Start" cho interstitial.
  - Remote Config hiện chỉ có khóa `level_config`, đặt `minimumFetchInterval` 12 giờ và `fetchTimeout` 2 giây, đọc chỉ khi nguồn là remote (`lib/core/firebase/firebase_remote_config_client.dart`). Mọi khóa mới đi qua cùng cổng, nên khoảng 12 giờ này là độ trễ tối thiểu để cấu hình quảng cáo mới có hiệu lực, trừ khi đổi.
  - `AppBootstrap.run` có hạn chót 3,5 giây, và dựng `AppServices` (config, catalog, progress, journey, audio, analytics, session) (`lib/features/journey/services/app_bootstrap.dart`). Dịch vụ quảng cáo và dịch vụ phiên bản nên được thêm tại đây hoặc ngay sau.
  - Văn bản chia sẻ nằm tập trung trong `ScoreShareService.scoreShareText` và `victoryShareText`, nên thêm link cửa hàng chỉ cần đổi hai hàm này.
  - Khóa hướng dọc được cấu hình ở `AndroidManifest.xml` (`screenOrientation="portrait"`) và `configureSystemUi`.
  - Tên game hiển thị là "Block Jewel", và `MaterialApp.title` cũng là "Block Jewel".
- **Risks / follow-up**:
  - `AndroidManifest.xml` chưa có `uses-permission` nào được thấy, và chưa có meta-data application ID cho AdMob hay AppLovin. Cần bổ sung ở bước triển khai. `Info.plist` chưa có `GADApplicationIdentifier`, `NSUserTrackingUsageDescription` hay danh sách `SKAdNetworkItems`.
  - Chế độ endless dùng cùng lớp phủ Game Over, nên cần quyết định reward ads có áp dụng cho endless hay chỉ cho chế độ journey.
  - Cơ chế lưu: `SharedPreferencesProgressStore` qua `ProgressRepository` có kiểm thử riêng khá dày (761 dòng), nên thay đổi luồng thua cần giữ các kiểm thử này xanh.
