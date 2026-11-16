# Requirements Analysis Questions — Gemstone Journey

Nguồn: file requirements (DocumentKB `01a1cee8-…`, FR-01..FR-08, NFR-01..NFR-06), scope và mockup đã duyệt, codekb.

Đánh giá yêu cầu:
- **Loại:** enhancement (nâng cấp app đã có)
- **Phạm vi:** nhiều thành phần (game, home, Firebase, assets, cấu hình nền tảng)
- **Độ phức tạp:** standard
- **Depth:** Standard

Các câu hỏi dưới đây chỉ hỏi những điểm còn mở.

---

## Q1. Sau khi hoàn thành level 36 (Journey Complete), màn Home và nút PLAY hoạt động thế nào?

A. Home hiển thị "Journey Complete". Bấm PLAY sẽ chơi lại Ruby · Bling
B. Bấm PLAY sẽ bắt đầu lại hành trình từ Rose Quartz · Rough Stone, nhưng vẫn giữ thông tin "đã hoàn thành" và high score
C. Bấm PLAY vào chế độ chơi tự do (endless Classic), không có mục tiêu điểm
X. Other (please specify)

[Answer]:C

---

## Q2. Khi thua và chọn BACK TO MENU (thay vì PLAY AGAIN), tiến trình đã lưu xử lý thế nào?

A. Vẫn đặt về Rough Stone của level lớn hiện tại. Bấm PLAY lần sau sẽ vào Rough Stone (khớp với luật FR-02)
B. Giữ nguyên level đang chơi. Chỉ PLAY AGAIN mới về Rough Stone
X. Other (please specify)

[Answer]:A

---

## Q3. Màn Game Over hiện có nút REVIVE (FREE) và SHARE SCORE. Trong chế độ level, giữ hay bỏ hai nút này?

A. Bỏ cả hai
B. Giữ REVIVE (mỗi level hồi sinh được một lần), bỏ SHARE
C. Giữ SHARE, bỏ REVIVE
D. Giữ cả hai
X. Other (please specify)

[Answer]:C

---

## Q4. Theme Neon/Wood/Jewel hiện có trong Settings và màu theo đá quý (mục 5.1 của requirements) xử lý thế nào?

A. Bỏ chọn theme. Màu UI tự đổi theo đá quý của level hiện tại (theo 5.1)
B. Giữ chọn theme cho bảng và khối. Màu đá quý chỉ dùng cho header, Victory và thanh tiến độ
C. Giữ nguyên theme hiện tại, không áp dụng màu đá quý
X. Other (please specify)

[Answer]:A

---

## Q5. Các tính năng gameplay hiện có (khối ice/bomb, combo, tutorial lần đầu) thì sao?

A. Giữ nguyên tất cả (FR-01: giữ gameplay classic hiện tại)
B. Giữ combo và tutorial, bỏ khối ice/bomb
C. Bỏ tutorial, giữ phần còn lại
X. Other (please specify)

[Answer]:A

---

## Q6. Khi điểm vừa đạt mốc trong lúc đang chơi thì sao?

A. Chuyển ngay sang màn Victory, kể cả khi trên bảng vẫn còn nước đi
B. Cho chơi tiếp đến khi hết nước đi. Thắng nếu điểm cuối cùng đạt mốc
X. Other (please specify)

[Answer]:A

---

## Q7. High score theo từng level (FR-08 `high_scores`) hiển thị ở đâu? Không có màn chọn level.

A. Trên header khi chơi (BEST của level đó) và trên màn Victory
B. Chỉ lưu dữ liệu để dùng sau, không hiển thị
C. Hiển thị trên Home cùng với level hiện tại
X. Other (please specify)

[Answer]:A

---

## Q8. Dữ liệu cũ từ Time Attack (`high_score_time`) và high score Classic (`high_score`) xử lý thế nào?

A. Gỡ hẳn code Time Attack. Bỏ qua các key cũ, không migrate
B. Ẩn Time Attack nhưng giữ code (dễ bật lại sau)
C. Gỡ Time Attack. Chuyển `high_score` cũ thành điểm hiển thị "all-time best"
X. Other (please specify)

[Answer]:A

---

## Q9. Trạng thái mute trong Settings hiện không được lưu. Âm thanh mới (victory, unlock) cần tuân theo mute thế nào?

A. Lưu trạng thái mute. Mọi âm thanh, kể cả victory và unlock, tuân theo nó
B. Không lưu mute. Âm thanh mới vẫn tuân theo mute trong phiên chơi
X. Other (please specify)

[Answer]:A

---

## Q10. Remote Config được fetch khi nào? FR-03 ghi là "khi khởi động app".

A. Fetch khi khởi động và activate ngay nếu kịp. Nếu không kịp hoặc lỗi thì dùng giá trị đã cache hoặc mặc định trong app. Khoảng fetch tối thiểu là 12 giờ (mặc định của Firebase)
B. Như A, nhưng chỉ áp dụng mốc điểm mới cho level kế tiếp, không đổi giữa ván đang chơi
C. Fetch mỗi lần bấm PLAY
X. Other (please specify)

[Answer]:A

---

Trả lời trong chat được, ví dụ: "1A 2A 3A 4B 5A 6A 7A 8A 9A 10B"

---

## Consolidated Summary Confirmation

- Q1: Sau level 36, bấm PLAY vào chế độ chơi tự do (endless Classic), không có mục tiêu điểm
- Q2: Thua rồi chọn BACK TO MENU cũng đặt tiến trình về Rough Stone của level lớn hiện tại
- Q3: Game Over: giữ SHARE SCORE, bỏ REVIVE
- Q4: Bỏ chọn theme. Màu UI tự đổi theo đá quý của level hiện tại (bảng màu 5.1)
- Q5: Giữ nguyên gameplay: khối ice/bomb, combo, tutorial lần đầu
- Q6: Đạt mốc điểm thì chuyển ngay sang Victory
- Q7: High score của từng level hiển thị trên header (BEST) và trên màn Victory
- Q8: Gỡ hẳn code Time Attack. Bỏ qua key cũ, không migrate
- Q9: Lưu trạng thái mute. Mọi âm thanh, kể cả victory và unlock, tuân theo mute
- Q10: Fetch Remote Config khi khởi động, activate ngay nếu kịp. Nếu không thì dùng cache hoặc giá trị mặc định. Khoảng fetch tối thiểu 12 giờ

Does this all look correct before I generate the requirements artifact?

- Looks correct
- Request changes

[Answer]: Looks correct
