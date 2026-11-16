# Code Structure — Block Crush

## Cây thư mục `lib/` (khoảng 1.800 dòng Dart)

```
lib/
├── main.dart                     (19)  entry: init audio, MultiProvider(ThemeManager)
├── app.dart                      (17)  BlockBlastApp → MaterialApp(home: HomeScreen)
├── core/
│   ├── audio/audio_controller.dart       (61)  static SFX player
│   ├── constants/colors.dart             (22)  AppColors
│   ├── constants/game_constants.dart     (5)   boardSize=8, spacing, padding
│   ├── theme/app_theme.dart              (47)  darkTheme + google_fonts
│   ├── theme/theme_manager.dart          (59)  ChangeNotifier, 3 theme, lưu theme_index
│   ├── utils/game_helpers.dart           (0)   RỖNG
│   └── widgets/animated_background.dart  (81)  gradient + particle painter
├── features/
│   ├── game/
│   │   ├── controllers/game_controller.dart  (0)   RỖNG
│   │   ├── logic/board_logic.dart            (145) đặt khối, xóa dòng, bomb, kiểm tra nước đi
│   │   ├── logic/block_generator.dart        (124) sinh 3 khối (small/medium/large, ice/bomb)
│   │   ├── models/block_model.dart           (25)
│   │   ├── models/cell_model.dart            (28)
│   │   ├── screens/game_screen.dart          (395) GameMode enum + toàn bộ state ván chơi
│   │   └── widgets/ block_palette, board_cell, draggable_block, game_board, particle_explosion (không dùng)
│   └── home/screens/home_screen.dart         (283) mode cards, Daily Gift, Settings sheet
└── shared/widgets/ game_button.dart (0), score_panel.dart (0)   RỖNG
```

## Phân loại file

| Loại | File |
|------|------|
| Entry/app | `main.dart`, `app.dart` |
| Screen (stateful, chứa logic) | `game_screen.dart`, `home_screen.dart` |
| Logic thuần (static) | `board_logic.dart`, `block_generator.dart` |
| Model | `block_model.dart`, `cell_model.dart` |
| Widget trình bày | `game_board.dart`, `board_cell.dart`, `block_palette.dart`, `draggable_block.dart`, `animated_background.dart` |
| Service/state | `theme_manager.dart`, `audio_controller.dart` |
| Rỗng / dead code | `game_controller.dart`, `game_helpers.dart`, `game_button.dart`, `score_panel.dart`, `particle_explosion.dart` (không dùng) |

## Pattern

- Feature-first folders, nhưng thư mục `controllers/` chưa được dùng.
- Widget đọc theme bằng `context.watch<ThemeManager>()`.
- Animation dùng extension `.animate()` của `flutter_animate`.
- Hằng số tập trung ở `core/constants`.

## Assets

```
assets/
├── icon.png
├── sounds/ clear.wav, combo.wav, gameover.wav, place.wav      (đã khai báo)
└── design/Level1..Level6/ 1..6.jpg + "Level N - <Gem>.txt"     (CHƯA khai báo trong pubspec)
```
`Level1` = Rose Quartz, `Level2` = Amethyst, `Level3` = Blue Topaz, `Level4` = Emerald, `Level5` = Sapphire, `Level6` = Ruby. Ảnh `1..6` tương ứng các bước (Bước 1–6) trong file prompt `.txt`, theo thứ tự Rough Stone … Bling. Mỗi ảnh khoảng 700KB, tổng khoảng 25MB.

## Nền tảng

`android/` (Gradle KTS, `MainActivity.kt` ở `kotlin/com/example/block_blast/`), `ios/` (Runner, deployment target 13.0), cùng `web/`, `linux/`, `macos/`, `windows/` là scaffold Flutter mặc định.
