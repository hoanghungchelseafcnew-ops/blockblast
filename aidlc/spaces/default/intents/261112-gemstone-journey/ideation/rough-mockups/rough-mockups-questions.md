# Rough Mockups Questions — Gemstone Journey

Bối cảnh từ code hiện tại:
- `home_screen.dart` có 2 thẻ chế độ chơi: Classic và Time Attack, nút Settings (âm thanh, theme) và popup Daily Gift.
- `game_screen.dart` có header SCORE/BEST và overlay GAME OVER với các nút chơi lại và "BACK TO MENU".

Scope đợt này gồm S-01 (chỉ Classic), S-06 (Victory), S-07 (chọn level lớn và level con).

---

## Q1. Màn hình Home thay đổi thế nào?

A. Thay 2 thẻ chế độ chơi bằng một nút lớn "PLAY / JOURNEY" mở màn hình chọn level lớn. Giữ Settings và Daily Gift
B. Bỏ Home, mở app là vào thẳng màn hình chọn level lớn
C. Giữ thẻ Classic (đổi tên thành Journey), ẩn thẻ Time Attack
D. Chưa xác định
X. Other (please specify)

[Answer]:X - Thay 2 thẻ chế độ chơi bằng một nút lớn "PLAY / JOURNEY" để mở màn hình chơi luôn

---

## Q2. Màn hình chọn level lớn (journey path) trình bày theo kiểu nào?

A. Đường path dọc, cuộn từ dưới lên, 6 viên đá xếp zig-zag (giống bản đồ trong Candy Crush)
B. Lưới 2 × 3 gồm 6 thẻ đá quý
C. Carousel ngang, mỗi lần hiển thị một viên đá
D. Chưa xác định
X. Other (please specify)

[Answer]:X - không cần màn hình chọn level , vào 1 phát là chơi luôn ở level thấp nhất

---

## Q3. Màn hình chọn level con trình bày theo kiểu nào?

A. Danh sách dọc 6 thẻ, mỗi thẻ có thumbnail, tên, mốc điểm, trạng thái và high score
B. Lưới 2 × 3 thẻ thumbnail
C. Path nhỏ giống màn hình level lớn
D. Chưa xác định
X. Other (please specify)

[Answer]:X không cần màn hình chọn level con 

---

## Q4. Trong lúc chơi, header hiển thị những gì?

A. Tên level (ví dụ "Amethyst · Shaping"), điểm hiện tại / mốc điểm, kèm thanh tiến độ
B. Như A, thêm high score của level
C. Giữ nguyên SCORE/BEST như hiện tại, chỉ thêm tên level
D. Chưa xác định
X. Other (please specify)

[Answer]:A

---

## Q5. Khi thua (game over), overlay hiển thị gì?

A. "Level Failed", điểm đạt được / mốc điểm, thông báo sẽ quay về Rough Stone, và 2 nút "Thử lại từ Rough Stone" và "Về màn hình chọn level"
B. Giữ overlay GAME OVER hiện tại, chỉ thêm thông báo quay về level
C. Chưa xác định
X. Other (please specify)

[Answer]:B

---

## Q6. Game hỗ trợ những thiết bị và hướng màn hình nào?

A. Chỉ điện thoại, màn hình dọc
B. Điện thoại và tablet, màn hình dọc
C. Điện thoại và tablet, cả dọc lẫn ngang
D. Chưa xác định
X. Other (please specify)

[Answer]:A

---

## Q7. Có yêu cầu accessibility nào không?

A. Mức cơ bản: kích thước chạm tối thiểu 48dp, chữ đủ tương phản, trạng thái lock không chỉ thể hiện bằng màu (có icon 🔒)
B. Như A, thêm hỗ trợ screen reader (TalkBack/VoiceOver) cho các màn hình menu
C. Không có yêu cầu
D. Chưa xác định
X. Other (please specify)

[Answer]:A

---

## Hướng dẫn trả lời

1. **Guide Me** · 2. **Edit File** · 3. **Chat**

Ví dụ: `[Answer]: A` hoặc `[Answer]: X. mô tả của bạn`


---

# Follow-up Questions

## Q8. Bỏ màn hình chọn level (Q2, Q3) mâu thuẫn với scope đã duyệt. Bạn muốn xử lý thế nào?

Scope đã duyệt có S-07 "Giao diện chọn level" (FR-07 trong file requirements).

A. Bỏ S-07 khỏi scope đợt này: không có màn hình chọn level lớn và level con. Cần sửa lại scope document
B. Giữ S-07 nhưng tối giản: chỉ một màn hình "Journey" xem tiến trình (36 level, trạng thái lock/unlock/completed), không bắt buộc đi qua mỗi lần chơi
C. Giữ đúng S-07 như file requirements (bỏ câu trả lời Q2 và Q3)
D. Chưa xác định
X. Other (please specify)

[Answer]:A

---

## Q9. "Vào là chơi luôn ở level thấp nhất" nghĩa là gì?

A. Vào thẳng level hiện tại theo tiến trình đã lưu (người mới bắt đầu ở Rose Quartz > Rough Stone)
B. Luôn bắt đầu ở level đầu tiên của level lớn hiện tại (Rough Stone)
C. Luôn bắt đầu lại từ Rose Quartz > Rough Stone mỗi lần mở app (không giữ tiến trình giữa các lần mở)
D. Chưa xác định
X. Other (please specify)

[Answer]:A

---

## Q10. Khi bỏ màn hình Home (Q1), Settings và Daily Gift hiện có sẽ xử lý thế nào?

A. Thêm icon ⚙️ Settings trên header màn hình chơi. Daily Gift hiện dạng popup khi mở app (như hiện tại)
B. Thêm icon ⚙️ Settings trên header. Bỏ Daily Gift
C. Bỏ cả Settings và Daily Gift
D. Chưa xác định
X. Other (please specify)

[Answer]:X - Vẫn để màn home nhé, t sửa lại câu 1. Bỏ Daily Gift (theo Requested Changes Feedback)

---

## Requested Changes Feedback

What should change?

[Answer]: tôi muốn câu Q10 sẽ bỏ Daily Gift đi

---

## Consolidated Summary Confirmation

Does this all look correct before I generate the artifact?

- Q1 (đã sửa): Giữ Home. Thay 2 thẻ chế độ chơi bằng một nút lớn "PLAY / JOURNEY" mở thẳng màn hình chơi
- Q2, Q3, Q8: Không có màn hình chọn level lớn/level con. Bỏ S-07 khỏi scope đợt này
- Q9: Bấm PLAY là vào thẳng level hiện tại theo tiến trình đã lưu (người mới bắt đầu ở Rose Quartz > Rough Stone)
- Q10: Settings vẫn ở Home. Bỏ Daily Gift
- Q4: Header khi chơi: tên level, điểm / mốc điểm, thanh tiến độ
- Q5: Giữ overlay GAME OVER hiện tại, thêm thông báo quay về Rough Stone
- Q6: Chỉ điện thoại, màn hình dọc
- Q7: Accessibility cơ bản: chạm tối thiểu 48dp, chữ đủ tương phản, không chỉ dùng màu để báo trạng thái

- Looks correct
- Request changes

[Answer]: Looks correct
