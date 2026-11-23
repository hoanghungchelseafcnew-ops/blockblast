# Requirements Analysis Questions

Mô tả gốc: bỏ splash native mặc định của Flutter, đổi tên game thành "Block Jewel", thêm chia sẻ ảnh chụp toàn màn hình khi qua level con và level lớn, sửa thuật toán sinh khối (khối "cứu", ưu tiên khối nhỏ khi bảng đầy trên 60%, độ khó tăng theo level).

## Question 1
Splash native: Android 12 trở lên luôn hiện splash hệ thống (nền và icon), không thể tắt hoàn toàn. Bạn muốn xử lý thế nào?

A. Gỡ cấu hình splash native tùy chỉnh và đặt nền splash hệ thống trùng màu với splash trong code (#0F0C29), bỏ ảnh logo native để hai màn liền mạch.
B. Giữ logo trên splash native nhưng cho giống hệt splash trong code (cùng logo, cùng nền).
C. Bỏ splash trong code, chỉ dùng splash native.
X. Other (please specify)

[Answer]:A

## Question 2
Phạm vi đổi tên "Block Jewel":

A. Chỉ đổi tên hiển thị: nhãn Android, `CFBundleDisplayName`/`CFBundleName` iOS, `title` của app, chữ trên splash, nội dung chia sẻ, README. Giữ nguyên applicationId, bundle id và tên package Dart `block_blast`.
B. Như A, và đổi cả applicationId/bundle id (app sẽ là app mới trên store).
X. Other (please specify)

[Answer]:A

## Question 3
Dòng phụ "◆ Gemstone Journey ◆" trên splash và màn Home:

A. Giữ nguyên.
B. Bỏ đi, chỉ còn "BLOCK JEWEL".
C. Đổi thành một dòng khác (ghi ở Other).
X. Other (please specify)

[Answer]:A

## Question 4
Chia sẻ khi thắng: hiển thị thế nào?

A. Thêm nút SHARE trên màn Victory, bấm mới chia sẻ. Áp dụng cho cả level con (1–5 trong mỗi gem), level lớn (mở khóa gem) và level 36.
B. Như A, nhưng chỉ cho level lớn (mở khóa gem) và level 36.
C. Tự mở khung chia sẻ ngay khi thắng.
X. Other (please specify)

[Answer]:A

## Question 5
Nội dung kèm ảnh chụp toàn màn hình hiện tại khi chia sẻ (chuỗi tiếng Anh):

A. "I cleared <tên level> with <điểm> points in Block Jewel!"
B. Chỉ gửi ảnh, không kèm chữ.
X. Other (please specify)

[Answer]:A

## Question 6
Thuật toán mới áp dụng cho chế độ nào?

A. Cả Journey và Endless (Endless dùng độ khó theo điểm hoặc một mức cố định, ghi ở Other nếu cần).
B. Chỉ Journey.
X. Other (please specify)

[Answer]:A

## Question 7
Khi không khối nào trong khay đặt vừa: thay đúng một khối bằng khối ngẫu nhiên đặt vừa (nhỏ nhất 1×1). Chọn khối nào để thay?

A. Khối ngẫu nhiên trong khay.
B. Khối lớn nhất trong khay (nhiều ô nhất).
X. Other (please specify)

[Answer]:A

## Question 8
Khối "cứu" (chọn khối giúp xóa ít nhất một dòng khi bảng có khối như vậy): xác suất cơ bản 30%. Khi lên level cao hơn, tỉ lệ này đổi thế nào?

A. Giảm dần (ví dụ 30% ở level 1 xuống 10% ở level 36), vì game khó hơn khi lên level.
B. Giữ 30% cho mọi level, chỉ tăng tỉ lệ khối lớn.
C. Tăng dần.
X. Other (please specify)

[Answer]:A

## Question 9
Ngưỡng và hành vi khi bảng đầy trên 60% (số ô đã lấp so với 64 ô):

A. Tăng tỉ lệ khối nhỏ (ví dụ từ 30% lên 60%) và giảm khối lớn tương ứng, các tỉ lệ chính xác sẽ được chốt ở bước thiết kế và là hằng số trong code.
B. Khi trên 60% thì không sinh khối lớn nữa.
X. Other (please specify)

[Answer]:A

## Question 10
Khay mới mặc định có 3 khối. Việc "không khối nào đặt vừa" nên được kiểm tra khi nào?

A. Ngay khi khay mới được sinh (sau mỗi lượt) và trước khi xét thua; chỉ thua khi cả khối 1×1 cũng không đặt vừa.
B. Chỉ kiểm tra khi khay đã hết khối và sinh khay mới.
X. Other (please specify)

[Answer]:A
