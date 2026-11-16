# Units of Work — Gemstone Journey

## Sources

- [comp] `inception/domain-design/components.md` (17 component), [adr] `decisions.md` (ADR-001..ADR-010)
- [req] `inception/requirements-analysis/requirements.md`
- [stories] `inception/user-stories/stories.md`
- [prac] `inception/practices-discovery/team-practices.md`: luôn làm walking skeleton trước, test-after, coverage 80%, không dùng git, người dùng tự build và test
- [Q1]–[Q4] `units-generation-questions.md`

## Tổng quan

| Unit ID | Directory | Tên | Kind | Deployment | Complexity |
|---------|-----------|-----|------|-----------|-----------|
| U1 | `u1-journey-skeleton` | Journey walking skeleton | service | embedded (một app Flutter) | L |
| U2 | `u2-level-rules` | Quy tắc level đầy đủ | service | embedded | M |
| U3 | `u3-victory-audio` | Victory và âm thanh | ui | embedded | M |
| U4 | `u4-visual-theme` | Giao diện theo đá quý và ảnh nền | ui | embedded | M |
| U5 | `u5-analytics` | Analytics và phiên chơi | service | embedded | S |
| U6 | `u6-endless-mode` | Chế độ endless | service | embedded | S |

Mọi unit được build thành một app duy nhất (`flutter build appbundle` / `ipa`) và phát hành thủ công. [prac] [Q4]

### Definition of Done chung (áp dụng cho mọi unit) [review R-06]

Mỗi unit chỉ được coi là xong khi đạt đủ các điểm sau:

| # | Tiêu chí | Cách kiểm |
|---|----------|-----------|
| DoD-1 | Logic mới và logic bị sửa nằm trong controller/service, có unit test cho happy path và ít nhất 2 ca lỗi/biên | Review code + `flutter test` xanh (người dùng chạy) |
| DoD-2 | Mọi file Dart mà unit **tạo mới hoặc sửa** có coverage dòng ≥ 80% | `flutter test --coverage`, xem `lcov` theo file |
| DoD-3 | Chuỗi UI mới chỉ tiếng Anh. Nút mới có vùng chạm ≥ 48dp (widget test) | Review chuỗi + widget test |
| DoD-4 | Không nuốt lỗi im lặng: mọi `catch` đều log và có fallback | Review code |
| DoD-5 | `flutter analyze` không có lỗi | Người dùng chạy |

**Mốc đo coverage toàn codebase ≥ 80% (NFR10)** là ở stage **Build & Test**, sau khi xong cả 6 unit. Code cũ không thuộc unit nào (ví dụ `animated_background.dart`, `particle_explosion.dart`, `app_theme.dart`, widget cũ) do **U4** chịu trách nhiệm: bổ sung test, hoặc gỡ nếu không còn dùng, để tổng coverage đạt ngưỡng. [review R-05]

US8.5 và US8.6 được thực hiện qua DoD-1..DoD-5 cho mọi unit. Riêng phần khóa portrait, font và tương phản của US8.6 thuộc U4.

### Quy ước màu giữa các unit [review R-02]

- **U1** giữ nguyên `ThemeManager` hiện có cho bảng và khối. Header và nút mới dùng `AppColors.primary` / `AppColors.accent`.
- **U3** dùng hằng số tạm `VictoryColors.accent = AppColors.accent` cho glow và confetti, khai báo ở **một chỗ duy nhất** trong `lib/features/victory/victory_colors.dart`.
- **U4** là **chủ sở hữu duy nhất** của `GemTheme`. U4 gỡ `ThemeManager`, thay mọi tham chiếu (`BoardCell`, `DraggableBlock`, header của U1, `VictoryColors` của U3) bằng `GemTheme.forGem(gemId)`, rồi xóa `victory_colors.dart`. Nếu U4 làm trước U3, U3 dùng thẳng `GemTheme` và bỏ qua hằng số tạm.
- `Level.assetPath` và `Level.backgroundUrl` được định nghĩa ngay từ **U1** (trong `LevelCatalog`). U1 chưa dùng `backgroundUrl`. U4 dùng nó.

---

## U1 — `u1-journey-skeleton` (walking skeleton)

