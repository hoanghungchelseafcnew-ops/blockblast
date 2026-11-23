# Tech Stack Decisions: u1-app-shell

Nguồn: requirements.md (NFR3, NFR5), technology-stack.md (code KB).

| ID | Quyết định | Lý do |
|---|---|---|
| NFR3.1 | Cập nhật test splash và Home (`test/ui/splash_home_test.dart`, `test/widget_test.dart`) theo chuỗi "BLOCK JEWEL"; dùng `flutter_test` hiện có; coverage dòng toàn codebase tối thiểu 80% | quy ước team: test-after, 80% |
| NFR5.1 | `flutter analyze` sạch và `dart format`, theo `flutter_lints` | quy ước team |
| NFR5.2 | Gỡ dev-dependency `flutter_native_splash` khỏi `pubspec.yaml`; không thêm gói mới | giảm phụ thuộc, tránh sinh lại splash cũ |
| NFR5.3 | Sửa tay tài nguyên khởi động (`styles.xml`, `launch_background.xml`, `LaunchScreen.storyboard`); bỏ ảnh splash native | tách khỏi generator đã gỡ |

Ngôn ngữ và nền tảng không đổi: Dart/Flutter, Android (Gradle Kotlin DSL), iOS (Storyboard).
