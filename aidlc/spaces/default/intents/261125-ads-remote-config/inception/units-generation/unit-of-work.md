# Danh sách unit: Quảng cáo và Remote Config

Nguồn: `components.md`, `decisions.md`, `requirements.md`, `stories.md` và `units-generation-questions.md`. Tài liệu này mô tả cấu trúc, chưa chọn thứ tự làm. Thứ tự do bước lập kế hoạch giao hàng quyết định.

## Bảng unit

| Unit ID | Directory | Tên | Kiểu | Độ phức tạp | Triển khai |
|---------|-----------|-----|------|-------------|-----------|
| U1 | `u1-ads-core` | Nền tảng quảng cáo và interstitial | library | L | embedded (cùng ứng dụng) |
| U2 | `u2-reward-ads` | Reward ads để chơi lại level | ui | M | embedded |
| U3 | `u3-banner` | Banner dưới màn chơi | ui | S | embedded |
| U4 | `u4-update-and-share` | Popup cập nhật và link chia sẻ | ui | S | embedded |

Cả bốn unit nằm trong cùng một ứng dụng Flutter và phát hành cùng nhau. (Q3 của units-generation)

## U1: u1-ads-core (bản mỏng chạy xuyên suốt)

- **Mô tả**: Nền tảng quảng cáo cộng interstitial. Đọc cấu hình từ Firebase, đếm lần mở ứng dụng và lần bấm Start, xử lý đồng ý của người dùng, chọn mạng theo `ads_priority` và hiện interstitial. (Q1, Q2)
- **Thành phần**: `AdsConfig`, `RemoteConfigClient` (mở rộng), `AdNetworkAdapters`, `ConsentService`, `AdCounters`, `AdMediator`, `AppBootstrap` (thêm nạp cấu hình, đếm lần mở và khởi động đồng ý ở nền), phần interstitial của `HomeScreen`. (`components.md`)
- **Stories**: US1.1, US1.2, US1.3, US2.1.
- **Trách nhiệm**: tạo ra mọi thứ mà các unit khác dùng chung (cấu hình, bộ đếm, thứ tự mạng, đồng ý) và là lát cắt nhỏ nhất chạy được từ đầu đến cuối.
- **Ghi chú và ràng buộc**: khởi tạo quảng cáo và đồng ý chạy nền, không chặn Splash (NFR1). Mã SDK nằm sau interface có bản giả để test (NFR3). `RemoteConfigClient` đổi nên bản giả `FakeRemoteConfigClient` và các kiểm thử liên quan phải cập nhật. (ADR-004)

## U2: u2-reward-ads

- **Mô tả**: Nút xem reward ads ở lớp phủ Game Over của chế độ Journey, và luồng chơi lại level sau khi nhận thưởng. (Q1)
- **Thành phần**: `LevelGameController` (hoãn ghi nhận thua, luồng thưởng), phần reward của `GameScreen` và lớp phủ Game Over.
- **Stories**: US3.1.
- **Trách nhiệm**: nút WATCH AD TO TRY AGAIN, kết quả thưởng (xem đủ, đóng sớm, không có quảng cáo), và đảm bảo level không bị hạ khi nhận thưởng.
- **Ghi chú và ràng buộc**: thay đổi hành vi ghi nhận thua hiện có, nên các kiểm thử `level_game_controller_test.dart` và `progress_repository_test.dart` phải cập nhật và vẫn xanh (NFR7, ADR-003). Đây là unit có rủi ro cao nhất.

## U3: u3-banner

- **Mô tả**: Banner thích ứng dưới cùng màn chơi, hiện từ lần mở ứng dụng thứ N. (Q1)
- **Thành phần**: phần banner của `GameScreen`.
- **Stories**: US4.1.
- **Trách nhiệm**: vùng banner không che bàn cờ và khay khối, ẩn hẳn khi không tải được.
- **Ghi chú và ràng buộc**: dùng lại `AdMediator` và `AdCounters` của U1.

## U4: u4-update-and-share

- **Mô tả**: Popup báo có bản mới trên màn Home và link cửa hàng trong nội dung chia sẻ. (Q1)
- **Thành phần**: `AppUpdateChecker`, phần popup của `HomeScreen`, `ScoreShareService`.
- **Stories**: US5.1, US6.1.
- **Trách nhiệm**: so phiên bản, hiện popup tối đa một lần mỗi lần mở ứng dụng, thêm link theo hệ điều hành vào nội dung chia sẻ.
- **Ghi chú và ràng buộc**: cần thêm một thư viện đọc phiên bản đang cài (ADR-006). Chỉ cần cấu hình từ U1, không cần quảng cáo.

## Thành phần chung giữa các unit

`HomeScreen` được sửa ở U1 (interstitial) và U4 (popup). `GameScreen` được sửa ở U2 (nút reward) và U3 (banner). Hai cặp này là điểm dễ xung đột khi gộp, nên cần làm tuần tự hoặc gộp cẩn thận.

## Assumptions & Open Questions

None.
