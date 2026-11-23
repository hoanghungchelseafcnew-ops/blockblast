# Code Summary — U4 `u4-visual-theme`

## Kết quả kiểm chứng

Chạy trên máy của AI bằng Flutter Linux 3.41.5, ngày 2026-11-18:

- `flutter analyze`: **No issues found**.
- `flutter test --coverage`: **297/297 test xanh** (sau U2 có 254 test).
- Coverage dòng toàn codebase: **97.5%** (1588/1628).

Coverage của các file U4 tạo mới hoặc sửa logic (DoD-2, ngưỡng 80%):

| File | Coverage |
|------|----------|
| `lib/core/theme/gem_theme.dart` (mới) | 100% |
| `lib/core/theme/contrast.dart` (mới) | 100% |
| `lib/core/theme/app_typography.dart` (mới) | 100% |
| `lib/core/theme/app_theme.dart` | 100% |
| `lib/features/journey/services/background_image_service.dart` (mới) | 90.5% (19/21) |
| `lib/shared/widgets/level_background.dart` (mới) | 100% |
| `lib/shared/widgets/gem_primary_button.dart` (mới) | 100% |
| `lib/shared/widgets/level_progress_bar.dart` (mới) | 100% |
| `lib/features/home/screens/home_screen.dart` | 96.6% (86/89) |
| `lib/features/splash/screens/splash_screen.dart` | 95.7% (22/23) |
| `lib/features/game/screens/game_screen.dart` | 99.3% (147/148) |
| `lib/features/game/widgets/{board_cell,draggable_block,game_board,quit_dialog,game_over_overlay}.dart` | 100% |
| `lib/features/journey/controllers/journey_controller.dart` | 83.6% (51/61) |
| `lib/features/journey/controllers/level_game_controller.dart` | 98.7% (153/155) |
| `lib/features/journey/services/progress_repository.dart` | 99.1% (108/109) |
| `lib/app_composition.dart` | 90.0% (9/10) |

**Một file dưới ngưỡng:** `lib/core/audio/audio_controller.dart` đạt **66.7% (10/15)**. U4 chỉ đổi định dạng file này (do `dart format`), không đổi logic. Phần chưa phủ là các lệnh phát âm thanh thật của `audioplayers`. U3 sẽ viết lại file này: lưu mute qua `sound_muted`, log lỗi thay vì nuốt im lặng, và thêm test. Tôi không hạ ngưỡng nào và không thêm `coverage:ignore`.

## Checklist tương phản WCAG AA (AC8.6.2)

Được kiểm tự động trong `test/core/theme/gem_theme_test.dart` cho cả 6 gem:

| Gem | Chữ nút trên nền nút (≥ 4.5:1) | Chữ trắng / viền thanh tiến độ trên nền (≥ 4.5:1 và ≥ 3:1) |
|-----|------|------|
| Rose Quartz | `#151525` trên `#FFB6C1` ≈ 10.9:1 | đạt |
| Amethyst | trắng trên `#7A4FB0` ≈ 5.9:1 | đạt |
| Blue Topaz | `#151525` trên `#4FC3F7` ≈ 9.0:1 | đạt |
| Emerald | `#151525` trên `#50C878` ≈ 8.5:1 | đạt |
| Sapphire | trắng trên `#0F52BA` ≈ 7.2:1 | đạt |
| Ruby | trắng trên `#E0115F` ≈ 4.8:1 | đạt |

Đầu gradient nền là màu phụ của gem trộn 35% lên `#0F0C29`. Nếu dùng màu phụ đặc, chữ trắng trên nền Rose Quartz chỉ đạt khoảng 2.6:1.

## File đã tạo, sửa, xóa

**Mới**
- `lib/core/theme/gem_theme.dart`, `contrast.dart`, `app_typography.dart`.
- `lib/features/journey/services/background_image_service.dart`.
- `lib/shared/widgets/level_background.dart`, `gem_primary_button.dart`, `level_progress_bar.dart`.
- `assets/fonts/Righteous-Regular.ttf`, `Montserrat-Variable.ttf`, cùng hai file giấy phép `OFL-*.txt` (tải từ `github.com/google/fonts`).
- Test: `test/core/theme/gem_theme_test.dart`, `legacy_theme_removed_test.dart`, `test/features/journey/background_image_service_test.dart`, `test/shared/level_background_test.dart`, `gem_widgets_test.dart`, `test/fakes/fake_images.dart`.

**Xóa**
- `lib/core/theme/theme_manager.dart` (`ThemeManager`, `AppThemeType`).
- `lib/core/widgets/animated_background.dart`.