- **Mô tả**: lát cắt tích hợp nhỏ nhất chạy được từ đầu đến cuối. Mở app → fetch Remote Config (hoặc fallback) → Home → PLAY → chơi Classic ở level hiện tại với target → đạt mốc thì Victory tối giản → CONTINUE → level kế tiếp → tiến trình được lưu và khôi phục khi mở lại. [prac] [Q2]
- **Component**: `LevelConfigService` (kèm `RemoteConfigClient` Firebase và fake, config mặc định, validate đầy đủ theo ADR-010), `LevelCatalog`, `AppBootstrap`, `ProgressRepository` (cache, hàng đợi ghi, key riêng theo ADR-009; trong U1 chỉ dùng `progress`), `JourneyController` (chỉ `onLevelWon` → next level), `BoardEngine` (thêm `TurnResolver`), `LevelGameController` (trạng thái playing → resolving → won theo ADR-008), `SplashUI` tối giản, `HomeUI` tối giản (nhãn level và PLAY), `GameplayUI` (header có tên level, `score / target`, `%`).
- **Ranh giới**:
  - Đổi package Android `com.h2.game.block_blast` và iOS `com.h2.game.blockBlast`. Thêm `firebase_core` và `firebase_remote_config`. Khởi tạo Firebase trong `main.dart`. [req FR14, NFR3, NFR4]
  - Gỡ Time Attack (FR1), sửa `test/widget_test.dart` đang hỏng.
  - Victory chỉ là màn tạm có "Level Complete!" và CONTINUE (U3 thay bằng bản đầy đủ).
  - Khi thua: giữ Game Over hiện có, chưa áp dụng quy tắc reset (U2 làm).
- **Kiểm chứng end-to-end (người dùng chạy)**:
  - Build Android thành công với package mới.
  - Offline: level 1 target 500 lấy từ config mặc định.
  - Online: target lấy từ Remote Config.
  - Thắng level 1 → CONTINUE → level 2. Kill app rồi mở lại vẫn ở level 2.
  - `flutter test` xanh.
- **Tiêu chí hoàn thành**: tính theo **Android**. Nếu chưa có Mac để build iOS, phần kiểm chứng iOS (đổi bundle ID, Firebase iOS) được ghi là hoãn và thực hiện ở Build & Test. Việc này không chặn U1. [review R-04]
- **Checklist tiền điều kiện của người dùng (chặn U1)** [Q2] [review R-04]:
  1. ☐ Sao lưu thủ công (zip) toàn bộ thư mục dự án trước khi bắt đầu U1 (không có git).
  2. ☐ Tạo Firebase project (gói Spark miễn phí).
  3. ☐ Thêm app Android với package `com.h2.game.block_blast`, tải `google-services.json` vào `android/app/`.
  4. ☐ (Nếu có Mac) Thêm app iOS `com.h2.game.blockBlast`, tải `GoogleService-Info.plist` vào `ios/Runner/`.
  5. ☐ Remote Config: tạo key `level_config` (kiểu JSON) với nội dung mặc định (sẽ được cung cấp trong code) và publish.
- **Thứ tự bên trong U1** (giảm rủi ro, mỗi bước có thể build và chạy được) [review R-01]:
  1. **Đổi package và khởi tạo Firebase**: chỉ đổi cấu hình Android/iOS và `main.dart` (`Firebase.initializeApp`). Sửa `test/widget_test.dart`. Người dùng build thử. *Chưa đụng logic game.*
  2. **Sao lưu lần 2** (người dùng zip lại thư mục), rồi **tách `BoardEngine`/`TurnResolver`** khỏi `_GameScreenState` kèm unit test. Gameplay phải giống hệt trước (US2.2). Gỡ Time Attack ở bước này.
  3. **`LevelConfigService` (fake và Firebase), `LevelCatalog`, `AppBootstrap`** kèm test validate và fallback.
  4. **`ProgressRepository`, `JourneyController.onLevelWon`, `LevelGameController`** (playing → resolving → won), header có target và %, Victory tạm, Home có PLAY. Chạy kiểm chứng end-to-end.
- **Ghi chú**: đây là unit lớn nhất (L) vì gánh refactor `_GameScreenState` (ADR-001) và tích hợp Firebase.
- **Hợp đồng `JourneyOutcome` tối thiểu của U1** [review R-03]: `JourneyOutcome { Level? nextLevel; int highestLevelReached; }`. U2 thêm các trường `String? unlockedGemId` và `bool journeyCompleted` cùng hàm `onLevelLost`.

## U2 — `u2-level-rules`

