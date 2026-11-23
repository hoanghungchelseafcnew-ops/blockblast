# Unit Test Instructions: u1-app-shell

Chiến lược Standard, test-after (implement từng lớp rồi viết và chạy test của lớp đó). Unit đóng gói nên chỉ có một thành phần có hành vi kiểm tra được bằng test: giao diện splash/Home và tên app.

## Khung test
- `flutter_test` (đã có), không cần cấu hình thêm.
- Fake sẵn có: `test/fakes/` và `test/ui/ui_test_helpers.dart`.

## Lệnh chạy riêng cho unit này
```
flutter test test/ui/splash_home_test.dart test/widget_test.dart test/app_composition_test.dart
```
Đây là lệnh chạy được trước khi implement; sau khi implement chạy lại.

## Test cần có (khoảng 5–8)
1. Splash hiện 'BLOCK JEWEL' và '◆ Gemstone Journey ◆' (cập nhật test cũ).
2. `MaterialApp.title` là 'Block Jewel'.
3. Splash dùng nền `GemTheme.backgroundEnd` (`#0F0C29`).
4. Home vẫn hiện dòng phụ '◆ Gemstone Journey ◆' sau splash.
5. Splash chuyển sang Home khi bootstrap xong (đã có, giữ pass).
6. `test/widget_test.dart` pass (yêu cầu của team).

Các cấu hình native (Android, iOS) và `pubspec.yaml` không test được bằng `flutter test`: kiểm bằng đọc file và bằng quan sát trên thiết bị.

## Coverage
Toàn codebase tối thiểu 80% dòng (`flutter test --coverage`, người dùng chạy toàn bộ). Phần Dart của unit này rất nhỏ nên chủ yếu giữ mức hiện có.

## Mock và dữ liệu
Dùng `FakeRemoteConfigClient`, `FakeProgressStore`, `FakeClock` như `splash_home_test.dart`; không cần dữ liệu thêm.
