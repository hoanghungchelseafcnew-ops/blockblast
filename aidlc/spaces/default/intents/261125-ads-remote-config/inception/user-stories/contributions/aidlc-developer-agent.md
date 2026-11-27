**Collaborator:** aidlc-developer-agent

## Contribution

Ghi chú: file này do conductor viết theo góc nhìn developer vì trợ lý chuyên trách không có công cụ ghi file trong phiên này, nên nó không độc lập với bản nháp của người dẫn.

- US3.1 (reward ads) là story lớn nhất, với 7 tiêu chí. Nó chạm vào luồng thua ván của `LevelGameController` và `JourneyController`, nơi game hiện lưu tổn thất ngay khi hết nước đi. Làm được, nhưng nên cẩn thận vì hai bộ kiểm thử dày (`level_game_controller_test.dart`, `progress_repository_test.dart`) bị ảnh hưởng. Chia thành hai stories sẽ dễ ước lượng hơn, nhưng bạn đã chọn một story cho mỗi tính năng (Q3), nên mình giữ nguyên và ghi chú rủi ro.
- US5.1 cần đọc phiên bản đang cài lúc chạy, nên cần thêm một thư viện. US2.1 và US4.1 cần bộ đếm lưu bền, dùng được `ProgressRepository` hiện có hoặc một kho riêng.
- US1.3 phụ thuộc vào cách nhận biết khu vực và trạng thái đồng ý, thường do SDK cung cấp. Cần giả lập trạng thái này qua interface để kiểm thử.
- Thứ tự làm đề xuất: US1.1, US1.2, US1.3, US2.1 (bản mỏng đã chốt), rồi US3.1, US4.1, US5.1, US6.1.

## Positions

- AGREE: các story đủ nhỏ để thực hiện, với US3.1 là ngoại lệ được ghi chú về rủi ro.
- AGREE: thứ tự phụ thuộc trong `stories.md` khớp với cách code sẽ được tách.
