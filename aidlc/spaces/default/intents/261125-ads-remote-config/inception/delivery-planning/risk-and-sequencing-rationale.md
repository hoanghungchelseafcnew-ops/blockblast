# Lý do xếp thứ tự và rủi ro

Một Bolt là một lượt xây dựng cho một phần việc, kết thúc bằng một thứ chạy được (xem `bolt-plan.md`). Bản mỏng chạy xuyên suốt là một phiên bản tối thiểu chạy hết đường đi, làm trước để chứng minh các phần nối được với nhau. Nguồn: `bolt-plan.md`, `unit-of-work-dependency.md`, `contract-summary.md` và `delivery-planning-questions.md`.

## Thứ tự và lý do

| Thứ tự | Bolt | Lý do |
|--------|------|-------|
| 1 | B1 `u1-ads-core` | Ba Bolt còn lại phụ thuộc nó theo sơ đồ phụ thuộc. Thực hành của đội yêu cầu làm bản mỏng chạy xuyên suốt trước. Đồng thời nó chứa ba trong bốn mối lo của bạn: đồng ý ở EU và iOS, thời gian chờ quảng cáo, tích hợp ba SDK (Q6) |
| 2 | B2 `u2-reward-ads` | Rủi ro cao nhất: đổi thời điểm ghi nhận thua có thể làm hỏng lưu tiến trình, và đây là mối lo thứ tư của bạn (Q6). Làm sớm để lỗi lộ ra sớm |
| 3 | B3 `u3-banner` | Rủi ro thấp, mang doanh thu, độc lập với B2 và B4 |
| 4 | B4 `u4-update-and-share` | Rủi ro thấp, giá trị gián tiếp, và phần link thật phụ thuộc cửa hàng nên để cuối |

Phương pháp: sắp xếp theo lý do định tính, rủi ro trước, kết hợp bản mỏng chạy xuyên suốt trước. Không dùng mô hình chấm điểm WSJF. (Q1, Q2)

Thứ tự này đúng với sơ đồ phụ thuộc: B1 trước, rồi B2, B3, B4 độc lập với nhau nên mọi thứ tự giữa chúng đều hợp lệ. Không có sai lệch so với thứ tự topo.

## Rủi ro và cách xử lý trong kế hoạch

| Rủi ro | Bolt xử lý | Cách xử lý |
|--------|-----------|-----------|
| Reward ads làm hỏng lưu tiến trình | B2 | Hoãn ghi nhận thua (ADR-003), cập nhật và chạy lại các kiểm thử hiện có, kiểm thử với giả lập đóng ứng dụng đột ngột |
| Xử lý đồng ý ở EU và iOS | B1 | `ConsentService` riêng, quảng cáo chỉ được xin sau khi đồng ý đã xử lý |
| Thời gian chờ quảng cáo lên tới 15 giây | B1 | Quyết định cách rút ngắn (ví dụ tải trước) ở bước thiết kế chi tiết, đã ghi trong câu hỏi mở của `contract-summary.md` |
| Ba SDK cùng lúc làm chậm khởi động | B1 | Khởi tạo quảng cáo chạy nền, không chặn hạn chót 3,5 giây (NFR1) |
| Thay đổi `RemoteConfigClient` làm hỏng kiểm thử hiện có | B1 | Cập nhật bản giả và chạy lại kiểm thử |
| Hai cặp thành phần chung (`HomeScreen`, `GameScreen`) gây xung đột khi gộp | B1 với B4, B2 với B3 | Làm lần lượt từng Bolt, gộp ngay khi xong mỗi Bolt |

## Assumptions & Open Questions

None.
