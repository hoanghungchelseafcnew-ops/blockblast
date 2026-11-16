## Review

**Verdict:** READY
**Reviewer:** aidlc-architecture-reviewer-agent
**Iteration:** 1

Người điều phối chép nguyên văn review do reviewer trả về (reviewer không có công cụ ghi file). Reviewer đánh giá dựa trên mô tả thay đổi, chưa đối chiếu với file thật.

### Findings

| ID | Severity | Location | Finding | Required action | Status |
|---|---|---|---|---|---|
| R-01 | Major | contract-design > bảng contracts, mục "Quan hệ với DAG" | Phần bổ sung giải thích rõ: DAG chỉ liệt kê phụ thuộc build-time trực tiếp, cột Consumer liệt kê cả consumer gián tiếp (U3, U6 dùng C5 qua u3→u2→u1 và u6→u2→u1; U5 dùng C4, C5 qua u5→u1). Quy tắc "đổi contract do U1 sở hữu (C1–C5, E1, E3) phải kiểm tra mọi consumer trong bảng" đã loại bỏ mâu thuẫn. | Không cần làm thêm. | Resolved |
| R-02 | Major | contract-design > C1/C2/C5 `u1_defaults`, `switch_rule` | Giá trị mặc định của U1 đã rõ cho các phần U2 mở rộng. C1: `unlockedGemId` luôn null, `journeyCompleted` luôn false, level 36 thắng thì giữ nguyên 36, không có `onLevelLost`. C2: enum đủ 5 giá trị ngay từ U1, `bestScore` = 0 và UI ẩn BEST khi bằng 0. C5: `highScore` trả 0, `saveHighScore` tồn tại nhưng chưa dùng. Quy tắc switch phải exhaustive và không có `default` làm việc thêm giá trị enum gây lỗi biên dịch ở mọi call site. Cách này đủ an toàn. Lưu ý nhỏ: quy tắc chỉ có hiệu lực nếu `flutter analyze` hoặc lint được chạy sạch, mà team tự chạy thủ công. | Không chặn. Nhắc ghi vào checklist Build and Test rằng phải chạy `flutter analyze` sau mỗi thay đổi enum. | Resolved |
| R-03 | Major | contract-design > C5 `write_failure_recovery`, C1, E3 `invariant_scope` | Cơ chế dirty-key đã đóng khoảng trống: giá trị đúng giữ trong cache, ghi lại ở lần ghi kế tiếp, `flushDirty()` khi `paused`, tối đa 3 lần retry mỗi key. C1 tham chiếu cơ chế này. `highestLevelReached` không giảm trong phiên và qua các lần ghi thành công, ngoại lệ khi key progress hỏng (về 1) được chấp nhận. Rủi ro còn lại là app bị kill khi còn dirty key, đã được ghi nhận. Chấp nhận với quy mô dự án cá nhân. | Không cần làm thêm. | Accepted risk |
| R-04 | Minor | contract-design > E1 `validation_bounds_location`, bảng open-questions | Cận 1..10M là hằng số trong code (`LevelConfigService.maxTargetScore`), không nằm trong schema, nên đổi cận không cần `_v2`. `allowedImageHosts` xử lý tương tự. Đường dẫn Storage `bg/<gemId>/<subOrder>.jpg` đã được đề xuất và hạn chót là trước khi upload ở U4. Không còn chặn việc xây dựng. | Chốt đường dẫn Storage trước U4 như đã ghi. | Resolved |
| R-05 | Minor | contract-design > E1 `config_source_signal`, C4 `setConfigSource`, E2 `x-user-properties` | `LevelConfig.source` ∈ {remote, cached, default} được log lúc khởi động. C4 có `setConfigSource` gọi một lần sau bootstrap. E2 thêm user property `config_source` ở dạng cộng thêm. Việc U1 chưa có analytics (U5 mới có) vẫn ổn vì U1 chỉ cần log. | Không cần làm thêm. | Resolved |
| R-06 | Minor | contract-design > E2 `highest_level_reached`, open questions | Ghi chú phải ép kiểu số khi phân tích đã giải quyết vấn đề sắp xếp chuỗi ('10' < '9'). Tên `game_session` vẫn chưa chốt, nhưng có hạn chót trước khi phát hành U5 và chưa có consumer nào phụ thuộc. | Chốt tên `game_session` trước khi phát hành U5. | Unresolved |
| R-07 | Minor | contract-design > E3 `change_rules`, `accepted_risks` | Parser JSON của progress và high_scores bỏ qua field lạ, không coi là hỏng. Rủi ro hạ cấp có thể mất tính năng mới nhưng dữ liệu cũ vẫn dùng được, được ghi là rủi ro chấp nhận. | Không cần làm thêm. | Accepted risk |

### Summary

Bản sửa đã xử lý các điểm chặn trước đó: không còn finding Critical và không còn Major mở (R-01, R-02 Resolved, R-03 Accepted risk). Một developer có thể xây U1 từ tài liệu này mà không cần hỏi lại kiến trúc. Điểm còn mở duy nhất là việc chốt tên sự kiện `game_session` (R-06, Minor), cần xong trước khi phát hành U5.
