# Kết quả build và kiểm thử

Nguồn: `build-instructions.md`, `integration-test-instructions.md`, `unit-test-instructions.md` và `code-summary.md` của bốn unit.

## Kiểm tra mã Dart

Lệnh `flutter analyze && flutter test --coverage` chạy trên mã hiện tại ở điểm kiểm tra của `u4-update-and-share` (2026-11-26, exit 0). Sau đó mã không đổi. Lệnh riêng của từng unit trong `unit-test-instructions.md` là tập con của lệnh này, nên được tính một lần.

| Mục | Kết quả |
|-----|---------|
| `flutter analyze` | Không có lỗi |
| Test | 669 pass, 0 fail, 1 skip (có sẵn từ trước) |
| `test/widget_test.dart` | Pass |
| Độ phủ dòng | 87,8% (3136/3572), sàn 80% |

## Build Android

Bạn chạy build trên Windows và gửi log (2026-11-26). Kết quả: **thất bại** ở `:app:compileDebugKotlin`.

```
play-services-ads-25.5.0-api.jar!/META-INF/....kotlin_module Module was compiled with an incompatible version of Kotlin.
The binary version of its metadata is 2.3.0, expected version is 2.1.0.
Execution failed for task ':app:compileDebugKotlin'.
BUILD FAILED in 1m 59s
```

Chẩn đoán: `android/settings.gradle.kts` khai báo Kotlin Gradle Plugin `2.1.0`. `google_mobile_ads 9.2.0` (thêm ở u1) kéo theo `play-services-ads 25.5.0`, thư viện này biên dịch bằng Kotlin 2.3. Trình biên dịch Kotlin chỉ đọc được thư viện mới hơn nó tối đa một phiên bản.

Log cũng có nhiều lỗi "Daemon compilation failed ... different roots C:\ và D:\". Đây là lỗi bộ đệm biên dịch tăng dần của Kotlin khi pub cache và dự án nằm trên hai ổ khác nhau. Kotlin tự chuyển sang biên dịch thường, nên lỗi này không làm hỏng build.

## Build iOS

Chưa chạy: môi trường này không có macOS. Chờ bạn chạy `flutter build ipa`.

## Kiểm thử trên máy thật

Chưa chạy: cần máy Android và iOS thật (`integration-test-instructions.md`, mục thủ công).

## Bậc xử lý lỗi

- Bậc 1 (sửa trong stage), lần 1: nguyên nhân nằm ở cấu hình build, thuộc phạm vi stage này. Theo lựa chọn A của bạn (2026-11-26):
  - `android/settings.gradle.kts`: `org.jetbrains.kotlin.android` từ `2.1.0` lên `2.2.21`.
  - `android/gradle.properties`: thêm `kotlin.incremental=false`.
  - Chờ bạn build lại trên Windows bằng `flutter build apk --debug` và gửi kết quả. Môi trường này không có Android SDK.

## Assumptions & Open Questions

None.
