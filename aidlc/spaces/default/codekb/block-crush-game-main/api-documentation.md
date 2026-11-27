# API Documentation

Ứng dụng không có API HTTP tự viết. Bề mặt bên ngoài:

## Firebase Remote Config
- `RemoteConfigClient` (lib/core/config/remote_config_client.dart) có ba phương thức: `configure()`, `fetchAndActivate()`, `readLevelConfig()`. Khóa duy nhất hiện có là `level_config` (JSON). Bản thật `FirebaseRemoteConfigClient` đặt `fetchTimeout` 2 giây, `minimumFetchInterval` 12 giờ, và chỉ trả giá trị khi nguồn là remote.
- `LevelConfigService` tải và kiểm tra cấu hình bằng `LevelConfigValidator`; lỗi thì dùng `default_level_config.dart` (`ConfigSource` ghi nguồn).

## Firebase Analytics
- `AnalyticsService` (abstract) với `NoopAnalyticsService` và `FirebaseAnalyticsService` (qua `AnalyticsClient`).

## Hợp đồng nội bộ chính
- `BlockSource = List<BlockModel> Function()` — nguồn khay 3 khối của `BoardEngine`.
- `BoardEngine`: `reset({startScore})`, `place(block,row,col) → TurnResult?`, `applyClear()`, `refillTrayIfEmpty()`, `hasMoves`.
- `JourneyOutcome` (nextLevel, highestLevelReached, unlockedGemId, journeyCompleted) → `VictoryVariant.of`.
- `ScoreShareService.shareScore({ScreenshotController screenshot, int score})`.
- `ProgressStore` (SharedPreferences) qua `ProgressRepository`.

## Chia sẻ
- `ScoreShareService.scoreShareText(score)` trả "I scored $score in Block Jewel!" và `victoryShareText(levelName, score)` trả "I cleared $levelName with $score points in Block Jewel!". Hai hàm tĩnh này là nơi duy nhất đặt nội dung chia sẻ, và `PlatformScoreShareService` gửi ảnh chụp kèm văn bản qua `Share.shareXFiles`.

## Analytics (`AnalyticsService`)
`logLevelStart`, `logLevelComplete`, `logLevelFail`, `logGameSession`, `setConfigSource`, cộng thiết lập thuộc tính tiến độ. Chưa có sự kiện quảng cáo.

## Quảng cáo
Chưa có API nào.