**Sửa (logic)**
- `pubspec.yaml`, `pubspec.lock`: thêm `cached_network_image`, khai báo `assets/design/Level1..6/`, khai báo font family `Righteous` và `Montserrat`.
- `AndroidManifest.xml`: `screenOrientation="portrait"`. `ios/Runner/Info.plist`: iPhone chỉ còn portrait.
- `app_composition.dart`: bỏ Provider `ThemeManager`, thêm `configureSystemUi()`. `main.dart` gọi hàm này.
- `progress_repository.dart`: `legacyKeys` thêm `theme_index` và `last_login_date`.
- `journey_controller.dart`: thêm `nextLevelFor`. `level_game_controller.dart`: thêm `upcomingLevel`.
- `app_theme.dart`: dùng `AppTypography`, không còn `GoogleFonts`.
- `home_screen.dart`: bỏ Daily Gift và phần THEME; giao diện M-1 (nền level, icon gem, "Level N of 36", PLAY màu gem).
- `splash_screen.dart`: giao diện M-0.
- `game_screen.dart`: `LevelBackground` (blur, phủ 50%), `LevelProgressBar`, nút màu gem, precache level N+1.
- `board_cell.dart`, `draggable_block.dart`, `game_board.dart`: giữ kiểu vẽ "neon", không còn phụ thuộc theme.
- `quit_dialog.dart`, `game_over_overlay.dart`: nút màu gem. Game Over hiện Rough Stone bằng màu `primary` và đặt PLAY AGAIN trước SHARE theo mockup M-3.
- Test: `app_composition_test.dart`, `widget_test.dart`, `progress_repository_test.dart`, `test/ui/{splash_home,game_screen,legacy_widgets}_test.dart`, `ui_test_helpers.dart`.

**Sửa (chỉ định dạng, `dart format lib test`)**: `audio_controller.dart`, `level_config_service.dart`, `level_config_validator.dart`, `firebase_remote_config_client.dart`, `game_helpers.dart`, `block_generator.dart`, `board_logic.dart`, `block_model.dart`, `cell_model.dart`, `score_share_service.dart`, `particle_explosion.dart`, `game_button.dart`, `score_panel.dart`, cùng 9 file test của U1 (xem `source-manifest.json`).

## Quyết định chính

- **`GemTheme` là lớp tĩnh, không dùng Provider**: màu chỉ phụ thuộc vào gem của level đang hiển thị, nên mỗi màn tự gọi `GemTheme.forGem(level.gemId)`.
- **Ảnh nền**: asset luôn hiện ngay. Ảnh mạng đè lên và fade in 300ms. Ảnh mạng lỗi thì giữ asset. Asset lỗi thì chỉ còn gradient. `BackgroundImageService.instance` dùng lại provider cho cùng URL trong phiên.
- **Font**: Montserrat chỉ có bản variable, nên mỗi style đặt cả `fontWeight` lẫn trục `wght`.
- **Khóa portrait** ở cả Dart, Android và iOS (iPad giữ nguyên cấu hình cũ).

## Lệch so với kế hoạch

- **`google_fonts` vẫn còn trong `pubspec.yaml`**: người dùng từ chối việc gỡ nó và chọn "giữ `google_fonts`, chỉ thêm `cached_network_image`". Code không còn import `google_fonts`; font được đóng gói nên vẫn chạy offline.
- **Cách thực thi**: tiếp tục để orchestrator tự viết code vì developer subagent không có công cụ, như đã thống nhất ở U2.
- **AC7.2.3**: `cached_network_image` không export `BaseCacheManager`, nên việc "không tải lại" được kiểm qua seam `NetworkImageFactory` (provider được dùng lại, factory không bị gọi lần hai). Cache trên đĩa là hành vi của thư viện. Kế hoạch đã ghi trước giả định này.
- **`nextLevelFor` / `upcomingLevel`**: kế hoạch có yêu cầu precache level N+1 nhưng chưa ghi chỗ sửa ở lớp logic. Đây là hai getter nhỏ, chỉ đọc catalog.
- **`game_board.dart`** cũng dùng `ThemeManager` (kế hoạch chỉ nêu `BoardCell` và `DraggableBlock`), nên được sửa cùng.
- **`dart format lib test`** định dạng lại cả file ngoài U4. Các file đó đã được liệt kê trong manifest.
- **Test grep Daily Gift** phân biệt hoa thường và chỉ tìm định danh code hoặc chuỗi UI cũ, để không bắt nhầm chú thích có nhắc FR10.2.

## Việc còn lại cho người dùng

- Chạy `flutter pub get` trên Windows trước khi build, vì Flutter Linux đã ghi đè `.dart_tool/package_config.json`.
- `assets/design` hiện nặng **25MB**. NFR5 khuyến nghị ≤ 10MB; việc nén ảnh do bạn quyết định.
- Kiểm tra trên máy thật: xoay máy thì app vẫn dọc; tắt mạng thì vẫn thấy ảnh và font đúng; Home đổi màu theo gem.
- `lib/core/utils/game_helpers.dart`, `lib/shared/widgets/game_button.dart` và `lib/shared/widgets/score_panel.dart` là file một dòng trống, không ai import. Có thể xóa khi tiện.
