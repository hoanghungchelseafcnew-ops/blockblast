# API Documentation

Ứng dụng không có API HTTP tự viết. Bề mặt bên ngoài:

## Firebase Remote Config
- `RemoteConfigClient` (lib/core/config/remote_config_client.dart), bản thật `FirebaseRemoteConfigClient`.
- `LevelConfigService` tải và kiểm tra cấu hình bằng `LevelConfigValidator`; lỗi thì dùng `default_level_config.dart` (`ConfigSource` ghi nguồn).

## Firebase Analytics
- `AnalyticsService` (abstract) với `NoopAnalyticsService` và `FirebaseAnalyticsService` (qua `AnalyticsClient`).

## Hợp đồng nội bộ chính
- `BlockSource = List<BlockModel> Function()` — nguồn khay 3 khối của `BoardEngine`.
- `BoardEngine`: `reset({startScore})`, `place(block,row,col) → TurnResult?`, `applyClear()`, `refillTrayIfEmpty()`, `hasMoves`.
- `JourneyOutcome` (nextLevel, highestLevelReached, unlockedGemId, journeyCompleted) → `VictoryVariant.of`.
- `ScoreShareService.shareScore({ScreenshotController screenshot, int score})`.
- `ProgressStore` (SharedPreferences) qua `ProgressRepository`.
