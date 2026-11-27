# Tóm tắt mã: u4-update-and-share

Conductor tự viết mã theo `code-generation-plan.md` đã được bạn duyệt, vì trợ lý developer không có công cụ ghi file trong phiên này. Mã bám theo `functional-spec.md`, `rules.md`, `performance-design.md`, `security-design.md`, `contract-summary.md` (hợp đồng 3), `unit-of-work.md` và `requirements.md` (FR6, FR7, NFR4).

## Tệp mới

| Tệp | Nội dung |
|-----|----------|
| `lib/features/update/logic/version_check.dart` | So phiên bản (bỏ số build, phần thiếu là 0), kiểm tra đường dẫn (chỉ `https` có tên máy chủ), chọn theo nền tảng |
| `lib/features/update/services/installed_version_reader.dart` | Interface và bản thật dùng `package_info_plus` |
| `lib/features/update/services/store_launcher.dart` | Interface và bản thật dùng `url_launcher` chế độ mở ngoài, kiểm tra lại đường dẫn trước khi mở |
| `lib/features/update/services/app_update_checker.dart` | Có bản mới hay không, và nhớ lần mở đã hiện popup |
| `lib/features/update/widgets/update_popup.dart` | Popup "Update available" với LATER và UPDATE |
| `test/features/update/*.dart` | Bản giả và 4 tệp test (logic, dịch vụ, popup trên Home) |

## Tệp sửa

| Tệp | Thay đổi |
|-----|----------|
| `pubspec.yaml`, `pubspec.lock` | Thêm `url_launcher: ^6.3.0`; `flutter pub get` chạy không xung đột |
| `android/app/src/main/AndroidManifest.xml` | Thêm intent `VIEW` với scheme `https` vào `<queries>` |
| `ad_mediator.dart` | `AdsService.appOpenCount` và `startupSettled` |
| `app_bootstrap.dart`, `app_composition.dart` | `AppServices.updates`; `AppBootstrap` nhận hàm dựng kiểm tra phiên bản, app thật truyền hàm này |
| `score_share_service.dart` | `withStoreLink` và `storeUrl` của `PlatformScoreShareService` |
| `home_screen.dart` | Kiểm tra sau khung hình đầu, khi quảng cáo báo thay đổi và khi quay về từ màn chơi; mở popup khi Home là màn trên cùng; truyền dịch vụ chia sẻ có link cho màn chơi và Endless |
| Test hiện có | `ads_fakes.dart`, `ad_mediator_test.dart` (+3), `app_bootstrap_test.dart` (+3), `score_share_service_test.dart` (+3), `ui_test_helpers.dart` |

## Quyết định khi viết mã

- Kiểm tra phiên bản bị bỏ qua khi người chơi vừa bấm PLAY (interstitial đang chạy) hoặc khi Home không còn là màn trên cùng; lần quay về Home sau đó kiểm tra lại.
- Khi không có bản mới, lần mở đó không bị đánh dấu, nên lần kiểm tra sau vẫn chạy. Việc đọc phiên bản rất nhẹ.
- Log chỉ ghi kết quả ("update available" hoặc lý do bỏ qua), không ghi đường dẫn hay chuỗi phiên bản (NFR8.3).

## Kiểm thử

Lệnh đã duyệt `flutter analyze && flutter test --coverage` đã chạy:
- `flutter analyze`: không có lỗi.
- `flutter test --coverage`: 669 test pass, 1 skip có sẵn từ trước.
- Độ phủ dòng: 87,8% (3136/3572). Sàn là 80%.

## Việc bạn cần làm trước khi phát hành

- Điền `android_version`, `android_url`, `ios_version`, `ios_url` thật trên Remote Config khi game lên cửa hàng.
- Thử nút UPDATE trên máy thật Android và iOS.