- **Mô tả**: hoàn thiện quy tắc hành trình và vòng đời ván level.
- **Component**:
  - `JourneyController`: `onLevelLost` (xóa các sub của gem hiện tại, về Rough Stone), mở khóa gem khi thắng Bling, journey complete ở level 36, high score, `highestLevelReached` không giảm.
  - `ProgressRepository`: key `high_scores`, migration gỡ key cũ, xử lý key hỏng.
  - `LevelGameController`: nhánh lost (resolving → lost), QUIT.
  - `GameplayUI`: `QuitDialog` với `PopScope`, `GameOverOverlay` mới (Target, thông báo quay về Rough Stone, bỏ REVIVE, giữ SHARE), BEST theo level trên header.
- **Ranh giới**: không làm hiệu ứng Victory (U3). Chỉ đưa `JourneyOutcome` (unlockedGem, journeyCompleted) để U3 hiển thị.

## U3 — `u3-victory-audio`

- **Mô tả**: trải nghiệm ăn mừng và âm thanh.
- **Component**:
  - `VictoryUI`: các biến thể sub, gemUnlock (2D), journeyComplete (không có CONTINUE). Confetti tái dùng `ParticleExplosion`, glow, CONTINUE hiện ngay và khóa sau lần bấm đầu, reduced motion.
  - `AudioController`: `playVictory`, `playUnlock`, `stopSfx`, mute lưu qua `sound_muted`, log lỗi.
  - `HomeUI`: Settings chỉ còn Sound.
  - Asset `victory` và `unlock.wav` (cho phép placeholder).
- **Ranh giới**: dùng màu tạm. Màu đá quý chính thức đến từ U4. Nếu U4 xong trước thì dùng luôn `GemTheme`.

## U4 — `u4-visual-theme`

- **Mô tả**: diện mạo theo đá quý và ảnh nền.
- **Component**:
  - `GemTheme`: gỡ `ThemeManager`, `AppThemeType` và `theme_index`. Sửa `BoardCell` và `DraggableBlock`.
  - `BackgroundImageService`: `ImageLoader` với `cached_network_image`, asset trước, cross-fade 300ms, precache.
  - `GameplayUI.LevelBackground`: blur, lớp phủ 50%, bỏ hạt chuyển động.
  - `SplashUI` theo mockup. `HomeUI` theo mockup (gem 2D placeholder, "Level N of 36", bỏ Daily Gift và key `last_login_date`).
  - Đóng gói font Righteous/Montserrat (`allowRuntimeFetching = false`), khai báo `assets/design/`, khóa portrait.
- **Ranh giới**: không đổi logic ván chơi.
- **Thêm trách nhiệm**: chủ sở hữu duy nhất của `GemTheme` (thay `ThemeManager` và `VictoryColors` tạm). Chịu trách nhiệm phần coverage của code cũ không thuộc unit nào (DoD chung). [review R-02, R-05]

## U5 — `u5-analytics`

- **Mô tả**: đo lường.
- **Component**:
  - `AnalyticsService`: abstract, kèm triển khai Firebase và fake. Thêm dependency `firebase_analytics`.
  - `LevelGameController`: gửi `level_start`, `level_complete`, `level_fail` và user property từ `JourneyOutcome`.
  - `SessionTracker`: `Clock`, gửi `game_session` khi paused, `addPlayTime`.
- **Phụ thuộc**: U1 và **U2**. `level_fail` cần nhánh thua của U2. User property cần `JourneyOutcome` đầy đủ của U2. [review R-03]
- **Ranh giới**: không gửi event level ở chế độ endless (U6 không gọi analytics).

## U6 — `u6-endless-mode`

- **Mô tả**: chơi tiếp sau Journey Complete.
- **Component**:
  - `EndlessGameController`: bắt đầu với `endless_saved_score` trên bảng trống. Lưu khi QUIT, về Home hoặc paused. Thua thì đặt về 0 và cập nhật `endless_high_score`.
  - `GameplayUI`: biến thể endless của header, quit dialog và game over.
  - `HomeUI`: State C "Journey Complete" với "Endless · Best N" (hiển thị "—" khi chưa có).
- **Ranh giới**: chỉ có hiệu lực khi `journeyCompleted = true` (U2).

## Assumptions & Open Questions

- [assumption] Plan approval: bản tóm tắt kế hoạch đã được người dùng xác nhận ("Looks correct") với số unit, kind và chiến lược chia unit, nên dùng thay cho bước Approve Plan riêng.
- [assumption] Người dùng có Mac/Xcode để build iOS (giả định A3 từ Feasibility). Nếu không, phần kiểm chứng iOS sẽ hoãn sang Build & Test và U1 tính hoàn thành theo Android.
- Bản này đã sửa theo `reviews/review-01.md` (R-01..R-06).
