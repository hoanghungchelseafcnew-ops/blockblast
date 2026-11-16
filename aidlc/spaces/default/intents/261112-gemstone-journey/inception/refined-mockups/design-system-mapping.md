# Design System Mapping — Gemstone Journey

## Sources

- [code] `lib/core/theme/app_theme.dart`, `lib/core/constants/colors.dart`, `lib/core/theme/theme_manager.dart`
- [req] `inception/requirements-analysis/requirements.md` (FR12, NFR6, NFR9)
- [stories] `inception/user-stories/stories.md` (US5.4, US8.6)
- [Q1]–[Q7] `refined-mockups-questions.md`

## Typography (giữ của app hiện tại, đóng gói offline) [code] [Q4]

| Token | Font | Size | Weight | Dùng cho |
|-------|------|------|--------|---------|
| `display` | Righteous | 36–60 | regular | Tiêu đề Home, "JOURNEY COMPLETE!" |
| `headline` | Righteous | 28 | regular | "Level Complete!", "GAME OVER", "Quit this level?" |
| `title` | Montserrat | 20 | w700 | Nhãn nút (PLAY, CONTINUE), tên level |
| `body` | Montserrat | 16–18 | w600 | Nội dung, điểm |
| `caption` | Montserrat | 14 | w500 | BEST, % tiến độ |

- Font được đóng gói trong `assets/fonts/` (Righteous-Regular.ttf, Montserrat variable hoặc các weight 500/600/700), khai báo trong `pubspec.yaml`. Đặt `GoogleFonts.config.allowRuntimeFetching = false`. [Q4]

## Gem color tokens (thay `ThemeManager`) [req FR12] [Q5]

| Gem | `gemPrimary` | `gemSecondary` | `onGemPrimary` (chữ trên nút) |
|-----|-------------|----------------|-------------------------------|
| Rose Quartz | `#FFB6C1` | `#FF69B4` | `#151525` (tương phản 10.9:1) |
| Amethyst | `#9966CC` | `#8B008B` | `#FFFFFF` (4.10:1, đạt mức chữ lớn ≥3:1, nhãn nút 20 w700) |
| Blue Topaz | `#4FC3F7` | `#0288D1` | `#151525` (8.99:1) |
| Emerald | `#50C878` | `#228B22` | `#151525` (8.47:1) |
| Sapphire | `#0F52BA` | `#000080` | `#FFFFFF` (7.15:1) |
| Ruby | `#E0115F` | `#8B0000` | `#FFFFFF` (4.76:1) |

Tỉ lệ tương phản tính theo công thức WCAG 2.x.

| Áp dụng màu đá quý | Không áp dụng |
|-------------------|---------------|
| Gradient nền (`gemSecondary` → `#0F0C29`), nền nút chính (`gemPrimary`), thanh tiến độ, glow, confetti, viền focus | Khối và ô trên bảng (giữ màu ngẫu nhiên của `BlockGenerator`) [Q5] |

## Nền [Q6]

- `LevelBackground` thay cho `AnimatedBackground`: ảnh nền (asset hoặc mạng) được blur `sigma 12` và phủ lớp `#000000` opacity 0.5. Không còn hạt chuyển động.
- Màn Victory dùng ảnh rõ nét, không blur, với lớp phủ gradient dưới đáy (0 → 0.7) để chữ dễ đọc.
- Home dùng ảnh của level hiện tại (blur) kèm gradient màu đá quý.

## Component mapping

| Component mới / sửa | Dựa trên | Ghi chú |
|---------------------|----------|---------|
| `GemPrimaryButton` (PLAY, CONTINUE, PLAY AGAIN) | `ElevatedButton` + `AppTheme.elevatedButtonTheme` | Nền `gemPrimary`, chữ `onGemPrimary`, bo góc 20, cao ≥ 56dp |
| `SecondaryTextButton` (BACK TO MENU, CANCEL) | `TextButton` hiện có | Chữ `white70`, vùng chạm ≥ 48dp |
| `LevelHeader` | `_buildHeader()` trong `game_screen.dart` | Thêm tên level, target, thanh tiến độ |
| `LevelProgressBar` | mới (`LinearProgressIndicator` tùy biến) | Fill `gemPrimary`, track `#FFFFFF1F`, **viền trắng 1.5dp** để đạt tương phản UI ≥ 3:1 với Sapphire và Ruby |
| `QuitDialog` | `AlertDialog` với style như Daily Gift cũ (`#1C1C2E`) | |
| `GameOverOverlay` | `_buildGameOverOverlay()` hiện có | Bỏ REVIVE, thêm Target và thông báo quay về |
| `VictoryScreen`, `GemUnlockAnimation`, `ConfettiLayer` | mới. Tái dùng `ParticleExplosion` cho confetti | `flutter_animate` cho glow, scale và rotate |
| `JourneyCompleteScreen` | biến thể của `VictoryScreen` | Không có CONTINUE |
| `SplashGate` | mới | Logo `assets/icon.png`, chờ tối đa 2 giây [Q7] |
| Settings sheet | `_openSettings()` hiện có | Bỏ phần THEME |

## Assumptions & Open Questions

- [assumption] Tên token (`gemPrimary`, ...) là đề xuất. Tên cuối cùng sẽ chốt ở bước Code Generation.
