# Đánh giá khả thi: Quảng cáo và Remote Config

Nguồn: `intent-statement.md` (ý định đã duyệt) và `feasibility-questions.md` (các câu trả lời Q1 đến Q8). Các nhận định về kỹ thuật là đánh giá của kiến trúc sư, được gắn nhãn "giả thuyết" khi chưa kiểm chứng.

## Kết luận

Khả thi ở mức thực hiện được với đội một developer, không có mốc thời gian cố định. Không có rào cản kỹ thuật chặn công việc. Rủi ro lớn nhất nằm ở sự đồng ý của người dùng (EU/EEA, iOS) và thời gian duyệt trên cửa hàng, không nằm ở khả năng xây dựng. (Q3, Q4, Q8)

## Cơ sở kỹ thuật hiện có

- Dự án Flutter đã có Firebase Core, Remote Config và Analytics. Remote Config hiện chỉ dùng cho tham số level. (xem bối cảnh trong `feasibility-questions.md`)
- Các tham số quảng cáo và phiên bản mới nằm cùng dự án Firebase và cùng Remote Config đó, nên không cần tạo hạ tầng mới. (Q1)
- Chưa có thư viện quảng cáo nào trong dự án, nên cần thêm hỗ trợ cho ba mạng AdMob, Unity và AppLovin. (xem bối cảnh trong `feasibility-questions.md`, `intent-statement.md` mục Constraints Already Known)
- Tài khoản và ad unit của ba mạng đã sẵn sàng. (`intent-statement.md`, Q7 của intent-capture)

## Đánh giá theo hạng mục của ý định

| Hạng mục | Mức khả thi | Căn cứ |
|----------|-------------|--------|
| Banner chỉ hiện từ lần vào thứ N, N cấu hình được | Cao | Đếm lần vào màn chơi và đọc N từ Remote Config, Q1 xác nhận nơi đặt tham số |
| Reward ads để tiếp tục level hiện tại, có cờ bật/tắt | Trung bình | Cần giữ nguyên trạng thái ván chơi khi thua để tiếp tục, Giả thuyết: có thể làm trong cấu trúc hiện tại, cần kiểm chứng ở bước thiết kế |
| Interstitial sau mỗi N lần bấm Start | Cao | Đếm lần bấm Start và đọc N từ Remote Config |
| `ads_priority` quyết định thứ tự mediation | Trung bình | Ứng dụng tự chạy thứ tự gọi từng mạng theo giá trị cấu hình (Q2), Giả thuyết: mỗi mạng cần gọi SDK riêng, tăng khối lượng tích hợp |
| Kiểm tra phiên bản và popup cập nhật | Cao | Đọc `android_version`, `ios_version` và so với phiên bản cài đặt |
| Dùng `android_url`, `ios_url` trong nội dung chia sẻ | Cao | Ứng dụng đã có chức năng chia sẻ, chỉ cần thêm link, link thật chỉ có sau khi lên cửa hàng (Q7) |

## Rủi ro chính

- Sự đồng ý của người dùng: phát hành toàn cầu gồm EU/EEA nên cần xử lý đồng ý trước khi hiển thị quảng cáo cá nhân hóa, và iOS cần xin phép theo dõi. (Q4, Q8 của intent-capture)
- Chính sách quảng cáo cho đối tượng trên 13 tuổi: game hướng tới trên 13 tuổi nên không phải nội dung dành cho trẻ em, cần xác nhận khai báo đúng trên cả hai cửa hàng và trên các mạng quảng cáo. (Q5)
- Thời gian duyệt trên cửa hàng ứng dụng làm chậm việc phát hành và việc có link thật. (Q8, Q7)
- Link cửa hàng chưa tồn tại: dùng link giả tạm thời, sau đó đổi qua Remote Config khi game lên cửa hàng. (Q7)

## Việc kiểm tra thiết bị

Có thể kiểm tra trên cả Android và iOS, nên các hạng mục quảng cáo và popup cập nhật kiểm chứng được trên cả hai nền tảng. (Q6)

## Phạm vi AWS

Không áp dụng. Hạ tầng cấu hình là Firebase, không dùng dịch vụ AWS. (Q1)

## Assumptions & Open Questions

None.
