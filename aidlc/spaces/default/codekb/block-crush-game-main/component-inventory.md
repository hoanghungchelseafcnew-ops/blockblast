# Component Inventory — Block Crush

## BlockBlastApp
- **File**: `lib/app.dart`
- **Trách nhiệm**: MaterialApp, theme tối, màn hình đầu tiên là `HomeScreen`
- **Phụ thuộc**: AppTheme, HomeScreen

## HomeScreen
- **File**: `lib/features/home/screens/home_screen.dart`
- **Trách nhiệm**: hai thẻ chế độ chơi (Classic, Time Attack) kèm BEST, popup Daily Gift, bottom sheet Settings (mute, theme), điều hướng sang GameScreen
- **Phụ thuộc**: ThemeManager, AudioController, AnimatedBackground, SharedPreferences, GameScreen

## GameScreen
- **File**: `lib/features/game/screens/game_screen.dart`
- **Trách nhiệm**: toàn bộ state ván chơi (board, blocks, score, combo, timer, high score), kéo-thả, game over, revive, share, tutorial, header SCORE/BEST
- **Phụ thuộc**: BoardLogic, BlockGenerator, GameBoard, BlockPalette, AudioController, ThemeManager, AnimatedBackground, SharedPreferences, share_plus, screenshot, path_provider

## BoardLogic
- **File**: `lib/features/game/logic/board_logic.dart`
- **Trách nhiệm**: luật bảng (đặt khối, xóa dòng, bomb, kiểm tra còn nước đi)
- **Phụ thuộc**: CellModel, BlockModel, GameConstants

## BlockGenerator
- **File**: `lib/features/game/logic/block_generator.dart`
- **Trách nhiệm**: sinh ngẫu nhiên 3 khối mỗi lượt
- **Phụ thuộc**: BlockModel

## GameBoard
- **File**: `lib/features/game/widgets/game_board.dart`
- **Trách nhiệm**: render lưới 8×8
- **Phụ thuộc**: BoardCell, ThemeManager, GameConstants

## BoardCell
- **File**: `lib/features/game/widgets/board_cell.dart`
- **Trách nhiệm**: render một ô (filled, preview, ice, bomb) theo theme
- **Phụ thuộc**: ThemeManager

## BlockPalette
- **File**: `lib/features/game/widgets/block_palette.dart`
- **Trách nhiệm**: khay 3 khối
- **Phụ thuộc**: DraggableBlock

## DraggableBlock
- **File**: `lib/features/game/widgets/draggable_block.dart`
- **Trách nhiệm**: khối kéo-thả, phát callback vị trí
- **Phụ thuộc**: BlockModel, ThemeManager

## ParticleExplosion
- **File**: `lib/features/game/widgets/particle_explosion.dart`
- **Trách nhiệm**: hiệu ứng hạt nổ. **Không được sử dụng**
- **Phụ thuộc**: —

## AnimatedBackground
- **File**: `lib/core/widgets/animated_background.dart`
- **Trách nhiệm**: nền gradient có hạt chuyển động
- **Phụ thuộc**: —

## ThemeManager
- **File**: `lib/core/theme/theme_manager.dart`
- **Trách nhiệm**: theme Neon/Wood/Jewel, lưu `theme_index`
- **Phụ thuộc**: SharedPreferences, AppColors

## AudioController
- **File**: `lib/core/audio/audio_controller.dart`
- **Trách nhiệm**: phát SFX, mute trong bộ nhớ
- **Phụ thuộc**: audioplayers

## AppTheme
- **File**: `lib/core/theme/app_theme.dart`
- **Trách nhiệm**: ThemeData tối, font chữ
- **Phụ thuộc**: google_fonts

## Models
- **File**: `lib/features/game/models/block_model.dart`, `cell_model.dart`
- **Trách nhiệm**: `BlockModel` (shape, color, ice, bomb), `CellModel` (filled, preview, clearing, ice, bomb, các màu)
- **Phụ thuộc**: —

## Placeholder rỗng
- **File**: `game_controller.dart`, `game_helpers.dart`, `game_button.dart`, `score_panel.dart`
- **Trách nhiệm**: chưa có (0 dòng)
- **Phụ thuộc**: —
