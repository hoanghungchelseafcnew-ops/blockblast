# Hướng dẫn test — U2 `u2-level-rules`

## Chiến lược

- Test strategy: **standard** (5–8 test mỗi component, unit test cộng integration cho ranh giới chính). Phương pháp: **test-after**. Mỗi lớp được implement trước, rồi viết và chạy test của lớp đó.
- Máy của AI đã có Flutter Linux 3.41.5, nên AI tự chạy các lệnh dưới đây. Người dùng có thể chạy lại trên máy của mình để đối chiếu.

## Thiết lập test

- Framework: `flutter_test` (đã có trong `dev_dependencies`). Không thêm thư viện mock: dùng lại các fake viết tay trong `test/fakes/` (`FakeProgressStore`, `FakeClock`, `LogCapture`).
- `FakeProgressStore` được bổ sung `remove(key)` và danh sách key bị gỡ, để kiểm tra việc gỡ key cũ và giả lập lỗi khi gỡ.
- Cấu trúc thư mục test:
  - `test/features/journey/high_scores_test.dart` — model `HighScores` (mới)
  - `test/features/journey/progress_repository_test.dart` — bổ sung `high_scores` và gỡ key cũ
  - `test/features/journey/journey_controller_test.dart` — bổ sung thắng Bling, level 36, thua, high score
  - `test/features/journey/level_game_controller_test.dart` — nhánh thua, QUIT, `bestScore`, bỏ REVIVE
  - `test/ui/game_screen_test.dart` — `QuitDialog`, Game Over mới, BEST trên header

## Lệnh chạy (phạm vi U2)

Lệnh mốc trước khi sửa (đã runnable):

```bash
flutter test test/features/journey/
```

Lệnh theo lớp của U2 (chạy từ gốc dự án):

```bash
flutter test test/features/journey/high_scores_test.dart
flutter test test/features/journey/progress_repository_test.dart
flutter test test/features/journey/journey_controller_test.dart test/features/journey/level_game_controller_test.dart
flutter test test/ui/game_screen_test.dart
```

Lệnh kiểm chứng của checkpoint (Construction Verification Command đã duyệt):

```bash
flutter analyze && flutter test --coverage
```

Xem coverage theo file trong `coverage/lcov.info`.

## Mục tiêu coverage

- Mọi file Dart mà U2 **tạo mới hoặc sửa** có coverage dòng **≥ 80%** (DoD-2).
- `flutter analyze` không có lỗi hay cảnh báo (DoD-5).
- Không hạ ngưỡng nào để một bước đạt. Nếu một file không đạt, ghi rõ con số và lý do trong `code-summary.md`.

## Danh mục test chính

| Component | Nội dung bắt buộc |
|-----------|-------------------|
| `HighScores` | JSON hợp lệ; JSON hỏng → null; key ngoài 1..36 bị bỏ; giá trị âm, thập phân hoặc chuỗi bị bỏ; trường lạ bị bỏ qua; `withScore` không giảm |
| `PlayerProgress.withoutGem` | bỏ đúng 6 sub của gem; giữ gem khác; gem chưa có sub nào hoàn thành thì không đổi |
| `ProgressRepository` | `high_scores` thiếu/hỏng → rỗng; đọc đúng; ghi thấp hơn bị bỏ; FIFO với `progress`; ghi lỗi → dirty → ghi lại; `flushDirty`; chỉ đọc bỏ qua ghi; gỡ `high_score`, `high_score_time`; lỗi gỡ chỉ log |
| `JourneyController` | thắng Bling mở khóa và sang gem kế; level 36 journey complete; AC1.4.1..AC1.4.4; `highestLevelReached` không giảm; high score khi thắng/thua; ghi lỗi vẫn trả outcome; chuyển level đúng cho cả 36 level |
| `LevelGameController` | thua gọi `onLevelLost` đúng một lần; thắng ưu tiên hơn hết nước đi; timeout 3s khi thua; PLAY AGAIN ở Rough Stone; `bestScore`; back khi playing không thoát, `confirmQuit` thoát mà không đổi tiến trình; input bị bỏ qua khi `lost`; không còn REVIVE |
| UI (widget test) | dialog "Quit this level?" với CANCEL/QUIT; CANCEL giữ điểm; QUIT rời màn; Game Over có Target và dòng "You will return to …", không có REVIVE; PLAY AGAIN; SHARE; BEST trên header; nút ≥ 48dp |

## Mocking và dữ liệu test

- Lưu trữ: `FakeProgressStore` với `initial`, `failingKeys` và `writeDelay` để giả lập ghi lỗi và kiểm tra thứ tự.
- Catalog: dựng `LevelCatalog` từ `DefaultLevelConfig` (36 level thật), như test của U1.
- Thời gian: `resolveTimeout` của `LevelGameController` được tiêm để kiểm tra timeout mà không chờ thật.
- Không có test nào luôn đúng. Mỗi test kiểm một hành vi cụ thể.
