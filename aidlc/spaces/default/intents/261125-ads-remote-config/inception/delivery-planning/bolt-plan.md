# Kế hoạch Bolt: Quảng cáo và Remote Config

Một Bolt là một lượt xây dựng cho một phần việc, kết thúc bằng một thứ chạy được. Kế hoạch này xếp bốn Bolt, mỗi Bolt tương ứng một unit trong `unit-of-work.md`. Nguồn: `unit-of-work.md`, `unit-of-work-dependency.md`, `contract-summary.md`, `team-practices.md` và `delivery-planning-questions.md`.

Mỗi Bolt bám theo các yêu cầu trong `requirements.md` (FR1 đến FR8, NFR1 đến NFR7) và các thành phần trong `components.md` (ví dụ `AdsConfig`, `AdMediator`, `AdCounters`, `ConsentService`, `LevelGameController`).

Thứ tự là rủi ro trước, và làm lần lượt từng Bolt một. (Q1, Q4, Q3 của delivery-planning)

## Bảng tóm tắt

| Thứ tự | Bolt | Unit | Stories | Bản mỏng chạy xuyên suốt |
|--------|------|------|---------|--------------------------|
| 1 | B1 | `u1-ads-core` | US1.1, US1.2, US1.3, US2.1 | Có |
| 2 | B2 | `u2-reward-ads` | US3.1 | Không |
| 3 | B3 | `u3-banner` | US4.1 | Không |
| 4 | B4 | `u4-update-and-share` | US5.1, US6.1 | Không |

## B1: u1-ads-core (bản mỏng chạy xuyên suốt)

Bản mỏng chạy xuyên suốt là một phiên bản tối thiểu chạy hết đường đi, làm trước để chứng minh các phần nối được với nhau. (`team-practices.md`)

- **Unit**: `u1-ads-core`.
- **Phần chứng minh**: đọc cấu hình từ Firebase, đếm lần mở và lần bấm Start, xử lý đồng ý, chọn mạng theo `ads_priority`, và hiện interstitial. Đây là nền cho mọi Bolt sau.
- **Definition of Done**: US1.1, US1.2, US1.3 và US2.1 có kiểm thử qua; ứng dụng khởi động trong hạn chót 3,5 giây khi quảng cáo chưa sẵn sàng; mọi lỗi quảng cáo không dừng game; `flutter analyze` sạch và `flutter test --coverage` đạt tối thiểu 80% dòng, do bạn chạy và báo kết quả. (NFR1, NFR2, NFR3)
- **Confidence hypothesis** (điều Bolt này khẳng định hoặc bác bỏ khi xong): ba SDK quảng cáo, việc xử lý đồng ý và Remote Config cùng chạy được trong một ứng dụng mà không làm chậm khởi động. Nếu sai, các Bolt sau phải xem lại.
- **Expected demo**: mở ứng dụng, bấm PLAY đủ N lần với quảng cáo thử của một mạng thì interstitial hiện rồi vào màn chơi. Tắt mạng thì ứng dụng vẫn chạy bằng giá trị mặc định.
- **Điểm kiểm tra thật của dự án**: bạn chạy `flutter analyze` và `flutter test --coverage` và báo kết quả. Lệnh kiểm tra tự động hoãn chọn, điểm kiểm tra đầu tiên sẽ hỏi lại. (Q7)
- **Chủ sở hữu**: aidlc-developer-agent (xem `team-allocation.md`).

## B2: u2-reward-ads

- **Unit**: `u2-reward-ads`.
- **Phần chứng minh**: luồng thua ván mới (hoãn ghi nhận thua, thưởng không hạ level) hoạt động đúng và không làm hỏng lưu tiến trình.
- **Definition of Done**: US3.1 có kiểm thử qua; các kiểm thử hiện có của `LevelGameController` và `ProgressRepository` đã được cập nhật và xanh; kiểm thử với giả lập ứng dụng bị đóng khi đang ở lớp phủ Game Over. (NFR7, ADR-003)
- **Confidence hypothesis**: đổi thời điểm ghi nhận thua không làm mất hay làm sai tiến trình của người chơi.
- **Expected demo**: thua một ván ở Journey, thấy nút WATCH AD TO TRY AGAIN, xem quảng cáo thử xong thì bàn cờ sạch và tiếp tục ở chính level đó, thoát và mở lại ứng dụng vẫn ở level đó.
- **Phụ thuộc**: B1. **Chủ sở hữu**: aidlc-developer-agent.

## B3: u3-banner

- **Unit**: `u3-banner`.
- **Phần chứng minh**: banner thích ứng không che bàn cờ và khay khối trên màn hình điện thoại ngắn.
- **Definition of Done**: US4.1 có kiểm thử qua, gồm kiểm tra bố cục.
- **Confidence hypothesis**: banner hiện từ lần mở thứ N và không cản thao tác kéo thả.
- **Expected demo**: mở ứng dụng lần thứ N, vào màn chơi thấy banner dưới cùng, bố cục không đổi khi banner không tải được.
- **Phụ thuộc**: B1. **Chủ sở hữu**: aidlc-developer-agent.

## B4: u4-update-and-share

- **Unit**: `u4-update-and-share`.
- **Phần chứng minh**: so sánh phiên bản đúng và link chia sẻ theo hệ điều hành.
- **Definition of Done**: US5.1 và US6.1 có kiểm thử qua; có thư viện đọc phiên bản đã chọn.
- **Confidence hypothesis**: popup hiện đúng lúc và nội dung chia sẻ có link đúng nền tảng, kể cả khi dùng link giả.
- **Expected demo**: đặt phiên bản cao hơn trên Firebase thì popup hiện trên Home, bấm UPDATE mở link, chia sẻ điểm thấy link ở cuối văn bản.
- **Phụ thuộc**: B1. **Chủ sở hữu**: aidlc-developer-agent.

## Thiết lập cho giai đoạn xây dựng

- **Cách lặp**: theo unit (unit-major), lần lượt (serial), mỗi unit có điểm kiểm tra riêng. Đây là cài đặt hiện có, giữ nguyên. (Q4, Q8)
- **Lệnh kiểm tra tự động**: chưa chọn. Bạn tự chạy `flutter analyze` và `flutter test --coverage` rồi báo kết quả, điểm kiểm tra đầu tiên sẽ hỏi lại trước khi xác minh. (Q7)
- **Bố trí người làm**: một phiên làm việc, không phải đội sở hữu từng unit. (Q8)

## Assumptions & Open Questions

None.
