## Review

**Verdict:** READY
**Reviewer:** aidlc-product-lead-agent
**Iteration:** 1

Người điều phối chép nguyên văn review do reviewer trả về (reviewer không có công cụ ghi file). Reviewer đánh giá dựa trên bản tóm tắt đầy đủ nội dung requirements.md trong yêu cầu.

### Findings

| ID | Severity | Location | Finding | Required action | Status |
|---|---|---|---|---|---|
| R-01 | Major | requirements.md > FR2 (fail → Rough Stone) và FR9 (Endless) | FR2 đưa người chơi về Rough Stone của gem hiện tại khi thua, nhưng tài liệu không nói điều này tác động thế nào đến `completed_levels`, `high_scores` và `highest_level_reached` (chỉ số 1..36). Ví dụ: người chơi đã thắng Shaping, thua ở Polishing rồi bị đưa về Rough Stone. Level Shaping có tính là đã hoàn thành không? `highest_level_reached` có giảm không? Tester sẽ không viết được pass/fail cho phần này. | Thêm tiêu chí kiểm thử: sau khi thua và bị reset, `completed_levels`, `high_scores` và `highest_level_reached` giữ nguyên hay đổi. Sau đó đưa trường hợp này vào bộ test 36 chuyển trạng thái của FR2. | New |
| R-02 | Major | requirements.md > FR9 và Assumptions (Endless) | Chế độ Endless có 3 điểm còn là giả định: chỉ gửi `game_session`, dùng nền và màu Ruby·Bling, và key `endless_high_score`. FR9 không có tiêu chí Pass. FR4 và FR11 cũng chưa nói rõ trong Endless thì header, progress bar và Game Over hiển thị gì khi không có target. Màn hình Game Over có "Target" và "return notice" sẽ vô nghĩa. | Viết Pass cho FR9 (ví dụ: không có Victory, không hiện target hay progress %, high score lưu ở `endless_high_score`). Mô tả header và Game Over ở chế độ Endless. Xin người dùng xác nhận 3 giả định. | New |
| R-03 | Major | requirements.md > FR3 (fallback) và FR5 (NFR5 ngân sách ảnh) | Trạng thái "dùng bản đã activate gần nhất, nếu chưa có thì dùng mặc định" chưa được kiểm thử ở trường hợp xung đột. Ví dụ: Remote Config đã activate nhưng sau đó bị hỏng, hoặc có bản cached nhưng version thấp hơn mặc định. Ngoài ra, NFR5 đặt ngân sách ảnh ≤10MB (hiện khoảng 25MB) nhưng không có bước nào của FR5 bắt buộc nén ảnh, và đây vẫn là giả định. Có nguy cơ vi phạm NFR mà không ai phát hiện. | Thêm một tiêu chí Pass cho trường hợp config cached bị hỏng (dùng mặc định và ghi log). Gắn việc nén ảnh vào một yêu cầu cụ thể với cách đo (tổng dung lượng thư mục `assets/design`), hoặc hạ NFR5 xuống mức khuyến nghị. | New |
| R-04 | Minor | requirements.md > FR1 (Pass) | Tiêu chí "grep `timeAttack` trong `lib/` = 0" chỉ bắt được một tên. Các tên khác như `high_score_time`, timer và chuỗi UI của Time Attack vẫn có thể còn sót. | Mở rộng thành danh sách grep: `timeAttack`, `high_score_time`, `TimeAttack` và các chuỗi UI liên quan. | New |
| R-05 | Minor | requirements.md > FR4 (Pass) | "DebugView shows 4 events" chỉ kiểm tra bằng tay trên máy khác. Chưa có kiểm thử tự động cho payload (tên tham số, `level_index` 1..36). | Thêm unit test cho lớp bọc analytics (mock) để kiểm tra tên sự kiện và tham số. | New |
| R-06 | Minor | requirements.md > FR13 và NFR9 | Chưa có Pass đo được cho FR13 (âm thanh tắt thì mọi âm đều tắt, trạng thái tắt được lưu). NFR9 có 48dp và contrast ≥4.5:1 nhưng không nêu cách kiểm tra. | Thêm tiêu chí Pass cho FR13 và cách kiểm NFR9 (widget test kích thước tối thiểu, checklist contrast cho 6 gem). | New |
| R-07 | Minor | requirements.md > Sources và FR6 | Đánh số lại FR/NFR (FR-01..08 thành FR1..FR8, thêm FR9..FR14) có thể làm mất truy vết tới tài liệu gốc. Truy vết lên ideation chưa có bảng ánh xạ. FR7 là OUT OF SCOPE nhưng vẫn nằm giữa danh sách FR, dễ gây nhầm. | Thêm bảng ánh xạ FR/NFR mới sang ID cũ và sang ideation (scope S-xx, decision D-xx). Chuyển FR7 xuống mục Out of scope. | New |

### Summary

Tài liệu đủ rõ để bắt đầu thiết kế: hầu hết FR có tiêu chí Pass đo được, phạm vi và loại trừ rõ, không có mâu thuẫn lớn. Người duyệt nên cân nhắc ba điểm Major trước khi chuyển bước. Đó là quy tắc dữ liệu khi thua và reset (R-01), chế độ Endless còn dựa trên giả định và thiếu tiêu chí (R-02), và các kịch bản hỏng config cùng ngân sách ảnh (R-03). Ba điểm này có cách xử lý tạm thời nên chưa chặn READY.
