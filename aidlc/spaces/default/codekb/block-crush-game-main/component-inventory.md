# Component Inventory

## BlockBlastApp
MaterialApp gốc (title 'Block Crush'); nhận `AppBootstrap`. Phụ thuộc: SplashScreen.
## SplashScreen
Splash trong code: logo, 'BLOCK CRUSH', '◆ Gemstone Journey ◆', chờ bootstrap rồi sang HomeScreen.
## HomeScreen
Menu chính, chọn Journey hoặc Endless; theo dõi vòng đời phiên.
## GameScreen
Màn chơi level; bọc `Screenshot`, hiện Victory/GameOver/Tutorial overlay. Phụ thuộc: LevelGameController, ScoreShareService.
## EndlessGameScreen
Màn chơi endless với cơ chế chia sẻ tương tự.
## LevelGameController
Trạng thái level (`LevelStatus`), điểm, mốc, combo, thắng/thua. Phụ thuộc: BoardEngine, JourneyController, ProgressRepository, GameFeedback.
## EndlessGameController
Trạng thái endless. Phụ thuộc: BoardEngine.
## JourneyController
Tiến trình 36 level, `JourneyOutcome`, level kế. Phụ thuộc: LevelCatalog, ProgressRepository.
## BoardEngine
Bảng 8×8, khay 3 khối, điểm, combo. Phụ thuộc: BlockGenerator, TurnResolver, BoardLogic.
## BlockGenerator
Sinh 3 khối (tĩnh, ngẫu nhiên, 30/50/20 nhỏ/vừa/lớn, 5% băng, 5% bom).
## BoardLogic
`canPlaceBlock`, `placeBlock`, `clearCompletedLines`, `applyClearAnimated`, `canPlaceAnyBlock`.
## TurnResolver
Tính điểm lượt: 10 điểm/ô, 100 điểm/dòng nhân combo.
## BoardGeometry
Đổi tọa độ chạm thành ô lưới.
## VictoryOverlay
Màn thắng 3 biến thể; ConfettiLayer, GemUnlockAnimation.
## GameOverOverlay
Điểm, target, nút Share, Play again, Menu.
## ScoreShareService
Chụp ảnh và mở share sheet (`PlatformScoreShareService`).
## LevelCatalog
Dựng 36 `Level` từ `LevelConfig`.
## LevelConfigService
Tải và kiểm tra cấu hình Remote Config, fallback mặc định.
## ProgressRepository
Lưu tiến trình, điểm cao, cờ tutorial, âm thanh.
## AudioController
Phát hiệu ứng âm thanh (`Sfx`).
## GemTheme
Bảng màu theo gem (`GemPalette`).
## AppBootstrap
Khởi tạo Firebase, cấu hình, tiến trình; có timeout 3,5 giây ở splash.
