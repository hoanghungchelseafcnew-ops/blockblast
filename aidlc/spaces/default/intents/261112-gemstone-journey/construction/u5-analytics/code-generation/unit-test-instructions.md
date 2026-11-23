# Hướng dẫn test — U5 `u5-analytics`

## Chiến lược

- Test strategy: **standard** (5–8 test mỗi component, unit test cộng integration cho ranh giới chính). Phương pháp: **test-after**. Mỗi lớp được implement trước, rồi viết và chạy test của lớp đó.
- AI chạy các lệnh dưới đây bằng Flutter Linux 3.41.5 trong WSL. Người dùng không build trên Windows cho tới khi U5 xong, sau đó chạy `flutter pub get` trên Windows.

## Thiết lập test

- Framework: `flutter_test`. Không thêm thư viện mock. Không gọi Firebase thật trong test.
- Fake viết tay:
  - `FakeAnalyticsClient`: ghi lại mọi `logEvent` và `setUserProperty`, có thể ném lỗi.
  - `FakeAnalytics implements AnalyticsService`: ghi lại các lời gọi ở mức service, dùng cho controller và session.
  - Dùng lại `FakeClock`, `FakeProgressStore`, `FakeSfxPlayer`, `LogCapture`.
- Cấu trúc thư mục test:
  - `test/core/analytics/analytics_names_test.dart` (mới)
  - `test/core/analytics/firebase_analytics_service_test.dart` (mới)
  - `test/core/analytics/session_tracker_test.dart` (mới)
  - `test/core/analytics/analytics_service_test.dart` (đã có, giữ nguyên)
  - `test/features/journey/progress_repository_test.dart`, `level_game_controller_test.dart`, `app_bootstrap_test.dart` (sửa)
  - `test/ui/splash_home_test.dart`, `test/ui/ui_test_helpers.dart` (sửa)

## Lệnh chạy (phạm vi U5)

Lệnh mốc trước khi sửa (đã runnable):

```bash
flutter test test/core/analytics/ test/features/journey/
```

Lệnh theo lớp của U5 (chạy từ gốc dự án):

```bash
flutter test test/core/analytics/analytics_names_test.dart
flutter test test/core/analytics/firebase_analytics_service_test.dart test/features/journey/progress_repository_test.dart
flutter test test/core/analytics/session_tracker_test.dart test/features/journey/level_game_controller_test.dart test/features/journey/app_bootstrap_test.dart
flutter test test/ui/splash_home_test.dart
```

Lệnh kiểm chứng của checkpoint (Construction Verification Command đã duyệt):

```bash
flutter analyze && flutter test --coverage
```

## Mục tiêu coverage

- Mọi file Dart mà U5 **tạo mới hoặc sửa** có coverage dòng **≥ 80%** (DoD-2). Phần bọc `FirebaseAnalytics.instance` (vài dòng) không chạy được trong test. Nếu nó làm `firebase_analytics_service.dart` dưới 80%, ghi rõ con số trong `code-summary.md`, không thêm `coverage:ignore`.
- Coverage dòng toàn codebase ≥ 80%.
- `flutter analyze` không có lỗi hay cảnh báo (DoD-5).

## Danh mục test chính

| Component | Nội dung bắt buộc |
|-----------|-------------------|
| `AnalyticsNames` / `levelParams` | tên đúng E2; tham số level 1 và 36; chỉ số ngoài 1..36 bị từ chối |
| `FirebaseAnalyticsService` | 4 event đúng tên và tham số; `score`/`target`; user property `current_major_level`, `highest_level_reached` (chuỗi), `config_source`; lỗi client chỉ log |
| `ProgressRepository` (`total_play_time`) | mặc định 0; giá trị âm/sai kiểu → 0 + log; cộng dồn và đọc lại; ≤ 0 bỏ qua; ghi lỗi → dirty |
| `SessionTracker` | 90 giây → event + `addPlayTime(90)`; `paused` hai lần đếm một lần; `resumed` mở phiên mới; 0 giây không gửi; lỗi lưu vẫn gửi event |
| `LevelGameController` (analytics) | `level_start` khi start; `level_complete` / `level_fail` một lần mỗi round; user property sau thắng/thua; Bling → gem kế; QUIT không có `level_fail` |
| `AppBootstrap` | Firebase ok → analytics thật + `setConfigSource`; Firebase lỗi → Noop |
| UI | vào nền ở Home → `game_session`; PLAY → `level_start` |

## Mocking và dữ liệu test

- Thời gian: `FakeClock` tiến tay (`advance`) để tính `duration_sec` chính xác.
- Catalog: `LevelCatalog` từ `DefaultLevelConfig`.
- Không có test nào luôn đúng. Mỗi test kiểm một hành vi cụ thể.
