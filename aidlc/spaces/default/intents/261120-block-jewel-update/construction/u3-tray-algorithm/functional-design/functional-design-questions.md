# Functional Design Questions: u3-tray-algorithm

## Question 1: Điểm mâu thuẫn cần bạn quyết định

Theo yêu cầu đã duyệt (FR4.1, FR4.2, Q10 = A), khi không khối nào trong khay đặt vừa thì một khối được thay bằng một khối đặt vừa, nhỏ nhất là 1×1, và chỉ thua khi cả 1×1 cũng không đặt vừa.

Trên bảng 8×8, sau mỗi lượt mọi hàng đầy đều bị xóa, nên bảng không bao giờ đầy hết 64 ô. Vì vậy luôn còn chỗ cho khối 1×1, và **người chơi sẽ gần như không bao giờ thua**. Level chỉ kết thúc khi đạt mốc điểm, và màn Game Over gần như không còn xuất hiện. Một số test hiện có về Game Over cũng sẽ phải đổi.

Bạn muốn xử lý thế nào?

A. Giữ đúng như yêu cầu: luôn thay khối, game gần như không thể thua (level chỉ kết thúc khi đạt mốc).
B. Giới hạn số lần "cứu" mỗi level: ví dụ 3 lần ở level 1, giảm dần đến 1 lần ở level 36; hết lượt cứu thì không khối nào vừa là thua.
C. Chỉ thay khối khi sinh khay mới (cả 3 khối mới); nếu giữa chừng 1–2 khối còn lại không vừa thì thua như hiện nay.
D. Thay khối với xác suất giảm theo level: 100% ở level 1, giảm tuyến tính còn 50% ở level 36; không được thay thì thua.
X. Other (please specify)

[Answer]: X. Khay đã sinh ra thì 3 khối không bao giờ bị thay đổi nữa. Trước khi sinh khay, thuật toán tính trước để tồn tại ít nhất một thứ tự và một cách đặt cả 3 khối vào bảng (kể cả khi các dòng được xóa giữa chừng). Người chơi đặt đúng thì không thua, đặt sai thì có thể thua. (Người dùng yêu cầu ngày 2026-11-20, message f0e6f665.)

## Question 2: Đường cong độ khó (giá trị khởi điểm, chỉnh được về sau)

Đề xuất, với `t = (level − 1) / 35` (level 1 → 0, level 36 → 1):
- Tỉ lệ khối nhỏ / vừa / lớn: level 1 là 40% / 45% / 15%, level 36 là 25% / 45% / 30% (tuyến tính).
- Tỉ lệ khối "cứu" (khối giúp xóa ít nhất một dòng): 30% ở level 1, giảm tuyến tính còn 10% ở level 36.
- Khi bảng đầy hơn 60% (từ 39 trên 64 ô trở lên): khối nhỏ cộng thêm 25 điểm phần trăm, khối lớn còn 40% mức cũ, phần còn lại là khối vừa. Ví dụ level 1: 65% / 29% / 6%.
- Endless dùng mức level 18.
- Giữ quy tắc cũ: tối đa 2 khối lớn trong một khay; băng 5%, bom 5%.

A. Đồng ý các con số trên.
B. Đổi (ghi rõ ở Other).
X. Other (please specify)

[Answer]:A

## Question 3: Khi không tìm được khay giải được (câu hỏi bổ sung cho Câu 1)

Nếu bảng quá đầy nên không có bộ 3 khối nào đặt hết được, thuật toán xử lý thế nào?

A. Chọn bộ 3 khối đặt được nhiều khối nhất (ít nhất khối 1×1 nếu còn ô trống), không đảm bảo đặt hết; hết nước đi thì thua.
B. Thua ngay (Game Over) vì bảng đã không còn cách thoát.
X. Other (please specify)

[Answer]:B

## Question 4: Phạm vi "tính trước" (câu hỏi bổ sung cho Câu 1)

A. Chỉ cần tồn tại MỘT cách đặt cả 3 khối (thứ tự và vị trí tùy ý, có tính cả xóa dòng giữa chừng).
B. Như A, nhưng người chơi đặt theo thứ tự nào cũng phải có ít nhất một cách đặt hết (khó hơn, dễ hơn cho người chơi).
X. Other (please specify)

[Answer]:B

## Question 5: Làm rõ Câu 3 và Câu 4 khi kết hợp (follow-up)

Câu 4 = B đòi hỏi mức chặt: với MỌI thứ tự đặt 3 khối đều phải có cách đặt hết. Câu 3 = B nói không tìm được khay "giải được" thì thua ngay. Có những bảng mà vẫn có khay giải được theo MỘT thứ tự nhưng không có khay nào giải được theo MỌI thứ tự. Ở bảng như vậy:

A. Thử mức chặt (mọi thứ tự) trước; nếu không có khay nào đạt thì hạ xuống mức "tồn tại một thứ tự đặt hết"; chỉ khi cả mức này cũng không có thì thua ngay.
B. Chỉ dùng mức chặt (mọi thứ tự); không có khay nào đạt thì thua ngay, dù vẫn còn khay giải được theo một thứ tự.
X. Other (please specify)

[Answer]:A
