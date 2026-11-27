# Câu hỏi phác thảo giao diện: Quảng cáo và Remote Config

Bối cảnh từ mã nguồn hiện tại: game có các màn Splash, Home, Game (màn chơi), Endless, và các lớp phủ cho thua (`game_over_overlay.dart`) và thắng (`victory_overlay.dart`). Đây là những nơi quảng cáo và popup cập nhật sẽ xuất hiện. Mọi chuỗi hiển thị trên giao diện chỉ dùng tiếng Anh.

## Q1. Vị trí banner ở màn chơi

Hạng mục 1 thêm một banner ở màn chơi. Vị trí ảnh hưởng đến khoảng chơi và khả năng bấm nhầm.

Banner nên nằm ở đâu?

- A. Dưới cùng màn chơi
- B. Trên cùng màn chơi
- C. Not yet defined (chưa xác định, để bước thiết kế đề xuất)
- X. Other (please specify)

[Answer]:A

## Q2. Vị trí nút xem reward ads

Hạng mục 2 thêm nút xem reward ads khi thua. Hiện đã có lớp phủ khi thua.

Nút này nằm ở đâu?

- A. Trong lớp phủ khi thua, cạnh các lựa chọn hiện có
- B. Một hộp thoại riêng hiện trước lớp phủ khi thua
- C. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:A

## Q3. Trạng thái ván chơi sau khi xem reward ads

Ý định của bạn là tiếp tục ở level hiện tại thay vì quay về Rough Stone. Câu hỏi này làm rõ người chơi quay lại ván chơi như thế nào, vì ảnh hưởng đến luồng và nội dung màn hình.

Sau khi xem xong quảng cáo, người chơi nhận được gì?

- A. Quay lại ván hiện tại với bàn cờ giữ nguyên và có thêm cơ hội đặt tiếp
- B. Bắt đầu lại level hiện tại từ đầu, không về Rough Stone
- C. Not yet defined (chưa xác định, để bước yêu cầu quyết định)
- X. Other (please specify)

[Answer]:B

## Q4. Popup cập nhật: bắt buộc hay tùy chọn

Hạng mục 5 hiện popup khi bản cài đặt thấp hơn bản trên cấu hình. Câu hỏi này xác định người chơi có thể đóng popup hay không.

Popup cập nhật hoạt động như thế nào?

- A. Tùy chọn: có nút Update và nút Later, người chơi có thể đóng
- B. Bắt buộc: chỉ có nút Update, không đóng được
- C. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:A

## Q5. Thời điểm hiện popup cập nhật

Câu hỏi này xác định luồng người chơi gặp popup lần đầu.

Popup hiện vào lúc nào?

- A. Khi mở ứng dụng, ngay sau màn Splash
- B. Khi vào màn Home
- C. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:B

## Q6. Khi quảng cáo không tải được

Quảng cáo có thể không tải được (không có mạng, hết lượt quảng cáo). Câu hỏi này xác định giao diện lúc đó.

Giao diện nên xử lý thế nào?

- A. Banner ẩn hẳn, không chừa khoảng trống, và nút reward ads cũng ẩn
- B. Banner chừa khoảng trống cố định, nút reward ads hiện nhưng không bấm được
- C. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:A

## Q7. Thiết bị cần hỗ trợ

Câu hỏi này xác định kích thước màn hình mà các bản phác thảo cần tính đến.

Thiết bị nào cần hỗ trợ?

- A. Điện thoại, hướng dọc
- B. Điện thoại và máy tính bảng
- C. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:A

## Q8. Yêu cầu trợ năng (accessibility)

Câu hỏi này ghi nhận yêu cầu đã biết về trợ năng cho các thành phần mới như nút và popup.

Có yêu cầu trợ năng nào không?

- A. Không có yêu cầu cụ thể (None)
- B. Có, các mức cơ bản như độ tương phản và cỡ chữ đọc được
- C. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:A

## Consolidated Summary Confirmation

Does this all look correct before I generate the artifact?

- Looks correct
- Request changes

[Answer]: Looks correct
