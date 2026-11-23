# Code Structure

Tổng cộng khoảng 6.400 dòng Dart trong `lib/` và 7.700 dòng trong `test/`.

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
