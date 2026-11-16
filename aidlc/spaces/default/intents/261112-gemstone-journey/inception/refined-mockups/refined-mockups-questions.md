# Refined Mockups Questions — Gemstone Journey

Bối cảnh: app hiện dùng `AppTheme.darkTheme`, font **Righteous** cho tiêu đề và **Montserrat** cho nội dung (qua `google_fonts`), nền `AnimatedBackground` gồm gradient và hạt chuyển động, nút bo góc 20. Câu hỏi bên dưới cũng xử lý các góp ý R-01, R-04 và R-06 từ review User Stories.

---

## Q1. Bấm CONTINUE khi hiệu ứng Victory đang chạy thì sao? (góp ý R-01)

A. Dừng ngay confetti, glow và âm thanh, chuyển sang level kế tiếp. Nút bị khóa sau lần bấm đầu tiên để chống bấm đúp
B. Âm thanh vẫn phát hết, chỉ dừng hiệu ứng hình
C. Chuyển level ngay, hiệu ứng mờ dần trong 300ms
X. Other (please specify)

[Answer]:A

---

## Q2. Phần trăm trên thanh tiến độ làm tròn thế nào? (góp ý R-04)

A. Làm tròn xuống (floor). 99,9% hiển thị 99%, chỉ hiện 100% khi đạt mốc
B. Làm tròn thông thường (68,5% thành 69%)
C. Không hiển thị %, chỉ hiển thị "2,850 / 4,200"
X. Other (please specify)

[Answer]:A

---

## Q3. Ảnh nền tải từ mạng về chậm, sau khi level đã bắt đầu, thì sao? (góp ý R-06)

A. Chỉ đổi ảnh khi bắt đầu level. Nếu ảnh mạng chưa sẵn sàng thì dùng ảnh asset cho cả level
B. Hiện asset trước, khi ảnh mạng về thì cross-fade 300ms sang ảnh mạng
X. Other (please specify)

[Answer]:B

---

## Q4. Font chữ: `google_fonts` mặc định tải font qua mạng ở lần chạy đầu, nên khi offline lần đầu chữ sẽ là font hệ thống. Xử lý thế nào?

A. Đóng gói sẵn font Righteous và Montserrat trong `assets/fonts/`, để offline vẫn đúng font (NFR6)
B. Chấp nhận dùng font hệ thống khi offline lần đầu
C. Bỏ `google_fonts`, chỉ dùng font hệ thống
X. Other (please specify)

[Answer]:A

---

## Q5. Màu đá quý được áp dụng tới đâu?

A. Gradient nền, accent (nút PLAY và CONTINUE), thanh tiến độ, glow và confetti theo màu đá quý. Khối và ô trên bảng giữ màu ngẫu nhiên như hiện tại
B. Như A, và khối trên bảng cũng mang tông màu đá quý
C. Chỉ áp dụng cho header và thanh tiến độ
X. Other (please specify)

[Answer]:A

---

## Q6. Giữ nền hạt chuyển động `AnimatedBackground` phía sau ảnh nền đã blur không?

A. Bỏ. Ảnh nền blur kèm một lớp phủ tối (khoảng 50%) để bảng dễ nhìn
B. Giữ hạt bay nhẹ phía trên ảnh blur
X. Other (please specify)

[Answer]:A

---

## Q7. Trạng thái "đang tải" lúc mở app (khi fetch Remote Config)?

A. Không chặn. Hiện Home ngay với config mặc định hoặc đã cache. Config mới chỉ áp dụng từ lần PLAY sau khi activate xong
B. Hiện splash tối đa 2 giây chờ fetch, quá thời gian thì dùng mặc định
X. Other (please specify)

[Answer]:B

---

Trả lời trong chat được, ví dụ: "1A 2A 3A 4A 5A 6A 7A"

---

## Consolidated Summary Confirmation

Does this all look correct before I generate the artifact?

- Q1: Bấm CONTINUE thì dừng ngay confetti, glow và âm thanh, chuyển level. Nút khóa sau lần bấm đầu tiên
- Q2: % làm tròn xuống (floor). Chỉ hiện 100% khi đạt mốc
- Q3: Hiện ảnh asset trước, ảnh mạng về thì cross-fade 300ms sang
- Q4: Đóng gói sẵn font Righteous và Montserrat trong `assets/fonts/`
- Q5: Màu đá quý cho gradient nền, accent, thanh tiến độ, glow và confetti. Khối giữ màu ngẫu nhiên
- Q6: Bỏ hạt chuyển động. Ảnh nền blur kèm lớp phủ tối khoảng 50%
- Q7: Splash tối đa 2 giây chờ fetch Remote Config, quá thời gian thì dùng mặc định

- Looks correct
- Request changes

[Answer]: Looks correct
