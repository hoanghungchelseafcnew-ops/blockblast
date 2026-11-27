# Component Inventory

## BlockBlastApp
MaterialApp gốc (title 'Block Jewel'); nhận `AppBootstrap`. Phụ thuộc: SplashScreen.
## SplashScreen
Splash trong code: chờ bootstrap (hạn chót 3,5 giây) rồi sang HomeScreen.
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
Tiến trình 36 level, `JourneyOutcome`, level kế, `onLevelWon`, `onLevelLost` và `returnLevelFor` (về level đầu của viên đá hiện tại khi thua). Phụ thuộc: LevelCatalog, ProgressRepository.
## BoardEngine
Bảng 8×8, khay 3 khối, điểm, combo. Phụ thuộc: TrayGenerator, TurnResolver, BoardLogic.
## TrayGenerator
Sinh khay 3 khối (`lib/features/game/logic/tray_generator.dart`), dùng `TraySolver` và `DifficultyProfile`. Các tỉ lệ khối của lần quét trước chưa được kiểm lại ở lần quét 261125.
## BoardLogic
`canPlaceBlock`, `placeBlock`, `clearCompletedLines`, `applyClearAnimated`, `canPlaceAnyBlock`.
## TurnResolver
Tính điểm lượt: 10 điểm/ô, 100 điểm/dòng nhân combo.
## BoardGeometry
Đổi tọa độ chạm thành ô lưới.
## VictoryOverlay
Màn thắng 3 biến thể; ConfettiLayer, GemUnlockAnimation.
## GameOverOverlay
Điểm, target, nút PLAY AGAIN, SHARE SCORE, BACK TO MENU và dòng 'You will return to' (journey); biến thể `.endless` hiện BEST.
## ScoreShareService
Chụp ảnh và mở share sheet (`PlatformScoreShareService`); văn bản chia sẻ nằm trong `scoreShareText` và `victoryShareText`.
## LevelCatalog
Dựng 36 `Level` từ `LevelConfig`.
## LevelConfigService
Tải và kiểm tra cấu hình Remote Config (khóa `level_config`), fallback mặc định.
## ProgressRepository
Lưu tiến trình, điểm cao, cờ tutorial, âm thanh.
## AudioController
Phát hiệu ứng âm thanh (`Sfx`).
## GemTheme
Bảng màu theo gem (`GemPalette`).
## AppBootstrap
Khởi tạo Firebase, cấu hình, tiến trình; có timeout 3,5 giây ở splash.
## FirebaseRemoteConfigClient
Cài đặt `RemoteConfigClient` bằng `FirebaseRemoteConfig`; `fetchTimeout` 2 giây, `minimumFetchInterval` 12 giờ.
## FirebaseGateway
Khởi tạo Firebase với hạn chót 1,5 giây, trả `FirebaseStatus` (ok, failed, timeout).
