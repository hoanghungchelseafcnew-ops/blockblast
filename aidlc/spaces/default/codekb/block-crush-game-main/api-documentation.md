# API Documentation — Block Crush

## External APIs

Không có. App không gọi network, không có backend, chưa tích hợp Firebase. Tương tác duy nhất với hệ điều hành là share sheet (`share_plus`), haptic (`HapticFeedback.heavyImpact`) và file tạm (`path_provider`).

## Internal APIs

### `BoardLogic` (`lib/features/game/logic/board_logic.dart`)

| Method | Signature | Mô tả |
|--------|-----------|-------|
| `createEmptyBoard` | `static List<List<CellModel>> createEmptyBoard()` | Tạo bảng `boardSize × boardSize` (8×8) |
| `canPlaceBlock` | `static bool canPlaceBlock(board, BlockModel, int row, int col)` | Kiểm tra biên và ô trống |
| `placeBlock` | `static void placeBlock(board, block, row, col)` | Đánh dấu ô `filled`, gán màu, cờ ice/bomb |
| `clearCompletedLines` | `static int clearCompletedLines(board)` | Đánh dấu `clearing` cho hàng/cột đầy, trả về số dòng |
| `applyClearAnimated` | `static Future<void> applyClearAnimated(board)` | Nổ bomb 3×3, đợi 180ms rồi xóa ô |
| `canPlaceAnyBlock` | `static bool canPlaceAnyBlock(board, List<BlockModel>)` | Còn nước đi hay không (điều kiện game over) |

### `BlockGenerator` (`logic/block_generator.dart`)

- `static List<BlockModel> generateThree()`: sinh 3 khối ngẫu nhiên từ nhóm small/medium/large, có xác suất là ice hoặc bomb.

### `AudioController` (`lib/core/audio/audio_controller.dart`)

| Member | Mô tả |
|--------|-------|
| `static Future<void> init()` | Rỗng (chưa preload) |
| `static bool get isMuted` / `static void toggleMute()` | Mute trong bộ nhớ, không lưu |
| `playPlace()`, `playClear()`, `playCombo()`, `playGameOver()` | Phát `assets/sounds/*.wav` qua một `_sfxPlayer` duy nhất. Lỗi bị nuốt |

### `ThemeManager` (`lib/core/theme/theme_manager.dart`), ChangeNotifier

- `AppThemeType currentTheme` (enum: `neon`, `wood`, `jewel`)
- `Future<void> setTheme(AppThemeType)`: lưu `theme_index`
- `List<Color> backgroundGradient`, `Color boardBackground`

### Screens

- `GameScreen({GameMode mode = GameMode.classic})`, với `enum GameMode { classic, timeAttack }` khai báo trong `game_screen.dart`.
- `HomeScreen()`: không có tham số.

### Widget contracts

- `GameBoard({required List<List<CellModel>> board})`
- `BlockPalette({required blocks, required onDragStart(BlockModel), required onDragUpdate(Offset), required onDragEnd()})`
- `AnimatedBackground({required List<Color> colors})`

## Persistence contract (SharedPreferences)

| Key | Kiểu | Ghi tại | Đọc tại |
|-----|------|---------|---------|
| `high_score` | int | `GameScreen._checkAndSaveHighScore` (classic) | Home, Game |
| `high_score_time` | int | như trên (timeAttack) | Home, Game |
| `theme_index` | int | `ThemeManager.setTheme` | `ThemeManager._loadTheme` |
| `last_login_date` | String `yyyy-MM-dd` | `Home._checkDailyReward` | như trên |
| `tutorial_completed` | bool | `GameScreen._completeTutorial` | `GameScreen._checkTutorial` |
