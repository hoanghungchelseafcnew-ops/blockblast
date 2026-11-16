# Delivery Planning Questions — Gemstone Journey

Bước này quyết định **thứ tự xây dựng** ở giai đoạn Construction. Mỗi **Bolt** là một lượt xây dựng trên một phần công việc và kết thúc bằng một thứ chạy được.

Những điều đã cố định từ các bước trước:
- Bolt đầu tiên là **walking skeleton**: bản tối giản chạy từ đầu đến cuối, làm trước để chứng minh các phần ghép được với nhau. Đó là U1 (practices: luôn làm skeleton trước).
- Không dùng git nên mọi việc ghi thẳng vào một thư mục. Vì vậy chỉ có thể làm **tuần tự**, không chạy song song nhiều nhánh cùng lúc. Cũng không thể giao từng unit cho các nhóm khác nhau, vì việc đó cần git.
- Thứ tự phụ thuộc (DAG): U2 và U4 sau U1; U3, U5, U6 sau U2.
- Phụ thuộc bên ngoài duy nhất là **bạn**: tạo Firebase project, file cấu hình, key Remote Config, upload ảnh lên Storage, và tự build/test trên máy khác.

---

## Q1. Sau skeleton (U1), thứ tự các phần còn lại là gì?

A. **Giá trị trước**: U1 → U2 (quy tắc chơi) → U3 (Victory, âm thanh) → U4 (giao diện đá quý, ảnh nền) → U5 (analytics) → U6 (endless). Người chơi có trải nghiệm hoàn chỉnh sớm nhất
B. **Rủi ro trước**: U1 → U4 (ảnh, Storage, font, đổi theme, nhiều file nhất) → U2 → U5 → U3 → U6
C. **Giao diện trước**: U1 → U4 → U2 → U3 → U6 → U5
X. Other (please specify)

[Answer]:A

---

## Q2. Mỗi Bolt gồm bao nhiêu unit?

A. Mỗi Bolt = 1 unit (6 Bolt). Mỗi Bolt kết thúc bằng một bản build để bạn kiểm tra
B. Gộp unit nhỏ: Bolt 1 = U1; Bolt 2 = U2 + U3; Bolt 3 = U4; Bolt 4 = U5 + U6 (4 Bolt)
X. Other (please specify)

[Answer]:A

---

## Q3. Cách đi qua các bước thiết kế và sinh code ở Construction?

A. **Theo từng unit** (mặc định): mỗi unit đi hết Functional Design → NFR → Code Generation rồi mới sang unit kế tiếp. Bạn kiểm tra bản build sau mỗi unit
B. **Theo từng bước**: làm Functional Design cho cả 6 unit, rồi NFR cho cả 6, rồi mới sinh code. Skeleton U1 vẫn được làm trọn trước
X. Other (please specify)

[Answer]:A

---

## Q4. Sau mỗi unit, bạn muốn tôi dừng lại chờ duyệt, hay tự chạy tiếp?

A. **Dừng chờ duyệt ở mỗi checkpoint** (an toàn hơn, vì bạn phải build/test tay và không có git để quay lại)
B. **Tự chạy tiếp** sau khi skeleton đã được duyệt. Chỉ dừng ở Plan Approval, các câu hỏi bắt buộc, và khi có lỗi
X. Other (please specify)

[Answer]:A

---

Trả lời trong chat được, ví dụ: "1A 2A 3A 4A"

---

## Consolidated Summary Confirmation

Does this all look correct before I generate the artifact?

- Q1: Giá trị trước: U1 → U2 → U3 → U4 → U5 → U6
- Q2: Mỗi Bolt = 1 unit (6 Bolt), mỗi Bolt kết thúc bằng một bản build để người dùng kiểm tra
- Q3: Đi theo từng unit (unit-major, tuần tự)
- Q4: Dừng chờ duyệt ở mỗi checkpoint (gated)

- Looks correct
- Request changes

[Answer]: Looks correct
