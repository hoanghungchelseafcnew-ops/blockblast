# Hướng dẫn build: đợt quảng cáo và Remote Config

Nguồn: `code-summary.md`, `code-generation-plan.md` và `unit-test-instructions.md` của bốn unit (`u1-ads-core`, `u2-reward-ads`, `u3-banner`, `u4-update-and-share`), cùng `team.md` (build và upload thủ công).

## Môi trường

- Flutter 3.41.5 trên Windows (`D:\Setup\fluter_sdk\...`), Android SDK ở `D:\Setup\android_sdk` (`android/local.properties`).
- Gradle 8.12, Android Gradle Plugin 8.9.1, Kotlin Gradle Plugin khai báo ở `android/settings.gradle.kts`.
- iOS: cần macOS có Xcode để chạy `flutter build ipa`.
- Không cần biến môi trường hay khóa bí mật. ID quảng cáo là định danh công khai trong `lib/features/ads/services/ad_unit_ids.dart` (bản debug dùng ID thử của AdMob).

## Cài thư viện

```bash
flutter pub get
```

Thư viện mới của đợt này: `google_mobile_ads ^9.2.0`, `unity_ads_plugin ^0.6.0`, `applovin_max ^4.6.4`, `app_tracking_transparency ^2.0.7`, `package_info_plus ^9.0.1`, `url_launcher ^6.3.0`.

## Kiểm tra mã Dart

```bash
flutter analyze && flutter test --coverage
```

## Build ứng dụng

```bash
# Android
flutter build apk --debug
flutter build appbundle

# iOS (trên macOS)
cd ios && pod install && cd ..
flutter build ipa
```

## Kiểm tra sau build

- APK hoặc AAB được tạo trong `build/app/outputs/`.
- Cài bản debug lên máy thật: banner thử, interstitial thử và reward thử của AdMob hiện được; hộp thoại đồng ý hiện ở lần vào Home đầu tiên.

## Xử lý lỗi thường gặp

| Lỗi | Nguyên nhân | Cách xử lý |
|-----|-------------|-----------|
| `Module was compiled with an incompatible version of Kotlin. The binary version of its metadata is 2.3.0, expected version is 2.1.0` (từ `play-services-ads-25.5.0`) | Kotlin Gradle Plugin 2.1.0 không đọc được thư viện biên dịch bằng Kotlin 2.3 | Nâng `org.jetbrains.kotlin.android` trong `android/settings.gradle.kts` lên `2.2.20` trở lên |
| `Daemon compilation failed ... this and base files have different roots: C:\... and D:\...` | Pub cache ở ổ C, dự án ở ổ D; bộ đệm biên dịch tăng dần của Kotlin không tính được đường dẫn giữa hai ổ | Thêm `kotlin.incremental=false` vào `android/gradle.properties`, hoặc đặt `PUB_CACHE` trên ổ D |
| `source value 8 is obsolete`, `deprecated API`, `unchecked cast` | Cảnh báo trong mã của các plugin | Bỏ qua |
| `flutter pub get` báo xung đột `win32` | `package_info_plus` mới hơn xung đột với `share_plus ^10.1.3` | Giữ `package_info_plus ^9.0.1` (đã làm ở u1) |

## Assumptions & Open Questions

None.
