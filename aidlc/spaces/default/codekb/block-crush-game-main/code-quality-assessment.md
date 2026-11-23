# Code Quality Assessment

- **Test**: khoảng 7.700 dòng test so với 6.400 dòng code; có unit, widget, fakes và fixtures. Có `coverage/lcov.info` từ lần chạy trước; chưa chạy lại trong stage này. `test/widget_test.dart` cần xác nhận pass (yêu cầu team.md).
- **Lint**: `flutter_lints` qua analysis_options.yaml.
- **CI/CD**: không có; build và phát hành thủ công.
- **Tài liệu**: README.md (tên cũ "Block Crush"); doc comment tiếng Việt dày.
- **Nợ kỹ thuật**:
  - `BlockGenerator` tĩnh, không nhận board hay level, không inject được `Random`.
  - Tên game rải rác nhiều file (xem developer-scan).
  - Splash trùng: native và trong code.
  - Thư mục `.git` tồn tại dù team không dùng git.
