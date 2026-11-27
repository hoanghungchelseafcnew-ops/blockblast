# Hướng dẫn kiểm thử đơn vị: u1-ads-core

Chiến lược kiểm thử: Standard (5 đến 8 test cho mỗi thành phần, cộng kiểm thử ranh giới chính). Phương pháp: test-after. Theo thực hành của đội, bạn chạy các lệnh dưới đây và báo kết quả, AI chỉ sinh code và test.

## Thiết lập

- Khung test: `flutter_test` (đã có), không thêm thư viện test mới.
- Điều kiện chạy: đã chạy `flutter pub get` sau khi thêm thư viện ở Step 1.
- Các test dùng bản giả đặt trong `test/fakes/` hoặc cạnh test (cổng đồng ý, adapter mạng, kho lưu, đồng hồ). Không có test nào gọi SDK quảng cáo thật hay mạng thật.

## Lệnh chạy cho riêng unit này

```bash
flutter test test/features/ads test/core/config/firebase_remote_config_client_test.dart test/features/journey/app_bootstrap_test.dart test/ui/splash_home_test.dart test/ui/game_screen_test.dart test/ui/endless_game_screen_test.dart
```

Lệnh này chỉ chạy các tệp test của unit này và các tệp hiện có bị ảnh hưởng. Trước khi đo độ phủ toàn dự án cần chạy `flutter test test/widget_test.dart` pass. Kiểm tra tĩnh: `flutter analyze`.

## Mục tiêu độ phủ

- Độ phủ dòng tối thiểu 80% trên toàn codebase, đo bằng `flutter test --coverage`. (`team-practices.md`, NFR3.1)
- Không hạ ngưỡng nào để cho kiểm thử qua.

## Số lượng test dự kiến

| Thành phần | Số test dự kiến |
|-----------|-----------------|
| `RemoteConfigClient` mở rộng | 5 đến 6 |
| `AdsConfig` | 7 đến 8 |
| `AdCounters` | 5 đến 6 |
| `ConsentService` | 6 đến 7 |
| `AdMediator` | 8 đến 10 |
| `AdLifecycleObserver` | 4 đến 5 |
| `AppBootstrap` (bổ sung) | 2 đến 3 |
| Màn hình (bổ sung) | 3 đến 4 |

## Hướng dẫn giả lập

- Cấu hình: `FakeRemoteConfigClient` đặt giá trị theo khóa, kể cả giá trị sai kiểu.
- Quảng cáo: adapter giả trả lần lượt `ready`, `no_fill`, `error` hoặc treo (không bao giờ hoàn tất) để kiểm thử thời hạn 5 giây bằng đồng hồ giả `FakeClock`.
- Đồng ý: cổng giả trả từng trạng thái `not_processed`, `required`, `granted`, `denied`, `not_applicable`.
- Bộ đếm: `FakeProgressStore` để kiểm thử tạo lại sau khi thoát ứng dụng.
- Mỗi test cần ít nhất một trường hợp lỗi hoặc ngoại lệ ngoài đường chính. (`phases/construction.md`)

## Dữ liệu kiểm thử

Dữ liệu tạo trong từng test, không có tệp dữ liệu cố định. Không dùng ID quảng cáo thật.
