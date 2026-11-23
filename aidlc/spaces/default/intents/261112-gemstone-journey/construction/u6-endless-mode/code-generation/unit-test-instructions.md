# Hướng dẫn test — U6 `u6-endless-mode`

## Chiến lược

- Test strategy: **standard** (5–8 test mỗi component, unit test cộng integration cho ranh giới chính). Phương pháp: **test-after**. Mỗi lớp được implement trước, rồi viết và chạy test của lớp đó.
- AI chạy các lệnh dưới đây bằng Flutter Linux 3.41.5 trong WSL. Người dùng không build trên Windows cho tới khi U6 xong, sau đó chạy `flutter pub get` trên Windows.

## Thiết lập test

- Framework: `flutter_test`. Không thêm thư viện mock.
- Fake viết tay: dùng lại `FakeProgressStore`, `RecordingFeedback` (từ `level_game_controller_test.dart`, chép thành helper chung nếu cần), `FakeAnalytics`, `FakeClock`, `LogCapture`, `engine_test_helpers.dart` (`single`, `line`, `makeBlock`).
- Ca thua dựng bằng helper "bảng còn ô trống cô lập" đã có ở U1/U2.
- Cấu trúc thư mục test:
  - `test/features/endless/endless_state_test.dart` (mới)
  - `test/features/endless/endless_game_controller_test.dart` (mới)
  - `test/features/endless/endless_game_screen_test.dart` (mới)
  - `test/features/game/engine/board_engine_test.dart` (sửa: `reset(startScore:)`)
  - `test/features/journey/progress_repository_test.dart` (sửa: hai key endless)
  - `test/ui/splash_home_test.dart` (sửa: Home State C), `test/ui/game_screen_test.dart` (hồi quy kéo-thả)

## Lệnh chạy (phạm vi U6)

Lệnh mốc trước khi sửa (đã runnable):

```bash
flutter test test/features/game/engine/board_engine_test.dart test/ui/game_screen_test.dart
```

Lệnh theo lớp của U6 (chạy từ gốc dự án):

```bash
flutter test test/features/endless/endless_state_test.dart test/features/game/engine/board_engine_test.dart
flutter test test/features/journey/progress_repository_test.dart
flutter test test/features/endless/endless_game_controller_test.dart
flutter test test/features/endless/endless_game_screen_test.dart test/ui/
```

Lệnh kiểm chứng của checkpoint (Construction Verification Command đã duyệt):

```bash
flutter analyze && flutter test --coverage
```

## Mục tiêu coverage

- Mọi file Dart mà U6 **tạo mới hoặc sửa** có coverage dòng **≥ 80%** (DoD-2).
- Coverage dòng toàn codebase ≥ 80%.
- `flutter analyze` không có lỗi hay cảnh báo (DoD-5).
- Không hạ ngưỡng nào để một bước đạt. Nếu một file không đạt, ghi rõ con số và lý do trong `code-summary.md`.

## Danh mục test chính

| Component | Nội dung bắt buộc |
|-----------|-------------------|
| `EndlessState` / `BoardEngine.reset(startScore)` | high score không giảm; mặc định 0; bắt đầu với điểm đã lưu trên bảng trống; mặc định 0 cho chế độ level |
| `ProgressRepository` (endless) | thiếu key → 0; đọc đúng; âm/sai kiểu → 0 + log; lưu và đọc lại; lưu 0; ghi lỗi → dirty; chỉ đọc không ghi |
| `EndlessGameController` | ER2..ER7, ER10, ER14: bắt đầu từ điểm đã lưu; QUIT lưu (kể cả 0); pause lưu và vẫn chơi; thua → 0 + high score; high score không giảm; PLAY AGAIN từ 0; input bị khóa khi `lost`/`quit`; back khi lưu bị bỏ qua; lưu lỗi vẫn chuyển trạng thái |
| `EndlessGameScreen` | header endless không có target/progress; dialog "Quit?" + "Your score will be saved."; Game Over endless không có Target/dòng quay về; PLAY AGAIN; kéo-thả ghi điểm; vào nền lưu điểm; không có Victory |
| Home State C | "Journey Complete", 6 viên đá, "Endless · Best —" / "Endless · Best N"; PLAY mở endless với điểm đã lưu |
| Hồi quy | `game_screen_test.dart` xanh sau khi tách `BoardPlayArea` |

## Mocking và dữ liệu test

- Tiến trình "đã hoàn thành hành trình": key `progress` có `journeyCompleted: true`, `currentLevelIndex: 36`.
- Điểm endless: key `endless_saved_score` / `endless_high_score` trong `FakeProgressStore(initial: …)`.
- Không có test nào luôn đúng. Mỗi test kiểm một hành vi cụ thể.
