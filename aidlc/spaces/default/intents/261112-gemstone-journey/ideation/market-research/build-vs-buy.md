# Build vs Buy — Gemstone Journey

## Sources

- [intent] `ideation/intent-capture/intent-statement.md`
- [Q3] [Q6] [Q7] Câu trả lời đã xác nhận trong `market-research-questions.md`.
- `ideation/intent-capture/stakeholder-map.md`: dự án chỉ có một developer.

## Quyết định tổng quan

Với các thành phần hỗ trợ (cấu hình điểm từ xa, analytics), người dùng chọn **dùng dịch vụ có sẵn**. [Q6]

## Đánh giá theo thành phần

| Thành phần | Quyết định | Lý do | Nguồn |
|------------|-----------|-------|-------|
| Hệ thống 36 level, chọn level, lock/unlock | Build | Đây là giá trị cốt lõi và điểm khác biệt của sản phẩm | [intent] [Q5] |
| Ảnh nền và chủ đề đá quý | Build (tự tạo hoặc mua asset) | Là điểm khác biệt chính, cần nhất quán với chủ đề | [Q5] |
| Cấu hình mục tiêu điểm từ xa | Buy: Firebase Remote Config | Điều chỉnh độ khó mà không cần phát hành bản mới | [Q6] |
| Analytics (session time, retention, hoàn thành level) | Buy: Firebase Analytics | Đo các chỉ số thành công đã nêu trong intent | [Q6] [intent] |
| Quảng cáo và in-app purchase | Buy: SDK có sẵn (ví dụ AdMob, billing của store) | Mô hình kiếm tiền kết hợp | [Q3] [assumption] |

## Lý do chung

- Đội ngũ chỉ có một developer, nên dùng dịch vụ có sẵn giúp giảm khối lượng phải tự xây và tự vận hành. [stakeholder-map] [Q6]
- Ở quy mô trên 100.000 người chơi, cần kiểm tra giới hạn của gói miễn phí Firebase. Analytics và Remote Config thường miễn phí, nhưng điều này cần xác minh ở bước Feasibility. [Q7] [assumption]

## Rủi ro

- **Phụ thuộc vendor:** phụ thuộc vào Firebase/Google. Nên bọc truy cập Remote Config trong một lớp trừu tượng và có giá trị mặc định offline. [Q6] [assumption]
- **Quyền riêng tư:** SDK analytics và quảng cáo kéo theo nghĩa vụ khai báo dữ liệu (xem `market-trends.md`). [Q4] [Q6]

## Assumptions & Open Questions

- [assumption] Việc chọn SDK quảng cáo/IAP cụ thể (AdMob hay mạng khác) chưa được xác nhận. Đây là ví dụ, chưa phải quyết định.
- [assumption] Chi phí Firebase ở quy mô mục tiêu chưa được kiểm chứng.
