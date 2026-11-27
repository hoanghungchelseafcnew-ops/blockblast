# Tóm tắt mã: u1-ads-core

Mã do conductor tự viết theo `code-generation-plan.md` đã được bạn duyệt, vì trợ lý developer không có công cụ ghi file trong phiên này. Chưa có lệnh Flutter nào được chạy: theo thực hành của đội, bạn chạy và báo kết quả.

## Tệp mới

| Tệp | Nội dung |
|-----|----------|
| `lib/features/ads/models/ads_settings.dart` | `AdNetwork` và `AdsSettings` chỉ đọc với mặc định |
| `lib/features/ads/services/ads_config.dart` | Đọc và kiểm tra tham số, chuẩn hóa `ads_priority` |
| `lib/features/ads/services/ad_counters.dart` | Bộ đếm lần mở, lần bấm Start và cờ bù, lưu bền |
| `lib/features/ads/services/consent_service.dart` | `ConsentService` và cổng thật dùng UMP và ATT |
| `lib/features/ads/services/ad_network_adapter.dart` | Interface chung cho mỗi mạng |
| `lib/features/ads/services/ad_unit_ids.dart` | ID thử của AdMob cho bản debug, ID phát hành để trống kèm TODO |
| `lib/features/ads/services/admob_adapter.dart`, `unity_adapter.dart`, `applovin_adapter.dart` | Bọc ba SDK, bắt mọi lỗi |
| `lib/features/ads/services/ad_mediator.dart` | `AdsService`, `NoopAdsService`, `AdMediator`: thứ tự mạng, thời hạn 5 giây, tải trước, bù lượt |
| `lib/features/ads/services/ad_lifecycle_observer.dart` | Báo lần quay lại từ nền |
| `test/features/ads/*.dart` | 6 tệp: bản giả dùng chung và test cho cấu hình, bộ đếm, đồng ý, điều phối, vòng đời |

## Tệp sửa

| Tệp | Thay đổi |
|-----|----------|
| `pubspec.yaml` | Thêm 5 thư viện |
| `android/app/src/main/AndroidManifest.xml` | ID ứng dụng AdMob thử |
| `ios/Runner/Info.plist` | ID ứng dụng AdMob thử, câu hỏi xin phép theo dõi (tiếng Anh), một mục `SKAdNetworkItems` |
| `lib/core/config/remote_config_client.dart`, `lib/core/firebase/firebase_remote_config_client.dart` | Thêm `readString`, `readInt`, `readBool`; giữ khoảng tải 12 giờ |
| `lib/features/journey/services/app_bootstrap.dart` | `AppServices` có thêm `ads` và `adsSettings`; đọc cấu hình quảng cáo từ cấu hình đã tải, không tốn thêm thời gian hạn chót |
| `lib/app_composition.dart` | `createAdsService` dựng `AdMediator` thật |
| `lib/features/home/screens/home_screen.dart` | Bắt đầu quảng cáo sau khung hình đầu; interstitial trước khi mở màn chơi và Endless |
| `lib/features/game/screens/game_screen.dart`, `lib/features/endless/screens/endless_game_screen.dart` | Interstitial trước PLAY AGAIN; bỏ đếm lần quay lại sau khi chia sẻ |
| Các tệp test hiện có | Bản giả `RemoteConfigClient`, hàm hỗ trợ UI, và test mới cho bootstrap, Home, màn chơi, Endless |

## Quyết định khi viết mã

- Màn hình chỉ phụ thuộc interface `AdsService`. Mặc định là `NoopAdsService`, nên mọi test cũ không cần SDK và không thay đổi hành vi.
- Khi không có quảng cáo, PLAY và PLAY AGAIN mở ngay, không chờ một nhịp nào.
- Bấm PLAY hai lần trong lúc interstitial đang hiện chỉ tính là một lần.
- Lỗi SDK đồng ý thì dùng quảng cáo không cá nhân hóa, không dừng.

## Khác với kế hoạch

- Không thêm SDK key AppLovin vào `AndroidManifest.xml`: thư viện `applovin_max` nhận key qua `initialize`, nên key nằm trong `ad_unit_ids.dart`.
- Sửa thêm `test/app_composition_test.dart` (không có trong kế hoạch): hai test dựng ứng dụng thật được truyền `NoopAdsService`, vì SDK quảng cáo không có trong môi trường test. Thêm một test kiểm tra `createAdsService` không chạm SDK.

## Việc bạn cần làm

1. Chạy `flutter pub get`. Nếu báo cần Flutter 3.38.1, hạ `google_mobile_ads` về `^7.0.0` và `package_info_plus` về `^9.0.1`.
2. Chạy `flutter analyze`. API của `unity_ads_plugin` và `applovin_max` được viết theo tài liệu hiện có, chưa biên dịch thử, nên có thể có vài lỗi tên tham số cần sửa.
3. Chạy lệnh test của unit trong `unit-test-instructions.md`, rồi `flutter test test/widget_test.dart` và `flutter test --coverage`.
4. Chạy `flutter build apk` và `flutter build ios` để kiểm tra xung đột thư viện gốc.
5. Trước khi phát hành: điền ID thật trong `ad_unit_ids.dart`, thay ID ứng dụng AdMob trong `AndroidManifest.xml` và `Info.plist`, bổ sung `SKAdNetworkItems` của Unity và AppLovin.

## Kiểm thử

Khoảng 50 test mới hoặc cập nhật, đều dùng bản giả. Độ phủ chưa đo được cho đến khi bạn chạy `flutter test --coverage`.
