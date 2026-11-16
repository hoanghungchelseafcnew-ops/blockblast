# Hướng dẫn test — U1 `u1-journey-skeleton`

## Chiến lược

- Test strategy: **standard** (5–8 test mỗi component, unit test cộng integration cho ranh giới chính). Phương pháp: **test-after**. Mỗi lớp được implement trước, rồi viết test của lớp đó.
- AI viết code và test. **Người dùng chạy** lệnh trên máy có Flutter và báo kết quả (AI không chạy được `flutter`).

## Thiết lập test

- Framework: `flutter_test` (đã có trong `dev_dependencies`). Không thêm thư viện mock: dùng fake viết tay (`FakeRemoteConfigClient`, `FakeClock`, `FakeProgressStore`) và `SharedPreferences.setMockInitialValues`.
- Cấu trúc thư mục test:
  - `test/features/game/engine/` — `BoardEngine`, `TurnResolver`
  - `test/core/config/` — models, validator, `ImageUrlPolicy`, `DefaultLevelConfig`, `LevelConfigService`
  - `test/features/journey/` — `LevelCatalog`, `ProgressRepository`, `JourneyController`, `AppBootstrap`, `LevelGameController`
  - `test/ui/` — widget test cho Splash, Home, header, Victory tạm, Game Over
  - `test/widget_test.dart` — test khởi động app (sửa `MyApp` → `BlockBlastApp`)

## Lệnh chạy (phạm vi U1)

Lệnh đã runnable ngay từ bước đầu (sau khi sửa `widget_test.dart`):

```bash
flutter test test/widget_test.dart
```

Lệnh theo nhóm của U1 (chạy từ gốc dự án):

```bash
flutter test test/features/game/engine/
flutter test test/core/config/
flutter test test/features/journey/
flutter test test/ui/
```

Lệnh kiểm tra tổng cho điểm dừng CP-3 (đã được duyệt là Construction Verification Command):

```bash
flutter analyze && flutter test --coverage
```

Xem coverage theo từng file mới hoặc sửa trong `coverage/lcov.info`. Ví dụ: `lcov --list coverage/lcov.info` hoặc `genhtml coverage/lcov.info -o coverage/html`.

## Mục tiêu coverage

- Mọi file Dart mà U1 **tạo mới hoặc sửa**: coverage dòng **≥ 80%** (DoD-2).
- Ngưỡng 80% toàn codebase được đo ở Build & Test sau khi xong cả 6 unit (U4 bổ sung test cho code cũ). Không hạ ngưỡng này để cho một bước đạt.
- `flutter analyze` không có lỗi (DoD-5).

## Danh mục test chính (5–8 test mỗi component)

| Component | Nội dung bắt buộc |
|-----------|-------------------|
| `BoardEngine`/`TurnResolver` | điểm ô × 10; điểm dòng × 100 × combo; combo reset khi không xóa dòng; xóa dòng và cột; hết nước đi; khối không đặt được |
| Models và `LevelConfigValidator` | JSON hợp lệ; thiếu gem; thiếu sub; `order` trùng; `targetScore` ngoài 1..10,000,000; `version` thiếu hoặc < 1; trường lạ bị bỏ qua; mốc không tăng dần chỉ log |
| `ImageUrlPolicy` | https hợp lệ (`firebasestorage.googleapis.com`, `<nhãn>.firebasestorage.app`); sai scheme; userinfo; port lạ và 443; host giả; chuỗi rỗng; chuỗi `%zz` không ném lỗi |
| `DefaultLevelConfig` | hợp lệ qua validator; level 1 target 500; 36 level |
| `LevelConfigService` | remote hợp lệ; remote hỏng → default; fetch timeout → cached; cached hỏng → default; Firebase lỗi/treo; log không chứa URL đầy đủ |
| `LevelCatalog` | 36 level; công thức `levelIndex`; `assetPath`; `next` ở 1, 35, 36; bất biến |
| `ProgressRepository` | key thiếu/hỏng; chỉ số ngoài 1..36; tutorial không phải bool; FIFO; dirty và thử lại tối đa 3; `flushDirty`; `load` lỗi → chỉ đọc |
| `JourneyController` | ví dụ BR4.1; thắng lại giữ `highestLevelReached`; level 36; lỗi ghi vẫn trả outcome; không throw |
| `AppBootstrap` | thành công; Firebase lỗi/treo; fetch treo; hạn chót 3,5s (đồng hồ giả) |
| `LevelGameController` | thắng ưu tiên hơn hết nước đi; khóa input theo trạng thái; back theo trạng thái; biên %; REVIVE một lần; PLAY AGAIN `roundId` mới; timeout 3s; không xử lý thắng hai lần |
| UI (widget test) | Splash → Home; Home có PLAY ≥ 48dp, không còn thẻ chế độ; header `score / target` và `%`; Victory tạm → CONTINUE → level kế; Game Over khi `lost` |

## Mocking và dữ liệu test

- Đồng hồ: tiêm `Clock` để kiểm thử hạn chót 3,5s và timeout 3s mà không chờ thật.
- Firebase: không gọi Firebase thật trong test. `RemoteConfigClient` là abstract và có `FakeRemoteConfigClient` (cấu hình được: trả JSON, ném lỗi, treo).
- Lưu trữ: `SharedPreferences.setMockInitialValues({...})`, hỗ trợ giả lập ghi lỗi qua lớp bọc `ProgressStore` có thể thay thế.
- Dữ liệu: JSON mẫu hợp lệ 6 gem × 6 sub nằm trong `test/fixtures/level_config_valid.json` (dùng chung). Ca hỏng được tạo bằng cách sửa bản mẫu trong từng test.
- Không có test nào luôn đúng (không dùng `expect(true, true)`). Mỗi test kiểm một hành vi cụ thể.
