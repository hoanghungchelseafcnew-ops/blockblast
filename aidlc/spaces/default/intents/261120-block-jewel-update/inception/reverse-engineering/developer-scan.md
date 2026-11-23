## Developer Code Scan Results

> Ghi chú: subagent developer không có công cụ đọc/ghi file trong phiên này, nên người điều phối (conductor) đã tự quét theo vai developer. Mọi số liệu dưới đây đều đọc trực tiếp từ mã nguồn.

### Scan Coverage
- **Analyzed deeply**:
  - lib/
  - test/
  - pubspec.yaml
  - analysis_options.yaml
  - android/app/src/main/AndroidManifest.xml
  - android/app/src/main/res/
  - android/app/build.gradle.kts
  - ios/Runner/Info.plist
  - ios/Runner/Base.lproj/LaunchScreen.storyboard
  - README.md
- **Skimmed only**:
  - assets/
  - web/
  - linux/
  - macos/
  - windows/
  - coverage/
  - backup/
  - screenshots/

### Packages Found
- block_blast (package name; Dart/Flutter app, SDK ^3.9.2) — app — Dart — game xếp khối kéo thả, chế độ Journey (36 level) và Endless
- lib/core — module — Dart — analytics, audio, config (Remote Config), constants, firebase, log, theme, utils
- lib/features/{endless,game,home,journey,splash,victory} — feature modules — Dart — theo cấu trúc feature-first
- lib/shared/widgets — module — Dart — widget dùng chung

### Build System
- **Type**: Flutter / Gradle (Kotlin DSL) cho Android, Xcode cho iOS
- **Config Files**: pubspec.yaml, analysis_options.yaml, android/app/build.gradle.kts, ios/Runner/Info.plist
- **Build Dependencies**: app → Firebase (core, remote_config, analytics), provider, share_plus, screenshot, path_provider

### APIs Discovered
- Firebase Remote Config — lib/core/firebase/firebase_remote_config_client.dart — cấu hình mốc điểm level, có fallback ở lib/core/firebase/default_level_config.dart
- Firebase Analytics — lib/core/analytics/ — sự kiện phiên và level
- Không có HTTP API tự viết; chỉ có ảnh nền qua URL (lib/core/config/image_url_policy.dart)

### Frameworks & Libraries
- flutter, provider ^6.1.2 — state qua ChangeNotifier
- share_plus ^10.1.3, screenshot ^3.0.0, path_provider ^2.1.5 — đã có sẵn cho tính năng chia sẻ ảnh
- shared_preferences ^2.2.3 — lưu tiến trình
- firebase_core ^3.15.0, firebase_remote_config ^5.4.0, firebase_analytics ^11.6.0
- audioplayers ^6.0.0, flutter_animate ^4.5.0, google_fonts ^6.2.1, cached_network_image ^3.4.1
- dev: flutter_lints ^5.0.0, flutter_native_splash ^2.4.0, flutter_launcher_icons ^0.13.1

### Test Coverage
- **Test Directories**: test/ (core, features, shared, ui, fakes, fixtures), 7.702 dòng test so với 6.413 dòng code trong lib/
- **Test Frameworks**: flutter_test
- **Coverage Config**: có coverage/lcov.info (2.467 dòng) từ lần chạy trước; test/widget_test.dart hiện có (42 dòng), tình trạng pass/fail chưa kiểm chứng ở bước này

### Code Quality Indicators
- **Linting**: flutter_lints qua analysis_options.yaml (loại trừ build/, android/, ios/, web/, windows/, macos/, linux/)
- **CI/CD**: không có (không có .github hay pipeline); build thủ công theo team.md
- **Documentation**: README.md có (tên "Block Crush"); doc comment tiếng Việt khá đầy đủ trong lib/

### Technical Debt Signals
- lib/features/game/logic/block_generator.dart: dùng `static final Random` và hàm tĩnh, không biết level, không biết trạng thái bảng (không testable theo seed, không có tham số độ khó)
- Tên cũ rải rác: "Block Crush", "BLOCK CRUSH", "Gemstone Journey", "BlockBlastApp", "block_crush" (CFBundleName)
- Thư mục .git tồn tại dù team.md ghi không dùng git

