# Nhật ký quyết định kiến trúc (ADR)

Nguồn: `domain-design-questions.md` và `components.md`.

## ADR-001: Tách khối quảng cáo thành AdsConfig, AdMediator và adapter cho mỗi mạng

- **Context**: Quảng cáo cần đọc cấu hình, chọn mạng theo `ads_priority`, và gọi SDK riêng của ba mạng. Một developer duy nhất, cần kiểm thử được từng phần (`team-practices.md`).
- **Decision**: Ba khối: `AdsConfig`, `AdMediator`, và `AdNetworkAdapters` sau cùng một interface. (Q1)
- **Consequences**: Mỗi khối kiểm thử riêng được và thêm mạng chỉ thêm một adapter. Đổi lại có nhiều tệp hơn.
- **Alternatives Rejected**: Một `AdService` gộp cả ba việc. Bị loại vì khó kiểm thử từng phần và khó thêm mạng.

## ADR-002: Bộ đếm nằm trong khối AdCounters riêng

- **Context**: Cần lưu bền số lần mở ứng dụng và số lần bấm Start. `ProgressRepository` hiện lớn và có nhiều kiểm thử.
- **Decision**: Khối `AdCounters` riêng, lưu qua interface kho lưu như `ProgressStore`. (Q2)
- **Consequences**: Không đụng dữ liệu tiến trình đang có và kiểm thử riêng được. Đổi lại thêm một khối.
- **Alternatives Rejected**: Thêm bộ đếm vào `ProgressRepository`. Bị loại vì rủi ro hồi quy cho lớp đã có nhiều kiểm thử.

## ADR-003: Hoãn ghi nhận thua đến khi người chơi rời lớp phủ Game Over

- **Context**: Game hiện hạ tiến trình và xóa phiên ngay khi hết nước đi. Reward ads cần giữ level không bị hạ khi người chơi nhận thưởng. (`architecture.md`, FR3.5)
- **Decision**: Hoãn ghi nhận thua đến khi người chơi bấm PLAY AGAIN hoặc BACK TO MENU. Nếu nhận thưởng thì không ghi nhận thua. (Q3)
- **Consequences**: Không cần hoàn tác nên luồng đơn giản. Nếu ứng dụng bị đóng đột ngột khi đang ở lớp phủ Game Over thì thua chưa được ghi nhận và người chơi giữ nguyên tiến trình có lợi cho họ. Hành vi hiện có của `LevelGameController` thay đổi nên cần cập nhật các kiểm thử hiện có (`level_game_controller_test.dart`).
- **Alternatives Rejected**: Giữ ghi nhận thua ngay rồi hoàn tác khi nhận thưởng. Bị loại vì cần thêm một đường lưu và dễ lỗi nếu hoàn tác thất bại giữa chừng.

## ADR-004: Mở rộng RemoteConfigClient thay vì tạo interface riêng

- **Context**: `RemoteConfigClient` hiện chỉ có `readLevelConfig()`. Các tham số mới có kiểu số nguyên, bật/tắt và chuỗi.
- **Decision**: Mở rộng `RemoteConfigClient` với các hàm đọc chung theo kiểu và cập nhật bản giả `FakeRemoteConfigClient`. (Q4)
- **Consequences**: Một cổng, một cấu hình tải chung (fetchTimeout 2 giây, minimumFetchInterval 12 giờ). Đổi lại phải sửa một interface đã có kiểm thử.
- **Alternatives Rejected**: Interface riêng cho tham số quảng cáo. Bị loại vì hai nơi cùng cấu hình Firebase Remote Config dễ lệch cài đặt.

## ADR-005: ConsentService là khối riêng

- **Context**: Phát hành toàn cầu gồm EU/EEA và iOS, cần xử lý đồng ý cho mọi loại quảng cáo. (FR8, `constraint-register.md`)
- **Decision**: Khối `ConsentService` riêng, và `AdMediator` chỉ yêu cầu quảng cáo sau khi đồng ý đã xử lý. (Q5)
- **Consequences**: Một nơi quyết định có hiện quảng cáo hay không. Đổi lại thêm một khối.
- **Alternatives Rejected**: Mỗi adapter tự xử lý đồng ý. Bị loại vì lặp ba lần và dễ không nhất quán.

## ADR-006: AppUpdateChecker là khối riêng

- **Context**: Kiểm tra phiên bản không liên quan đến quảng cáo và thay đổi theo lý do khác. (FR6)
- **Decision**: Khối `AppUpdateChecker` riêng, với interface đọc phiên bản đang cài có bản giả để test. (Q6)
- **Consequences**: Kiểm thử riêng được và không phụ thuộc quảng cáo. Cần thêm một thư viện đọc phiên bản (quyết định cụ thể ở bước sau).
- **Alternatives Rejected**: Gộp vào `AdsConfig`. Bị loại vì trộn hai mối quan tâm khác nhau.

## ADR-007: Không có quảng cáo khi bấm nút reward thì vẫn thưởng

- **Context**: Quyết định ở bước thiết kế giao diện: quảng cáo reward được tải trước, nút luôn hiện khi `reward_enabled` là true, và nếu không có quảng cáo khi bấm thì người chơi vẫn được thưởng. (`refined-mockups-questions.md` Q6, Q8)
- **Decision**: `AdMediator` trả kết quả "không có quảng cáo" cho reward, và `LevelGameController` xử lý như đã xem đủ.
- **Consequences**: Người chơi không bị chặn khi không có quảng cáo. Đổi lại họ có thể tắt mạng để nhận thưởng miễn phí, và nhà phát hành không thu doanh thu từ những lượt đó. `requirements.md` (FR3.1) và `stories.md` (AC3.1.2) cần cập nhật.
- **Alternatives Rejected**: Ẩn nút khi quảng cáo chưa sẵn sàng. Bị loại theo lựa chọn của bạn ở Q8 của refined-mockups.
