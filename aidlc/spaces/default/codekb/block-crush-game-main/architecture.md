# Architecture

## Kiểu kiến trúc
Ứng dụng Flutter một module, feature-first, state bằng `provider` (ChangeNotifier). Logic thuần nằm trong `engine/` và `logic/`; screen chỉ render. Firebase và SharedPreferences nằm sau interface (`RemoteConfigClient`, `ProgressStore`, `AnalyticsService`).

## Sơ đồ thành phần
```mermaid
flowchart TD
  main[main.dart] --> comp[app_composition.dart]
  comp --> app[BlockBlastApp]
  app --> splash[SplashScreen]
  splash --> boot[AppBootstrap]
  boot --> rc[LevelConfigService / Remote Config]
  boot --> prog[ProgressRepository]
  splash --> home[HomeScreen]
  home --> gs[GameScreen]
  home --> es[EndlessGameScreen]
  gs --> lgc[LevelGameController]
  es --> egc[EndlessGameController]
  lgc --> eng[BoardEngine]
  egc --> eng
  eng --> gen[TrayGenerator]
  eng --> tr[TurnResolver]
  tr --> bl[BoardLogic]
  gs --> vo[VictoryOverlay]
  gs --> go[GameOverOverlay]
  go --> share[ScoreShareService]
```
Văn bản: main → app_composition → BlockBlastApp → SplashScreen (AppBootstrap) → HomeScreen → GameScreen/EndlessGameScreen → controller → BoardEngine → TrayGenerator/TurnResolver/BoardLogic.

## Interaction Diagrams
### Một lượt đặt khối (Journey)
```mermaid
sequenceDiagram
  participant U as Người chơi
  participant G as GameScreen
  participant C as LevelGameController
  participant E as BoardEngine
  U->>G: kéo thả khối
  G->>C: placeAt(row, col)
  C->>E: place(block, row, col)
  E-->>C: TurnResult (điểm, dòng xóa)
  alt score >= target
    C->>C: _resolve(won) → JourneyOutcome
    C-->>G: status won → VictoryOverlay
  else còn chơi
    C->>E: applyClear, refillTrayIfEmpty
    alt không còn nước đi (hasMoves = false)
      C-->>G: status lost → GameOverOverlay
    end
  end
```
### Chia sẻ ảnh (hiện chỉ ở Game Over)
GameOverOverlay.onShare → ScoreShareService.shareScore(ScreenshotController, score) → capture → ghi score.png → Share.shareXFiles.

## Dòng dữ liệu
Remote Config → LevelConfigService → LevelCatalog (36 Level) → JourneyController. Tiến trình: JourneyController ↔ ProgressRepository ↔ SharedPreferences.

## Quyết định thiết kế đáng chú ý
- `BoardEngine` không biết level hay mốc điểm; nguồn khối là `BlockSource = List<BlockModel> Function()`.
- Điểm thắng được kiểm tra ngay sau khi tính điểm, trước animation xóa dòng.
- `pubspec.yaml` hiện không còn `flutter_native_splash`; chỉ còn `SplashScreen` trong code (xác nhận ở lần quét 261125).

## Cơ hội cải thiện
- Lần quét 261125 thấy `BlockGenerator` đã được thay bằng `TrayGenerator` cùng `TraySolver` và `DifficultyProfile` (`lib/features/game/logic/`); nhận định cũ rằng generator tĩnh không còn đúng.
- Tên game hiển thị xuất hiện ở nhiều nơi (`MaterialApp.title`, Android label, iOS `CFBundleDisplayName`, `ScoreShareService.gameName`), chưa có một hằng số trung tâm.

## Luồng thua ván (quan trọng cho reward ads)
```mermaid
sequenceDiagram
  participant C as LevelGameController
  participant J as JourneyController
  participant P as ProgressRepository
  participant G as GameScreen
  C->>C: hết nước đi, _resolve(won false)
  C->>P: saveLevelSession(null)
  C->>J: onLevelLost(level, score)
  J->>P: savePlayerProgress(đã hạ về level đầu của viên đá), saveHighScore
  C-->>G: status lost, outcome.nextLevel = returnLevel
  G->>G: hiện GameOverOverlay
```
Nghĩa là phiên chơi đã bị xóa và tiến trình đã bị hạ **trước khi** lớp phủ Game Over hiện. Reward ads kiểu "xóa sạch ô và chơi tiếp ở level đó" cần chặn hoặc hoàn tác hai bước lưu này (`level_game_controller.dart`, `journey_controller.dart`). `playAgain()` chỉ chạy khi `status == lost` và gọi `start(outcome.nextLevel ?? returnLevel)`.

## Điểm gắn cho intent 261125-ads-remote-config
- **Khởi tạo**: `AppBootstrap.run` (hạn chót 3,5 giây) dựng `AppServices`; dịch vụ quảng cáo và phiên bản nên cùng chỗ hoặc ngay sau.
- **Cấu hình**: `RemoteConfigClient` chỉ đọc khóa `level_config`, với `minimumFetchInterval` 12 giờ và `fetchTimeout` 2 giây (`firebase_remote_config_client.dart`).
- **Màn chơi**: `GameScreen` là `Stack` gồm nền, `Column` trong `SafeArea` (header, vùng combo cao 44, `Expanded` bảng và khay), và các lớp phủ.
- **Đếm Start**: `HomeScreen._startGame` (và `_startEndless`) tạo controller rồi `Navigator.push`.
- **Chia sẻ**: `ScoreShareService.scoreShareText` và `victoryShareText`.
