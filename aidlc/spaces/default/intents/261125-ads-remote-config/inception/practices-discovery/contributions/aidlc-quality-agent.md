**Collaborator:** aidlc-quality-agent

## Contribution

Ghi chú: file này do conductor viết theo góc nhìn chất lượng vì trợ lý chuyên trách không có công cụ ghi file trong phiên này, nên nó không độc lập với bản nháp của người dẫn.

Bằng chứng kiểm thử trong mã nguồn đã quét:

- Khoảng 508 ca kiểm thử trong `test/`, chia thành unit (engine, logic, config, journey), widget và UI (`test/ui/`), mô phỏng độ khó (`test/simulation/`) và fakes dùng chung (`test/fakes/`). Có `test/widget_test.dart` (42 dòng).
- Có thư mục `coverage/` với `lcov.info`, nhưng không có ngưỡng độ phủ nào được cấu hình trong repo. Ngưỡng 80% chỉ nằm trong `team.md`.
- Không có CI: không có `.github` hay tệp pipeline, nên không có cổng chất lượng tự động. Nhóm chạy `flutter analyze` và `flutter test --coverage` bằng tay.
- Hai bộ kiểm thử dày nhất, `level_game_controller_test.dart` (1.002 dòng) và `progress_repository_test.dart` (761 dòng), sẽ bị ảnh hưởng nếu luồng thua ván đổi cho reward ads.

Điểm cần phỏng vấn làm rõ: quy ước kiểm thử hiện tại (test-after, 80% dòng, người dùng chạy lệnh) vẫn đúng cho đợt quảng cáo này, và mã phụ thuộc SDK quảng cáo phải được giả lập qua interface như `RemoteConfigClient` và `AnalyticsService`.

## Positions

- AGREE: test-after với độ phủ dòng tối thiểu 80% phù hợp với cách codebase đang làm.
- AGREE: SDK quảng cáo nên nằm sau interface với bản fake để test, như mẫu hiện có.
