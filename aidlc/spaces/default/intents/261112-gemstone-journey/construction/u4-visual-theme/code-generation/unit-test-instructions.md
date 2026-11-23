# Hướng dẫn test — U4 `u4-visual-theme`

## Chiến lược

- Test strategy: **standard** (5–8 test mỗi component, unit test cộng integration cho ranh giới chính). Phương pháp: **test-after**. Mỗi lớp được implement trước, rồi viết và chạy test của lớp đó.
- AI chạy các lệnh dưới đây bằng Flutter Linux 3.41.5 trong WSL. Sau đó người dùng chạy `flutter pub get` trên Windows trước khi build.

## Thiết lập test

- Framework: `flutter_test`. Không thêm thư viện mock. Dùng fake viết tay: `FakeNetworkImageFactory` (đếm số lần gọi, trả provider thành công hoặc lỗi), `FakeProgressStore`, `LogCapture`.
- Ảnh trong widget test: provider giả trả ảnh 1×1 hoặc ném lỗi, để không cần mạng.
- Hướng màn hình: `TestDefaultBinaryMessengerBinding` bắt method call `SystemChrome.setPreferredOrientations` trên `SystemChannels.platform`.
- Cấu trúc thư mục test:
  - `test/core/theme/gem_theme_test.dart` — bảng màu, độ tương phản, typography (mới)
  - `test/features/journey/background_image_service_test.dart` — nạp ảnh nền (mới)
  - `test/features/journey/progress_repository_test.dart` — gỡ 4 key cũ
  - `test/app_composition_test.dart` — không còn `ThemeManager`, khóa portrait
  - `test/shared/level_background_test.dart`, `test/shared/gem_widgets_test.dart` — widget mới
  - `test/ui/splash_home_test.dart`, `test/ui/game_screen_test.dart`, `test/ui/legacy_widgets_test.dart` — màn đã sửa

## Lệnh chạy (phạm vi U4)

Lệnh mốc trước khi sửa (đã runnable):

```bash
flutter test test/ui/ test/app_composition_test.dart
```

Lệnh theo lớp của U4 (chạy từ gốc dự án):

```bash
flutter test test/core/theme/gem_theme_test.dart
flutter test test/features/journey/background_image_service_test.dart
flutter test test/features/journey/progress_repository_test.dart test/app_composition_test.dart
flutter test test/shared/ test/ui/
```

Lệnh kiểm chứng của checkpoint (Construction Verification Command đã duyệt):

```bash
flutter analyze && flutter test --coverage
```

Xem coverage theo file trong `coverage/lcov.info`.

## Mục tiêu coverage

- Mọi file Dart mà U4 **tạo mới hoặc sửa** có coverage dòng **≥ 80%** (DoD-2).
- Coverage dòng toàn codebase ≥ 80% (U4 phụ trách code cũ không thuộc unit nào).
- `flutter analyze` không có lỗi hay cảnh báo (DoD-5).
- Không hạ ngưỡng nào để một bước đạt. Nếu một file không đạt, ghi rõ con số và lý do trong `code-summary.md`.

## Danh mục test chính

| Component | Nội dung bắt buộc |
|-----------|-------------------|
| `GemTheme` / `contrastRatio` | đúng 6 bảng màu; `buttonFill` của Amethyst; gem lạ → Rose Quartz + log; giá trị tương phản đã biết; checklist WCAG AA cho 6 gem (chữ ≥ 4.5:1, viền thanh tiến độ ≥ 3:1) |
| `AppTypography` | đúng family; trục `wght` khớp `fontWeight` |
| `BackgroundImageService` | asset path đúng (AC7.1.1); không URL → không provider mạng; có URL → factory gọi một lần và được dùng lại (AC7.2.3); precache lỗi chỉ log, không lộ URL; đủ 36 asset trên đĩa |
| Gỡ theme cũ / Daily Gift / portrait | gỡ đủ 4 key cũ; không còn provider `ThemeManager`; lệnh portrait được gửi; grep tĩnh không còn `ThemeManager`, `theme_index`, `last_login_date`, Daily Gift trong `lib/` |
| `LevelBackground` | asset khi không URL; blur khi `blurred`; ảnh mạng lỗi → giữ asset; asset lỗi → gradient |
| `GemPrimaryButton` / `LevelProgressBar` | ≥ 56dp và đúng màu; viền trắng, màu `primary`, nhãn % |
| Splash / Home / Game | chữ của Splash; "Level N of 36"; PLAY ≥ 48dp; không Daily Gift; Settings không có THEME; màu Emerald ở Emerald; nền game có blur; không còn `AnimatedBackground` |

## Mocking và dữ liệu test

- Catalog: dựng `LevelCatalog` từ `DefaultLevelConfig` (36 level thật). Ca có URL dùng `Level` dựng tay với `backgroundUrl` hợp lệ theo `ImageUrlPolicy`.
- Không gọi mạng thật trong test. Mọi ảnh mạng đi qua `FakeNetworkImageFactory`.
- Không có test nào luôn đúng. Mỗi test kiểm một hành vi cụ thể.
