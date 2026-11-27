# Quyết định công nghệ: u1-ads-core

Nguồn: `nfr-requirements-questions.md`, `technology-stack.md` của kho kiến thức mã nguồn và `pubspec.lock`. Phiên bản bên dưới lấy từ pub.dev tại thời điểm viết và kiểm tra với ràng buộc của dự án.

## Thư viện được chọn

| Mục đích | Thư viện | Phiên bản đề xuất | Lý do | Nguồn |
|----------|----------|--------------------|-------|-------|
| AdMob (banner, reward, interstitial) | `google_mobile_ads` | ^9.2.0 | Thư viện chính thức của Google, có UMP cho đồng ý | Q1, Q2 |
| Unity Ads | `unity_ads_plugin` | ^0.6.0 | Thư viện chính thức cho Unity Ads, ứng dụng tự điều phối | Q1 |
| AppLovin MAX | `applovin_max` | ^4.6.4 | Thư viện chính thức của AppLovin, ứng dụng tự điều phối | Q1 |
| Xin phép theo dõi trên iOS | `app_tracking_transparency` | ^2.0.7 | Hộp thoại ATT của iOS | Q2 |
| Đọc phiên bản đang cài | `package_info_plus` | ^10.2.2 | Dùng cho `u4-update-and-share`, chọn sớm để `pubspec.yaml` thống nhất | Q3 |

## Tương thích với dự án

- `pubspec.lock` hiện yêu cầu Dart từ 3.10.0 và Flutter từ 3.38.0, nên môi trường của bạn đã đủ cho các phiên bản trên, ngoại trừ ghi chú sau.
- `google_mobile_ads` 9.2.0 và `package_info_plus` 10.2.2 yêu cầu Flutter từ 3.38.1. Nếu bạn dùng Flutter 3.38.0 thì `flutter pub get` sẽ báo lỗi, và khi đó dùng `google_mobile_ads` ^7.0.0 (cần Flutter từ 3.35.1) và `package_info_plus` ^9.0.1 (cần Flutter từ 3.19.0).
- Theo thực hành của đội, AI chỉ sửa `pubspec.yaml`, còn bạn chạy `flutter pub get` và báo kết quả.

## Rủi ro đã biết

- Ba SDK quảng cáo cùng lúc làm tăng kích thước ứng dụng và có thể xung đột phiên bản thư viện gốc (native) trên Android và iOS. Cần chạy thử `flutter build` cho cả hai nền tảng sau khi thêm. (R4 trong `raid-log.md`)
- `unity_ads_plugin` ở phiên bản 0.6.0 chưa phải bản ổn định 1.0, nên cần kiểm tra khi lên phiên bản mới.
- Mỗi mạng yêu cầu cấu hình riêng trong `AndroidManifest.xml` (ID ứng dụng AdMob, SDK key AppLovin) và `Info.plist` (ID ứng dụng AdMob, `NSUserTrackingUsageDescription`, danh sách `SKAdNetworkItems`). Mã nguồn hiện chưa có các mục này. (`dependencies.md` của kho kiến thức mã nguồn)

## Không đổi

Dart, Flutter, `provider`, `shared_preferences`, `firebase_remote_config` và `firebase_analytics` giữ nguyên. (`technology-stack.md`)

## Assumptions & Open Questions

None.