## Handoff Summary
- **Intent-relevant finding**:
  1. **Splash gốc (native)**: pubspec.yaml dòng 121 có khối `flutter_native_splash` (color #0F0C29, image assets/icon.png, android_12 cùng màu/ảnh). Đã sinh: android/app/src/main/res/drawable{,-v21}/launch_background.xml (bitmap `background` + `splash`), drawable-*/splash.png, drawable-*/android12splash.png, values{,-v31,-night,-night-v31}/styles.xml (LaunchTheme với windowSplashScreenBackground #0F0C29 và windowSplashScreenAnimatedIcon @drawable/android12splash), iOS: ios/Runner/Base.lproj/LaunchScreen.storyboard dùng ảnh `LaunchImage` (1024×1024) và `LaunchBackground` (1×1) trong Assets.xcassets. Splash trong code: lib/features/splash/screens/splash_screen.dart (SplashScreen, hiện assets/icon.png, chữ 'BLOCK CRUSH', '◆ Gemstone Journey ◆', chờ `AppBootstrap.run()` rồi pushReplacement sang HomeScreen). Có test: test/ui/splash_home_test.dart, test/widget_test.dart (key splash-logo/splash-title/splash-subtitle/splash-progress).
  2. **Tên game**: android/app/src/main/AndroidManifest.xml dòng 3 `android:label="Block Crush"`; ios/Runner/Info.plist CFBundleDisplayName "Block Crush", CFBundleName "block_crush"; lib/app.dart dòng 16 `title: 'Block Crush'` (class BlockBlastApp); lib/features/game/services/score_share_service.dart dòng 38 chuỗi chia sẻ "Block Crush"; lib/features/splash/screens/splash_screen.dart dòng 54 'BLOCK CRUSH'; subtitle 'Gemstone Journey' ở splash_screen.dart dòng 60 và lib/features/home/screens/home_screen.dart dòng 170, lib/core/log/gj_log.dart dòng 6 (comment); README.md. applicationId/namespace `com.h2.game.block_blast` (android/app/build.gradle.kts dòng 11 và 25) và package Dart `block_blast` (import trong mọi test) KHÔNG nên đổi nếu app đã phát hành.
  3. **Chia sẻ**: đã có `ScoreShareService` (abstract) và `PlatformScoreShareService` trong lib/features/game/services/score_share_service.dart, dùng `ScreenshotController.capture()` → ghi `score.png` vào thư mục tạm → `Share.shareXFiles` với text 'I scored $score in Block Crush!'. GameScreen (lib/features/game/screens/game_screen.dart) bọc toàn Scaffold trong `Screenshot(controller: _screenshotController)` và chỉ gọi share từ `GameOverOverlay.onShare` (dòng ~243). `VictoryOverlay` (lib/features/victory/widgets/victory_overlay.dart) KHÔNG có nút share; nó nhận `variant`, `level`, `score`, `target`, `best`, `onContinue`, `onBackToMenu`. Biến thể: `VictoryVariant` { sub (level con 1–5), gemUnlock (mở khóa gem, tức "level lớn"), journeyComplete (level 36) } trong lib/features/victory/models/victory_variant.dart; `LevelGameController.victoryVariant` tính từ `JourneyOutcome`. Victory được vẽ bên trong cùng Stack của GameScreen nên ảnh chụp từ `_screenshotController` sẽ gồm cả overlay. Endless có `EndlessGameScreen` với cùng cơ chế (ngoài phạm vi yêu cầu).
  4. **Thuật toán sinh khối**: `BlockGenerator.generateThree()` (lib/features/game/logic/block_generator.dart) là hàm tĩnh, trả 3 `BlockModel`; mỗi khối: 30% nhỏ / 50% vừa / 20% lớn, tối đa 2 khối "lớn" (rows>=3 hoặc cols>=3) rồi ép khối nhỏ; 5% băng (isIce, iceHealth 2), 5% bom. `BoardEngine` (lib/features/game/engine/board_engine.dart) nhận `BlockSource = List<BlockModel> Function()` (mặc định `BlockGenerator.generateThree`), gọi trong `reset()` và `refillTrayIfEmpty()`; engine KHÔNG biết level và KHÔNG truyền board cho generator. `LevelGameController` (journey) và `EndlessGameController` đều tạo `BoardEngine()` mặc định (dòng 37 và 25). Sau mỗi lượt: `_engine.refillTrayIfEmpty(); if (!_engine.hasMoves) → thua`. `hasMoves` dùng `BoardLogic.canPlaceAnyBlock(board, tray)`; `BoardLogic.canPlaceBlock(board, block, row, col)` đã có. Board 8×8 (`GameConstants.boardSize`), `CellModel.filled`. Level hiện có `Level.levelIndex` 1..36 (`Level.totalLevels`), `gemOrder` 1..6, `subOrder` 1..6. Hạn chế: thuật toán mới cần board hiện tại, level hiện tại và số ô đã đầy; hiện BoardEngine chỉ có `BlockSource` không tham số, nên cần đổi chữ ký hoặc thêm một lớp chọn khối nhận (board, level, tray hiện tại). Lưu ý "không khối nào đặt vừa" hiện được coi là thua (`hasMoves == false`), cần quyết định: kiểm tra và thay khối ngay sau khi sinh khay/sau mỗi lượt trước khi xét thua.
- **Risks / follow-up**:
  - Android 12+ luôn hiện splash hệ thống (icon + nền); chỉ có thể làm cùng màu nền với splash trong code, không bỏ hẳn được. Cần gỡ `flutter_native_splash` khỏi pubspec hoặc chạy `dart run flutter_native_splash:remove` rồi chỉnh tay styles.xml/LaunchScreen.storyboard; đây là bước người dùng phải chạy (team.md: AI chỉ sinh code, người dùng chạy lệnh).
  - Test hiện tham chiếu chuỗi 'BLOCK CRUSH' và 'Gemstone Journey' (test/ui/splash_home_test.dart, test/widget_test.dart, có thể test home); đổi tên phải cập nhật test.
  - Điểm thắng và độ khó theo level nằm ở Remote Config/`default_level_config.dart`; tham số độ khó của generator nên là hằng số trong code, không chạm Remote Config.
  - test/widget_test.dart cần xác nhận pass trước khi đo coverage (yêu cầu team.md).
  - Chuỗi UI chỉ dùng tiếng Anh (project.md).
