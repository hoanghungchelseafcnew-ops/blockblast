# Technology Stack — Block Crush

| Lớp | Công nghệ | Phiên bản (pubspec) | Ghi chú |
|-----|-----------|---------------------|---------|
| Ngôn ngữ | Dart | SDK `^3.9.2` | |
| UI framework | Flutter | theo SDK | Material 3 dark theme |
| State management | provider | `^6.1.2` | Chỉ dùng cho ThemeManager |
| Lưu trữ cục bộ | shared_preferences | `^2.2.3` | High score, theme, tutorial, ngày đăng nhập |
| Animation | flutter_animate | `^4.5.0` | |
| Âm thanh | audioplayers | `^6.0.0` | SFX wav |
| Font | google_fonts | `^6.2.1` | |
| Chia sẻ | share_plus `^10.1.3`, screenshot `^3.0.0`, path_provider `^2.1.5` | | Share score |
| Icon | cupertino_icons | `^1.0.8` | |
| Test | flutter_test | SDK | Test hiện tại hỏng |
| Lint | flutter_lints | `^5.0.0` | |
| Tooling | flutter_native_splash `^2.4.0`, flutter_launcher_icons `^0.13.1` | | Splash `#0F0C29`, min_sdk_android 21 |
| Android build | Gradle Kotlin DSL, Kotlin | flutter.minSdkVersion / targetSdkVersion | namespace và applicationId `com.example.block_blast` |
| iOS | Xcode project Runner, Swift AppDelegate | deployment target 13.0 | bundle `com.example.blockBlast` |
| Backend / cloud | **Không có** | | Firebase chưa được tích hợp |

Phiên bản chính xác đã resolve nằm trong `pubspec.lock` (chưa đọc chi tiết).
