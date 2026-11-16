**Collaborator:** aidlc-quality-agent

> Conductor viết thay, đóng vai quality agent (agent con không có công cụ file; người dùng đã đồng ý). Chỉ dựa trên bản nháp của lead và codekb, không xem đóng góp của agent khác.

## Contribution

- **Hiện trạng test:** `test/widget_test.dart` là test counter mặc định của Flutter, gọi `MyApp` trong khi class này không tồn tại, nên `flutter test` sẽ lỗi compile. Coverage hiện tại bằng 0. Không có `coverage/` hay cấu hình lcov.
- **Phần dễ test:** `BoardLogic` và `BlockGenerator` là static thuần nên unit-test được ngay. Logic level mới (mốc điểm, quy tắc thua về Rough Stone, mở khóa, parse JSON Remote Config, fallback) nên đặt trong lớp Dart thuần hoặc trong `GameController` để test không cần widget.
- **Môi trường:** máy hiện không có `flutter` hoặc `dart` trên PATH, nên chưa chạy được test hay đo coverage. Cần xác nhận lệnh build và test mà người dùng chạy.
- **Cần hỏi người dùng:**
  - Phương pháp test: test-after (mặc định) hay TDD.
  - Có giữ ngưỡng coverage 80% cho code mới không, hay áp dụng cho toàn bộ code.
  - Có cần widget test cho các màn mới (Victory, Quit dialog) không.
- **Quality gate đề xuất:** `flutter analyze` sạch, `flutter test --coverage` xanh.

## Positions

- AGREE: dùng mặc định org là test-after và coverage 80% cho scope `feature`. Bằng chứng cho thấy chưa có văn hóa test, nên test-after thực tế hơn TDD.
- OBJECT: ngưỡng 80% nếu tính trên toàn bộ code cũ (UI widget nhiều) sẽ khó đạt. Đề xuất tính 80% trên logic mới và các file bị sửa, cần người dùng quyết định.
