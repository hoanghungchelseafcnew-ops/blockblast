## Review

**Verdict:** READY
**Reviewer:** aidlc-product-lead-agent
**Iteration:** 1

Người điều phối chép nguyên văn review do reviewer trả về (reviewer không có công cụ ghi file). Reviewer đánh giá dựa trên mô tả thay đổi, chưa đối chiếu với nguyên văn requirements.md.

### Findings

| ID | Severity | Location | Finding | Required action | Status |
|---|---|---|---|---|---|
| R-01 | Major | requirements.md > FR2.3a, FR2.3b | Ảnh hưởng của việc thua lên completed_levels, high_scores và highest_level_reached đã được xác định rõ. Thua sẽ xóa mọi sub-level của gem hiện tại, kể cả level đã thắng. Các gem đã hoàn thành không bị ảnh hưởng. high_scores được giữ lại và highest_level_reached không bao giờ giảm. Tiêu chí Pass có ví dụ cụ thể và kiểm thử được (Amethyst·Shaping → Rose Quartz vẫn đủ 6 sub). | Không cần. Khi code, nên có thêm một test cho mốc ranh giới "thua ở sub-level đầu tiên của gem" (chưa có tiêu chí Pass riêng cho mốc này). | Resolved |
| R-02 | Major | requirements.md > FR9.1–FR9.8 | Chế độ endless đã được viết lại đầy đủ: không có target hay Victory, lưu điểm khi QUIT/Home/background, tiếp tục từ điểm đã lưu, thua thì về 0. Header, hộp thoại thoát, màn game over và analytics đều được mô tả. Pass có kịch bản cụ thể (1,200 → QUIT → vào lại; thua → PLAY tiếp = 0). FR9.3 (bàn cờ bắt đầu trống khi resume) là assumption đã được gắn nhãn. | Không cần. Xác nhận FR9.3 với người dùng nếu muốn giữ nguyên trạng bàn cờ. | Resolved |
| R-03 | Major | requirements.md > FR3.3a, NFR5 | Config cache bị hỏng giờ được coi là mất và đặt về mặc định (level 1 target 500), có ghi log lỗi. Tiêu chí Pass dùng cache giả lập bị hỏng nên kiểm thử được. Ngân sách ảnh ≤10MB đã hạ xuống thành khuyến nghị, đo bằng `du -sh`, và gắn nhãn assumption, nên không còn là yêu cầu mơ hồ. | Không cần. | Resolved |
| R-04 | Minor | requirements.md > FR1 Pass | Lệnh grep không phân biệt hoa thường, bao phủ timeattack, "time attack", high_score_time, _timeLeft, _startTimer trong lib/. Phạm vi đã đủ rộng. | Không cần. | Resolved |
| R-05 | Minor | requirements.md > FR4 Pass | Đã bổ sung unit test với analytics service được mock, kiểm tra tên và tham số của event và level_index 1..36. DebugView vẫn là bước kiểm tra thủ công do người dùng chạy, phù hợp với team practice. | Không cần. | Resolved |
| R-06 | Minor | requirements.md > FR13, NFR9 | FR13 có unit test mute cho cả 6 âm thanh và kiểm tra mute được giữ qua lần khởi động lại. NFR9 có widget test nút ≥48dp và checklist tương phản cho 6 bảng màu gem. Cả hai đều có Pass đo được. | Không cần. Lưu ý: ngưỡng tương phản trong checklist nên ghi rõ (ví dụ WCAG AA 4.5:1) để tránh diễn giải khác nhau. | Resolved |
| R-07 | Minor | requirements.md > FR7, §7 | FR7 đã chuyển sang mục Out of scope và giữ ID dạng stub. Ma trận truy vết §7 ánh xạ FR1–FR14 và NFR1–NFR11 sang ID gốc và S-xx/D-xx/Q của ideation. Vấn đề truy vết đã được giải quyết. Việc giữ ID FR7 ở đầu mục Out of scope là chấp nhận được. | Không cần. | Resolved |
| R-08 | Minor | requirements.md > FR9.2 vs FR9.4 | Hai điểm chưa được nói rõ: (a) điểm endless_saved_score khi app bị kill đột ngột (không có sự kiện QUIT/background) được lưu hay không; (b) endless_saved_score được cập nhật định kỳ hay chỉ ở các sự kiện thoát. Dev có thể hiểu khác nhau. | Thêm một dòng nêu rõ hành vi khi app bị kill. Đề xuất: chỉ lưu ở các sự kiện đã liệt kê, nên mất điểm khi bị kill, và ghi đây là hạn chế đã chấp nhận. | New |

### Summary

Cả ba finding Major (R-01 đến R-03) và bốn finding Minor (R-04 đến R-07) đã được xử lý bằng các tiêu chí Pass kiểm thử được, và các quyết định ở gate được phản ánh đúng. Kỹ sư có thể bắt đầu mà không cần hỏi lại. Chỉ còn một điểm Minor mới (R-08) về hành vi khi app bị kill đột ngột, không chặn việc bắt đầu.
