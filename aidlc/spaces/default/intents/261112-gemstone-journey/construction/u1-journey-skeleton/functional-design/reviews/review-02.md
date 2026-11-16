## Review

**Verdict:** READY
**Reviewer:** aidlc-architecture-reviewer-agent
**Iteration:** 2

Người điều phối chép nguyên văn review do reviewer trả về (reviewer không có công cụ file). Reviewer đánh giá dựa trên bản mô tả thay đổi.

### Findings

| ID | Severity | Location | Finding | Required action | Status |
|---|---|---|---|---|---|
| R-01 | Critical | functional-design u1-journey-skeleton > BR5.3, BR5.9, BR4.3, WF4, state machine | Trạng thái `resolving` được đặt ngay khi score ≥ target. Chuyển sang `won` khi animation và onLevelWon cùng xong, hoặc sau 3s thì dùng kết quả từ cache. BR4.3 cập nhật cache trước khi await ghi, và mọi exception đều bị bắt. Vì vậy không còn đường treo, và thời gian khóa input bị chặn trên ở 3s. | Không cần thêm. | Resolved |
| R-02 | Major | BR4.1, BR4.2, BR3.1, entity PlayerProgress | `highestLevelReached` nay có nghĩa là level cao nhất đã mở khóa. Các ví dụ khớp nhau: thắng lần đầu, thắng lại khi highest=9, và k=36. Ràng buộc highest ≥ current được áp dụng khi load. | Không cần thêm. Xem R-11 về việc kiểm tra biên của `current`. | Resolved |
| R-03 | Major | BR1.8, BR1.1, BR1.5, WF1 | Deadline cứng 3.5s cùng ngân sách theo từng bước (init ≤1.5s, fetch ≤ min(2s, deadline−0.5s−now), prefs ≤0.5s) giúp bootstrap luôn dừng và vào được Home. Quy tắc prefs rơi về mặc định lại tạo rủi ro mất dữ liệu, ghi ở R-12. | Không cần thêm cho R-03 gốc. | Resolved |
| R-04 | Major | BR1.3, BR1.2 | Parser URI chuẩn, bắt buộc https, không userinfo, port rỗng hoặc 443, host so khớp theo label và so khớp trên cả nguồn remote lẫn cache. Các kiểu giả mạo host đã nêu (userinfo, hậu tố giả) đều bị chặn. | Không cần thêm. Xem R-13 về việc ghim bucket. | Resolved |
| R-05 | Major | BR3.2, BR3.3 | Hàng đợi FIFO duy nhất gồm cả flushDirty ở cuối hàng. Bộ đếm retry theo từng key dừng ở 3 lần. flushDirty khi paused luôn thử mỗi key dirty một lần. Future hoàn tất khi ghi xong hoặc sau khi đánh dấu dirty. Rủi ro dư (tắt app trước khi ghi lại thành công) được ghi rõ là chấp nhận. | Không cần thêm. | Resolved |
| R-06 | Major | BR5.7, BR5.4, entity LevelRound | Overlay Game Over có status `lost` riêng, REVIVE và PLAY AGAIN được định nghĩa rõ, và PLAY AGAIN tạo `roundId` mới. Việc sửa contract C2 `u1_defaults` chỉ nằm trong ghi chú của rules.md. Xem R-13. | Không cần thêm cho R-06 gốc. | Resolved |
| R-07 | Major | BR5.1, BR5.3, BR5.5, BR5.6, BR5.10 | Score được tính ngay lúc đặt khối. Kiểm tra thắng diễn ra trước animation, và `clearing` chặn drag trong 180ms. target = max(1, targetScore). Kiểm tra no-moves chỉ chạy khi chưa thắng, sau animation. Không còn xung đột. | Không cần thêm. | Resolved |
| R-08 | Minor | WF7 | Việc hoãn AC1.6.2 sang u5 đã được nêu rõ. U5 SessionTracker tự đăng ký lifecycle observer. | Không cần thêm. | Resolved |
| R-09 | Minor | traceability | Phần N/A ngược chỉ còn 6 quy tắc (BR1.6, BR1.7, BR2.3, BR2.4, BR6.4, BR7.2), mỗi quy tắc đều có lý do cụ thể. Kiểm tra bằng script cho thấy 36 quy tắc, không có đích lạ và không có quy tắc mồ côi. | Không cần thêm. | Resolved |
| R-10 | Minor | BR3.5 | Giá trị `tutorial_completed` không phải bool thì được xử lý là false kèm cảnh báo. | Không cần thêm. | Resolved |
| R-11 | Minor | BR3.1, entity PlayerProgress | Brief chỉ nêu việc loại `completedLevels` ngoài khoảng 1..36 và đặt highest = max(read, current). Không thấy quy tắc kẹp `currentLevel` vào 1..36 (giá trị 0, âm, >36, hoặc không phải int). `highest ≥ current` có thể đẩy highest lên ngoài miền hợp lệ. | Ghi rõ trong BR3.1: `currentLevel` ngoài 1..36 hoặc sai kiểu thì về mặc định (1) kèm cảnh báo, rồi mới tính highest. | New |
| R-12 | Major | BR1.8, BR3.3, WF1 | Khi đọc prefs quá 0.5s, các key chưa đọc dùng giá trị mặc định. Dart không hủy được lần đọc đang chạy, và các lần ghi sau đó (kể cả flushDirty) có thể ghi mặc định (level 1, completedLevels rỗng) đè lên tiến trình thật đã lưu trên đĩa. Hậu quả là mất tiến trình người chơi không phục hồi được, và team không dùng git. | Chọn một trong hai. (a) Khi một key bị cắt do timeout, key đó vào chế độ "chưa nạp" và không bị ghi cho tới khi lần đọc đang chạy hoàn tất, rồi hợp nhất kết quả đọc (max/hợp). (b) Ghi nhận rõ trong WF1 rằng prefs timeout thì chặn mọi ghi key đó trong phiên. | New |
| R-13 | Minor | BR5.7, contract C2 `u1_defaults`, BR1.3 | Hai điểm. (1) Việc sửa contract C2 chỉ nằm trong ghi chú của rules.md, còn `contract-summary` ở inception không đổi. Các unit sau đọc contract-summary sẽ thấy mâu thuẫn trạng thái Game Over. (2) BR1.3 chấp nhận mọi `<label>.firebasestorage.app`, tức là bucket của bất kỳ dự án Firebase nào, không riêng dự án của game này. | (1) Thêm tham chiếu chéo tới bản sửa C2 trong tài liệu bàn giao cho U2, hoặc ghi vào danh sách amendment của contract. (2) Ghim label hoặc bucket theo dự án của app, hoặc ghi chú đây là rủi ro đã chấp nhận do URL đến từ Remote Config do team kiểm soát. | New |

### Summary

Cả 10 phát hiện cũ đều đã được xử lý, gồm Critical R-01 (không còn đường treo) và 5 Major. Còn 1 Major mới, R-12: prefs timeout rơi về mặc định rồi ghi đè tiến trình thật. Với 1 Major (≤2) và 0 Critical, verdict là READY, nhưng cần sửa R-12 ở đầu bước triển khai. R-11 và R-13 là Minor, không chặn.
