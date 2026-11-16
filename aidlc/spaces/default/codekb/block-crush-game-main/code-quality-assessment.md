# Code Quality Assessment — Block Crush

## Tổng quan

| Khía cạnh | Đánh giá | Bằng chứng |
|-----------|----------|------------|
| Test coverage | 🔴 Không có, test hỏng | `test/widget_test.dart` tham chiếu `MyApp` không tồn tại (app là `BlockBlastApp`), là test counter mặc định |
| Linting | 🟡 Cơ bản | `flutter_lints` mặc định, không có rule tùy chỉnh |
| CI/CD | 🔴 Không có | Không có `.github/` hay pipeline. Thư mục không phải git repo |
| Documentation | 🟡 | README dạng marketing, hầu như không có doc comment |
| Cấu trúc | 🟡 | Có feature folders, nhưng logic tập trung trong `_GameScreenState` (395 dòng) |

## Technical debt

| ID | Vấn đề | Vị trí | Ảnh hưởng tới intent |
|----|--------|--------|----------------------|
| TD-1 | God-widget: state, scoring, timer, persistence và UI nằm chung | `game_screen.dart` | Cao: thêm level/target/victory sẽ làm file phình thêm. Nên tách sang `GameController` |
| TD-2 | Nhánh `GameMode.timeAttack` rải ở khoảng 7 chỗ | `game_screen.dart` | Trung bình: phải gỡ khi chỉ giữ Classic |
| TD-3 | File rỗng `game_controller.dart`, `game_helpers.dart`, `game_button.dart`, `score_panel.dart` | nhiều nơi | Thấp: có thể tận dụng |
| TD-4 | `ParticleExplosion` không được dùng | `widgets/particle_explosion.dart` | Thấp: có thể dùng lại cho confetti ở màn Victory |
| TD-5 | Test hỏng, không có coverage | `test/` | Cao: scope `feature` yêu cầu coverage floor 80% |
| TD-6 | Mute không được lưu, `init()` rỗng, lỗi audio bị nuốt | `audio_controller.dart` | Trung bình: âm thanh victory/unlock cần tuân theo Settings |
| TD-7 | Daily Gift hiển thị "+500 Points" nhưng không cộng điểm | `home_screen.dart` | Không còn: Daily Gift bị bỏ trong intent |
| TD-8 | Ice có `iceHealth` nhưng không có cơ chế giảm | models, logic | Thấp |
| TD-9 | `withOpacity` deprecated | nhiều widget | Thấp |
| TD-10 | `assets/design/` (khoảng 25MB) chưa khai báo trong pubspec | `pubspec.yaml` | Cao: cần khai báo, nên nén ảnh |
| TD-11 | Package `com.example.*` | android, ios | Nằm trong scope (S-09) |

## Điểm mạnh

- `BoardLogic` và `BlockGenerator` là static thuần, dễ unit-test.
- Đã dùng `RepaintBoundary` cho board và palette.
- Theme tách riêng qua provider.
