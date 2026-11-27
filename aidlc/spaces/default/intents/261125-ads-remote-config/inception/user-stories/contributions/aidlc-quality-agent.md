**Collaborator:** aidlc-quality-agent

## Contribution

Ghi chú: file này do conductor viết theo góc nhìn chất lượng vì trợ lý chuyên trách không có công cụ ghi file trong phiên này, nên nó không độc lập với bản nháp của người dẫn.

- Phần lớn tiêu chí chấp nhận kiểm thử được bằng giả lập: cấu hình giả (`FakeRemoteConfigClient` đã có), quảng cáo giả, trạng thái đồng ý giả, và đồng hồ giả (`FakeClock` đã có).
- AC1.1.4 (Splash chuyển trong 3,5 giây khi quảng cáo treo) kiểm thử được bằng cách giả lập một dịch vụ quảng cáo không bao giờ hoàn thành, theo mẫu kiểm thử `AppBootstrap` hiện có.
- AC2.1.5 ("không có khoảng chờ tối thiểu") là điều kiện phủ định, kiểm thử bằng hai lần hiện liên tiếp với đủ N lần bấm. Đã đủ rõ.
- AC1.3.1 phụ thuộc vào khu vực và nền tảng nên cần giả lập trạng thái đồng ý ở mỗi nhánh (cần đồng ý, đã đồng ý, từ chối, không áp dụng).
- Các bộ đếm lưu bền (AC2.1.2, AC4.1.3) cần kiểm thử khởi động lại bằng kho lưu giả `FakeProgressStore` đã có.

## Positions

- AGREE: các tiêu chí đủ cụ thể để viết kiểm thử tự động.
- AGREE: giữ khuyến nghị ở bước sau là chạy lại các kiểm thử hiện có sau khi đổi luồng thua ván (NFR7).
