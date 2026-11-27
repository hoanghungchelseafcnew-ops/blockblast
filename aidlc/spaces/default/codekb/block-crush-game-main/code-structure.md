# Code Structure

Tổng cộng khoảng 6.600 dòng Dart trong `lib/` (73 tệp) và khoảng 10.800 dòng trong `test/` (xác nhận ở lần quét 261125).

```
lib/
  main.dart, app.dart, app_composition.dart
  core/{analytics,audio,config,constants,firebase,log,theme,utils}
  features/
    endless/{controllers,models,screens}
    game/{engine,logic,models,screens,services,widgets}
    home/screens
    journey/{controllers,models,services}
    splash/screens
    victory/{models,widgets}
  shared/widgets
test/  (phản chiếu cấu trúc lib, thêm fakes/, fixtures/, ui/)
```

## Phân loại file
- **Logic thuần**: `engine/*`, `logic/*`, `core/config/*`, `journey/models`, `victory/models`.
- **Controller**: `LevelGameController`, `EndlessGameController`, `JourneyController`.
- **Service/Repository**: `ProgressRepository`, `AppBootstrap`, `BackgroundImageService`, `ScoreShareService`, `GameFeedback`.
- **UI**: `screens/*`, `widgets/*`, `shared/widgets/*`.

## Mẫu code
- Interface trừu tượng + bản `Noop`/fake để test (`AnalyticsService`, `ProgressStore`, `SfxPlayer`, `ScoreShareService`).
- Tiêm phụ thuộc qua constructor, composition ở `app_composition.dart`.
- Doc comment bằng tiếng Việt, tham chiếu mã yêu cầu (FR, BR, AC).

## Ghi chú lần quét 261125
- Có 3 tệp chỉ 1 dòng, có vẻ là phần còn sót: `lib/shared/widgets/game_button.dart`, `lib/shared/widgets/score_panel.dart`, `lib/core/utils/game_helpers.dart`.
- Vị trí các điểm cần sửa cho quảng cáo: `lib/features/home/screens/home_screen.dart`, `lib/features/game/screens/game_screen.dart`, `lib/features/game/widgets/game_over_overlay.dart`, `lib/features/endless/screens/endless_game_screen.dart`, `lib/features/game/services/score_share_service.dart`, `lib/core/firebase/*`, `lib/core/config/remote_config_client.dart`, `lib/features/journey/services/app_bootstrap.dart`.
