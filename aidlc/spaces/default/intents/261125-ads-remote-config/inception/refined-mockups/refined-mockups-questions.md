# Câu hỏi thiết kế giao diện chi tiết: Quảng cáo và Remote Config

Bối cảnh từ mã nguồn hiện tại: lớp phủ Game Over dùng nút chính `GemPrimaryButton` (PLAY AGAIN), nút phụ `OverlayButton` (SHARE SCORE) và nút chữ (BACK TO MENU). Hộp thoại dùng mẫu `QuitDialog` với nền `0xFF1C1C2E`, tiêu đề `AppTypography.title()` và hai nút CANCEL, QUIT. Mọi chuỗi giao diện chỉ dùng tiếng Anh.

## Q1. Kiểu nút reward ads trong lớp phủ Game Over

Phác thảo trước chỉ nói nút nằm "cạnh các lựa chọn hiện có". Câu hỏi này chốt thứ bậc trực quan giữa nút reward và PLAY AGAIN.

Nút reward có kiểu nào?

- A. Nút chính (`GemPrimaryButton`) ở trên cùng, PLAY AGAIN chuyển xuống thành nút phụ (`OverlayButton`)
- B. Nút phụ (`OverlayButton`) màu riêng nằm dưới PLAY AGAIN, PLAY AGAIN vẫn là nút chính
- C. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:A

## Q2. Nhãn nút reward ads

Nhãn phải bằng tiếng Anh và hiểu được ngay mà không cần đọc thêm. Sau khi xem quảng cáo, người chơi chơi tiếp ở level đó với bàn cờ sạch.

Nhãn nào được dùng?

- A. WATCH AD TO CONTINUE
- B. WATCH AD TO TRY AGAIN
- C. CONTINUE (WATCH AD)
- X. Other (please specify)

[Answer]:B

## Q3. Dòng "You will return to <tên level>" khi có nút reward

Lớp phủ Game Over hiện nói người chơi sẽ quay về level đầu của viên đá. Khi nút reward hiện, dòng này có thể gây hiểu nhầm vì xem quảng cáo giúp giữ level.

Xử lý dòng này thế nào?

- A. Giữ nguyên dòng hiện tại
- B. Khi nút reward hiện, thêm một dòng nhỏ bên dưới: "Watch an ad to stay on this level"
- C. Khi nút reward hiện, thay dòng hiện tại bằng dòng "Watch an ad to stay on this level"
- D. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:B

## Q4. Nội dung popup cập nhật

Popup theo mẫu `QuitDialog` (nền tối, tiêu đề, nội dung, hai nút) với nút Later bên trái và nút Update bên phải.

Nội dung nào được dùng?

- A. Tiêu đề "Update available", nội dung "A new version of Block Jewel is ready.", nút LATER và UPDATE
- B. Nội dung khác (nêu rõ ở Other)
- C. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:A

## Q5. Banner: kích thước và nền

Banner nằm dưới cùng màn chơi (đã chốt). Câu hỏi này chốt cách chiếm chỗ.

Banner chiếm chỗ như thế nào?

- A. Banner chuẩn cao 50dp, dải nền tối cùng màu giao diện phía sau, nằm dưới cùng trong vùng an toàn
- B. Banner thích ứng theo chiều rộng màn hình (cao hơn trên màn rộng)
- C. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:B

## Q6. Trạng thái chờ sau khi bấm nút reward

Từ lúc bấm nút đến khi quảng cáo mở có thể mất vài giây.

Giao diện lúc chờ như thế nào?

- A. Nút hiện vòng quay và bị khóa cho đến khi quảng cáo mở
- B. Không có trạng thái chờ riêng
- C. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:X - Nên load trước quảng cáo, đến khi user ấn nút xem quảng cáo nếu có quảng cáo sẽ hiện, còn k có thì k show và sẽ coi như họ đã xem quảng cáo rồi . 

## Q7. Mức trợ năng cho các thành phần mới

Các thành phần mới là nút reward, popup cập nhật và vùng banner.

Mức trợ năng nào áp dụng?

- A. Cơ bản: tương phản chữ so với nền tối thiểu 4.5 trên 1, vùng chạm tối thiểu 48dp, mỗi nút có nhãn đọc được bởi trình đọc màn hình
- B. Không có yêu cầu riêng cho thành phần mới
- C. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:A

## Q8. Làm rõ nút reward khi chưa có quảng cáo (câu hỏi bổ sung cho Q6)

Ở Q6 bạn trả lời: tải quảng cáo trước, khi người chơi bấm nút mà có quảng cáo thì hiện, còn không có thì không hiện và coi như họ đã xem. Điều này mâu thuẫn với yêu cầu đã duyệt FR3.1 (và Q5 của requirements-analysis), vốn ẩn nút khi quảng cáo chưa sẵn sàng. Một hệ quả cần biết: nếu không có quảng cáo thì vẫn được thưởng, người chơi có thể tắt mạng để nhận thưởng miễn phí.

Cách nào đúng?

- A. Nút luôn hiện khi `reward_enabled` là true. Bấm nút mà không có quảng cáo thì thưởng ngay, không cần xem. Thay thế yêu cầu ẩn nút của FR3.1
- B. Giữ yêu cầu cũ: ẩn nút khi quảng cáo chưa sẵn sàng, và không thưởng nếu không xem
- C. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:A

## Consolidated Summary Confirmation

- Nút reward: nút chính (`GemPrimaryButton`) ở trên cùng lớp phủ Game Over, PLAY AGAIN chuyển xuống thành nút phụ (Q1)
- Nhãn nút reward: WATCH AD TO TRY AGAIN (Q2)
- Dòng "You will return to <tên level>": giữ, và khi nút reward hiện thì thêm dòng nhỏ "Watch an ad to stay on this level" (Q3)
- Popup cập nhật: tiêu đề "Update available", nội dung "A new version of Block Jewel is ready.", nút LATER và UPDATE (Q4)
- Banner: thích ứng theo chiều rộng màn hình (Q5)
- Quảng cáo reward được tải trước. Nút luôn hiện khi `reward_enabled` là true, và bấm nút mà không có quảng cáo thì thưởng ngay không cần xem. Điều này thay thế yêu cầu ẩn nút khi quảng cáo chưa sẵn sàng trong FR3.1 (Q6, Q8)
- Trợ năng cơ bản: tương phản chữ tối thiểu 4.5 trên 1, vùng chạm tối thiểu 48dp, nhãn đọc được bởi trình đọc màn hình (Q7)

Does this all look correct before I generate the artifact?

- Looks correct
- Request changes

[Answer]: Looks correct
