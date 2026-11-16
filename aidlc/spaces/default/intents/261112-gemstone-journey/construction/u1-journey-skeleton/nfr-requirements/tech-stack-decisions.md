# Tech Stack Decisions — U1 `u1-journey-skeleton`

## Sources

- [codekb] `aidlc/spaces/default/codekb/block-crush-game-main/technology-stack.md`
- [req] `inception/requirements-analysis/requirements.md` NFR1, NFR3, NFR4, NFR7, NFR10
- [adr] `inception/domain-design/decisions.md` ADR-004, ADR-005
- [prac] `inception/practices-discovery/team-practices.md`

| ID | Lựa chọn | Lý do | Thay thế bị loại |
|----|----------|-------|------------------|
| NFR1.1 | Giữ Flutter/Dart SDK `^3.9.2` và cấu trúc `lib/core`, `lib/features` | Brownfield, practices | — |
| NFR1.2 | State: `provider` + `ChangeNotifier` cho `LevelGameController`, `JourneyController`. Inject phụ thuộc qua constructor (ADR-004) | Đã có trong dự án, không thêm dependency | riverpod, bloc, get_it (vi phạm NFR4) |
| NFR4.2 | Thêm `firebase_core` và `firebase_remote_config`, chọn phiên bản tương thích Dart 3.9 tại thời điểm sinh code, dùng ràng buộc `^`. **Tiêu chí kiểm:** `flutter pub get` thành công, `flutter analyze` không có lỗi, `flutter build apk --debug` thành công (người dùng chạy) | Yêu cầu FR3, NFR4 | FlutterFire CLI và `firebase_options.dart` (thêm bước và file sinh tự động. Người dùng đã có file cấu hình nền tảng, nên `Firebase.initializeApp()` không cần tham số) |
| NFR4.3 | Lưu trữ: `shared_preferences` **đã có sẵn** trong `pubspec.yaml` (`^2.2.3`, codekb technology-stack.md), không phải dependency mới nên không vi phạm NFR4 | Đã có, đủ cho dữ liệu nhỏ | Hive, sqflite (thêm dependency) |
| NFR3.1 | Android: plugin `com.google.gms.google-services` trong `settings.gradle.kts` và `app/build.gradle.kts`. `namespace` và `applicationId` = `com.h2.game.block_blast`. Chuyển `MainActivity.kt` | Bắt buộc để đọc `google-services.json` | — |
| NFR3.2 | iOS: `PRODUCT_BUNDLE_IDENTIFIER = com.h2.game.blockBlast`. `GoogleService-Info.plist` được thêm vào target Runner (người dùng làm trong Xcode). Deployment target ≥ 13.0 (giữ nguyên, đủ cho Firebase hiện hành) | FR14 | — |
| NFR10.1 | Test: `flutter_test` hiện có. Fake viết tay (`FakeRemoteConfigClient`, `FakeClock`, repository trong bộ nhớ). `SharedPreferences.setMockInitialValues`. **Không thêm** mocktail hay mockito | NFR4 (hạn chế dependency), ADR-005 | mocktail, mockito |
| NFR10.2 | Coverage: **trước tiên sửa `test/widget_test.dart`** (đang tham chiếu `MyApp` không tồn tại) để `flutter test` chạy được. Sau đó người dùng chạy `flutter test --coverage` và xem `coverage/lcov.info` theo từng file. **Mục tiêu U1:** mọi file Dart mà U1 tạo mới hoặc sửa có coverage dòng ≥ 80% (DoD-2). Mức ≥ 80% toàn codebase đo ở Build & Test | DoD-2, NFR10 | — |
| NFR9.1 | Nút **PLAY** mới ở Home có vùng chạm ≥ 48×48dp. Nhãn "PLAY" chữ trắng trên `AppColors.primary` (`#6C63FF`) đạt tương phản 4,32:1. Nhãn là chữ lớn (≥ 20 logical px, đậm), nên đạt mức WCAG AA cho chữ lớn (≥ 3:1). Phần accessibility đầy đủ (theo checklist A1–A14) thuộc U4 | NFR9 (một phần) | — |
| NFR7.1 | Chuỗi UI tiếng Anh, hardcode trong widget (không dùng i18n) | NFR7: chỉ một ngôn ngữ | `flutter_localizations` (không cần) |

## Assumptions & Open Questions

- [assumption] Phiên bản cụ thể của `firebase_core` và `firebase_remote_config` được chọn ở bước Code Generation. AI không chạy được `flutter pub get`, nên người dùng xác nhận bằng lần build đầu tiên.
