# Code Summary: u1-app-shell

## Files đã sửa hoặc xóa
- **Dart:** `lib/app.dart` (title 'Block Jewel'), `lib/features/splash/screens/splash_screen.dart` ('BLOCK JEWEL', giữ dòng phụ).
- **Test:** `test/ui/splash_home_test.dart` (chuỗi mới, thêm 2 test: tiêu đề app và nền splash, dòng phụ ở Home).
- **Cấu hình:** `pubspec.yaml` (gỡ `flutter_native_splash` và khối cấu hình), `README.md` (đổi tên hiển thị; giữ URL repo).
- **Android:** `AndroidManifest.xml` nhãn "Block Jewel"; `drawable/launch_background.xml` và `drawable-v21/launch_background.xml` chỉ còn nền `#0F0C29`; thêm `drawable/splash_empty.xml`; `values-v31` và `values-night-v31` dùng `splash_empty` cho icon splash Android 12+; đã xóa mọi `splash.png`, `android12splash.png`, `background.png` và các thư mục `drawable-*dpi` và `drawable-night-*` trở thành rỗng.
- **iOS:** `LaunchScreen.storyboard` chỉ còn nền `#0F0C29`; đã xóa `LaunchImage.imageset` và `LaunchBackground.imageset`; `Info.plist` `CFBundleDisplayName` "Block Jewel", `CFBundleName` "block_jewel".

## Quyết định chính
- Android 12+ luôn hiện splash hệ thống; icon được đặt trong suốt nên chỉ thấy nền `#0F0C29`, liền mạch với `SplashScreen`.
- Không đổi `applicationId`, `namespace`, bundle id và tên package Dart (NFR7.1); không thêm quyền hay gói (NFR7.2).
- Chuỗi chia sẻ "Block Crush" trong `score_share_service.dart` để U2 xử lý (US2.3).

## Test
- Cập nhật 1 test và thêm 2 test trong `test/ui/splash_home_test.dart`.
- **Chưa chạy:** theo quy ước team, người dùng chạy `flutter test test/ui/splash_home_test.dart test/widget_test.dart test/app_composition_test.dart`, rồi `flutter analyze` và `flutter test --coverage`.
- Sau khi gỡ `flutter_native_splash` cần chạy `flutter pub get` để cập nhật `pubspec.lock`.

## Lệch so với kế hoạch
Không có lệch đáng kể. Thư mục `ios/Runner/Assets.xcassets` chỉ còn `AppIcon.appiconset`; chưa kiểm tra mở được trong Xcode (cần kiểm trên máy macOS).
