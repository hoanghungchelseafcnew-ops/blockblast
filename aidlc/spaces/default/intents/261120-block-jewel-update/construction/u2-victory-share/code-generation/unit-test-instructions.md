# Unit Test Instructions: u2-victory-share

Chiến lược Standard, test-after. Hai thành phần có hành vi: `ScoreShareService` (logic và I/O) và `VictoryOverlay`/`GameScreen` (giao diện).

## Khung test
- `flutter_test` (đã có). Kênh nền tảng `plugins.flutter.io/path_provider` và `dev.fluttercommunity.plus/share` được mock như test hiện có.
- `FakeShareService` trong `test/ui/ui_test_helpers.dart` ghi lại lời gọi.

## Lệnh chạy riêng cho unit này
```
flutter test test/features/game/services/score_share_service_test.dart test/features/victory/victory_overlay_test.dart test/ui/game_screen_test.dart
```

## Test cần có
- **ScoreShareService (5–8):** chuỗi `scoreShareText`, chuỗi `victoryShareText`; `shareVictory` không gắn widget thì không chia sẻ; chụp được thì ghi `victory.png` và gọi share với văn bản đúng; kênh share ném lỗi thì ghi log, không ném; `shareScore` vẫn dùng `score.png` và chuỗi mới.
- **VictoryOverlay (5–8):** SHARE ở biến thể sub, gemUnlock, journeyComplete; cao ≥ 48dp; ẩn khi không có `onShare`; bấm hai lần khi đang chia sẻ chỉ gọi một lần; CONTINUE vẫn bấm được sau SHARE; `onShare` lỗi không làm hỏng màn.
- **GameScreen (3):** thắng rồi bấm SHARE gọi `shareVictory` đúng tên level và điểm; không bấm thì không gọi; Game Over SHARE vẫn gọi `shareScore`.

## Coverage
Toàn codebase tối thiểu 80% dòng (người dùng chạy `flutter test --coverage`).

## Mock và dữ liệu
Dùng `GameHarness`, `LevelCatalog.from(DefaultLevelConfig.config)` như test hiện có.
