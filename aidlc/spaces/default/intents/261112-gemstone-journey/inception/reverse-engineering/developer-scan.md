# Developer Code Scan — block-crush-game-main

> Ghi chú quy trình: các agent con trong phiên này không có công cụ đọc/ghi file. Người dùng đã đồng ý cho conductor tự thực hiện link developer, đóng vai aidlc-developer-agent.

## Developer Code Scan Results

### Scan Coverage
- **Analyzed deeply**:
  - lib/main.dart
  - lib/app.dart
  - lib/core/
  - lib/features/game/
  - lib/features/home/
  - lib/shared/
  - test/
  - pubspec.yaml
  - analysis_options.yaml
  - android/app/build.gradle.kts
  - assets/
- **Skimmed only**:
  - android/ (ngoài build.gradle.kts: manifest, MainActivity.kt)
  - ios/ (Runner.xcodeproj bundle ID, deployment target)
  - web/, linux/, macos/, windows/ (scaffold Flutter mặc định)
  - README.md, screenshots/

### Packages Found
- `block_blast` — Flutter app (một package duy nhất) — Dart — game xếp khối "Block Crush" (tên hiển thị), có chế độ Classic và Time Attack

### Build System
- **Type**: Flutter/Dart pub. Android dùng Gradle Kotlin DSL, iOS dùng Xcode
- **Config Files**: `pubspec.yaml`, `pubspec.lock`, `analysis_options.yaml`, `android/app/build.gradle.kts`, `ios/Runner.xcodeproj/project.pbxproj`
- **Build Dependencies**: một module duy nhất, không có package nội bộ. Asset khai báo trong pubspec: `assets/sounds/`, `assets/icon.png`. **`assets/design/` chưa được khai báo**

### APIs Discovered
- Không có API mạng hay backend. App chạy hoàn toàn offline
- API nội bộ (static class):
  - `BoardLogic`: `createEmptyBoard`, `canPlaceBlock`, `placeBlock`, `clearCompletedLines`, `applyClearAnimated`, `canPlaceAnyBlock` — `lib/features/game/logic/board_logic.dart`
  - `BlockGenerator.generateThree()` — `lib/features/game/logic/block_generator.dart`
  - `AudioController`: `init`, `toggleMute`, `isMuted`, `playPlace`, `playClear`, `playCombo`, `playGameOver` — `lib/core/audio/audio_controller.dart`
  - `ThemeManager` (ChangeNotifier): `currentTheme`, `setTheme`, `backgroundGradient`, `boardBackground` — `lib/core/theme/theme_manager.dart`
- Key lưu trong SharedPreferences: `high_score`, `high_score_time`, `theme_index`, `last_login_date`, `tutorial_completed`

### Frameworks & Libraries
- flutter (SDK) — Dart ^3.9.2 — UI framework
- provider — ^6.1.2 — state management (chỉ dùng cho ThemeManager)
- shared_preferences — ^2.2.3 — lưu dữ liệu cục bộ
- flutter_animate — ^4.5.0 — animation
- audioplayers — ^6.0.0 — âm thanh hiệu ứng
- google_fonts — ^6.2.1 — font (dùng trong app_theme)
- share_plus — ^10.1.3 — chia sẻ điểm
- screenshot — ^3.0.0 — chụp màn hình để chia sẻ
- path_provider — ^2.1.5 — thư mục tạm cho ảnh chia sẻ
- cupertino_icons — ^1.0.8
- dev: flutter_test, flutter_lints ^5.0.0, flutter_native_splash ^2.4.0, flutter_launcher_icons ^0.13.1

### Test Coverage
- **Test Directories**: `test/`
- **Test Frameworks**: flutter_test
- **Coverage Config**: không có
- `test/widget_test.dart` là test counter mặc định của Flutter. Nó gọi `MyApp`, class không tồn tại (app thật là `BlockBlastApp`), nên **test này không compile được**. Thực tế coverage bằng 0.

### Code Quality Indicators
- **Linting**: `flutter_lints` qua `analysis_options.yaml`, không có rule tùy chỉnh
- **CI/CD**: không có (không có `.github/`). Thư mục không phải git repo
- **Documentation**: README dạng marketing. Code hầu như không có doc comment

### Technical Debt Signals
- Toàn bộ logic game nằm trong `_GameScreenState` (`lib/features/game/screens/game_screen.dart`, 395 dòng): state, scoring, timer, high score, tutorial, share, game over và revive.
- File rỗng (0 dòng): `lib/features/game/controllers/game_controller.dart`, `lib/core/utils/game_helpers.dart`, `lib/shared/widgets/game_button.dart`, `lib/shared/widgets/score_panel.dart`.
- `ParticleExplosion` (`widgets/particle_explosion.dart`) không được dùng ở đâu.
- `AudioController.init()` rỗng. `_bgmPlayer` không bao giờ phát nhạc. Trạng thái mute không được lưu, nên mất khi khởi động lại.
- Mọi lỗi phát âm thanh đều bị nuốt (`catch (e) {}`).
- Dùng `withOpacity` (deprecated trên Flutter mới).
- Daily Gift hiển thị "+500 Points" nhưng không cộng điểm thật (`home_screen.dart`).
- Tính năng ice/bomb có trong model và generator, nhưng ice không có cơ chế giảm `iceHealth`.
- Test hỏng (xem Test Coverage).
- Package Android `com.example.block_blast` (namespace, applicationId, `kotlin/com/example/block_blast/MainActivity.kt`). iOS `com.example.blockBlast`.
- `assets/design/` (36 ảnh jpg khoảng 700KB mỗi ảnh, tổng khoảng 25MB, kèm 6 file prompt `.txt`) chưa có trong `pubspec.yaml`.

## Handoff Summary
- **Intent-relevant finding**:
  - Điểm mở rộng chính là `_GameScreenState`. `GameMode` enum (`game_screen.dart:25`) với nhánh `timeAttack` nằm rải ở các dòng 62, 89, 97, 205, 219, 309, 350.
  - Scoring nằm trong `placeBlock()`: 10 điểm/ô, cộng `cleared*100*combo`. Game over ở `_triggerGameOver()`.
  - Home có `_buildModeCard` ×2 và `_checkDailyReward` (`home_screen.dart`).
  - Ảnh nền 36 level đã có ở `assets/design/Level1..6/1..6.jpg` (thứ tự Level1 = Rose Quartz … Level6 = Ruby).
- **Risks / follow-up**:
  1. REVIVE (FREE) và SHARE SCORE có trên Game Over nhưng chưa được đề cập trong scope. Cần quyết định giữ hay bỏ trong chế độ level.
  2. Theme Neon/Wood/Jewel có thể xung đột với màu theo đá quý (mục 5.1 của requirements).
  3. 25MB ảnh trong bundle ảnh hưởng dung lượng app.
  4. `game_controller.dart` rỗng là nơi tự nhiên để tách logic (NFR-01).
  5. Test hiện tại hỏng, cần sửa trước khi đặt coverage floor 80%.
  6. Chưa có Firebase (không có `google-services.json` hay `GoogleService-Info.plist`).
