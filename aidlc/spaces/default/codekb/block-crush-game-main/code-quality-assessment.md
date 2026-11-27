# Code Quality Assessment

- **Test**: khoảng 10.800 dòng test so với 6.600 dòng code, 508 ca kiểm thử (đếm `test(` và `testWidgets` ở lần quét 261125); có unit, widget, fakes và fixtures. Có `coverage/lcov.info` từ lần chạy trước; chưa chạy lại trong stage này. `test/widget_test.dart` cần xác nhận pass (yêu cầu team.md).
- **Lint**: `flutter_lints` qua analysis_options.yaml.
- **CI/CD**: không có; build và phát hành thủ công.
- **Tài liệu**: README.md (tên cũ "Block Crush", chưa kiểm lại ở lần quét 261125); doc comment tiếng Việt dày.
- **Nợ kỹ thuật**:
  - Tên game rải rác nhiều file (xem developer-scan).
  - Ba tệp 1 dòng còn sót (`game_button.dart`, `score_panel.dart`, `game_helpers.dart`).
  - `pubspec.yaml` còn `description: "A new Flutter project."`.

## Ghi chú lần quét 261125
- `test/features/journey/level_game_controller_test.dart` (1.002 dòng) và `progress_repository_test.dart` (761 dòng) là hai bộ kiểm thử dày nhất, và sẽ bị ảnh hưởng nếu đổi luồng thua ván.
- Không có `.github` hay tệp pipeline nào, đúng quy ước nhóm: build tay và upload tay lên cửa hàng.
- Chưa chạy lại `flutter analyze` và `flutter test` ở lần quét này. Theo quy ước nhóm, người dùng chạy và báo kết quả.
