# Technology Stack

- **Ngôn ngữ**: Dart (SDK ^3.9.2), Kotlin DSL (Gradle) cho Android, Swift/Storyboard cho iOS.
- **Framework**: Flutter; state `provider ^6.1.2`.
- **Gói chính**: shared_preferences ^2.2.3, share_plus ^10.1.3, screenshot ^3.0.0, path_provider ^2.1.5, firebase_core ^3.15.0, firebase_remote_config ^5.4.0, firebase_analytics ^11.6.0, audioplayers ^6.0.0, flutter_animate ^4.5.0, google_fonts ^6.2.1, cached_network_image ^3.4.1.
- **Dev**: flutter_test, flutter_lints ^5.0.0, flutter_launcher_icons ^0.13.1. (`flutter_native_splash` không còn trong `pubspec.yaml` ở lần quét 261125.)
- **Android**: applicationId/namespace `com.h2.game.block_blast`, label "Block Jewel".
- **iOS**: CFBundleDisplayName "Block Jewel", CFBundleName "block_jewel".
- **Font**: Righteous, Montserrat (đóng gói).
- **Phiên bản app**: 1.0.0+1. Android `minSdk` và `targetSdk` lấy từ Flutter; iOS deployment target 13.0.
- **Quảng cáo**: chưa có thư viện nào (không `google_mobile_ads`, Unity hay AppLovin).
- **Khóa hướng**: dọc, cấu hình ở `AndroidManifest.xml` (`screenOrientation="portrait"`) và `SystemChrome.setPreferredOrientations`.
