## Review

**Verdict:** READY
**Reviewer:** aidlc-architecture-reviewer-agent
**Iteration:** 1

Người điều phối chép nguyên văn review do reviewer trả về (reviewer không có công cụ đọc/ghi file). Reviewer đánh giá dựa trên mô tả thay đổi, chưa đối chiếu với file thật.

### Findings

| ID | Severity | Location | Finding | Required action | Status |
|---|---|---|---|---|---|
| R-01 | Major | units-generation > U1 (thứ tự nội bộ 4 bước) | Thứ tự 4 bước đã giải quyết rủi ro ban đầu. Mỗi bước có thể build riêng. Bước (1) không đổi logic game. Bước (2) có zip backup thứ hai trước khi tách BoardEngine/TurnResolver. Bước (2) cũng có test và ràng buộc gameplay giống hệt (US2.2). Điểm còn lại: không có git nên không có ranh giới rollback tự động giữa các bước. | Không cần sửa thêm. Phần backup thủ công là cách giảm rủi ro được chấp nhận cho dự án một người không dùng git. | Resolved |
| R-02 | Major | units-generation > mục quy ước màu (ThemeManager / VictoryColors / GemTheme) | Quyền sở hữu đã rõ. U1 giữ ThemeManager cho board/block. Header và nút mới dùng AppColors. U3 dùng hằng tạm VictoryColors.accent. U4 là chủ duy nhất của GemTheme, thay mọi tham chiếu ThemeManager rồi xóa victory_colors.dart. Trường hợp U4 chạy trước U3 cũng được xử lý. `Level.assetPath/backgroundUrl` định nghĩa ở U1 và U4 dùng, nên hợp đồng đi đúng hướng u4→u1. | Không cần sửa thêm. | Resolved |
| R-03 | Major | units-generation > DAG (cạnh u5→[u1,u2]) và hợp đồng JourneyOutcome | Cạnh u5→u2 và dòng lý do đã được thêm. Hợp đồng tối thiểu của U1 là `{Level? nextLevel; int highestLevelReached}`. U2 mở rộng bằng `unlockedGemId`, `journeyCompleted` và `onLevelLost`. Dùng AnalyticsService no-op đến U5 giữ đồ thị không có chu trình. Mục song song hóa (sau U1 chạy {U2,U4}, sau U2 chạy {U3,U5,U6}) khớp với DAG. | Không cần sửa thêm. | Resolved |
| R-04 | Major | units-generation > tiêu chí hoàn thành U1 và danh sách điều kiện tiên quyết | Tiêu chí hoàn thành U1 giờ chỉ là Android. iOS được hoãn sang Build & Test nếu không có Mac. Checklist điều kiện tiên quyết của người dùng đã đủ: backup, Firebase Spark, google-services.json, plist nếu có Mac, và key Remote Config `level_config` đã publish. Rủi ro còn lại: iOS có thể chưa được xác minh ở lần phát hành đầu. | Ghi rõ iOS chưa xác minh là rủi ro đã biết ở Build & Test. | Accepted risk |
| R-05 | Major | units-generation > bảng Common DoD và checkpoint coverage | DoD-1 đến DoD-5 áp dụng cho mọi unit, và DoD-2 yêu cầu coverage ≥80% theo từng file. Checkpoint toàn codebase (NFR10) nằm ở Build & Test. Code cũ không thuộc unit nào (animated_background, particle_explosion, app_theme, widget cũ) giao cho U4 xử lý bằng test hoặc xóa. Đã có người chịu trách nhiệm. | Không cần sửa thêm. | Resolved |
| R-06 | Minor | units-generation > bản đồ story US8.5 / US8.6 | US8.5 được thực hiện qua DoD ở mọi unit, và U1 đặt nền test. US8.6 được thực hiện qua DoD-3 ở mọi unit, cộng với phần portrait, font và contrast ở U4. Việc hoàn thành đã được gán rõ cho cơ chế kiểm tra. | Không cần sửa thêm. | Resolved |
| R-07 | Minor | units-generation > U4 (sở hữu GemTheme và code cũ) | U4 giờ nhận thêm trách nhiệm: thay ThemeManager ở BoardCell, DraggableBlock, header U1 và VictoryColors U3, đồng thời dọn code cũ. Phần này làm U4 nặng hơn mô tả ban đầu, và U4 chạm vào file mà U1 và U3 đã sở hữu. Vì thế DoD-2 (coverage ≥80% trên mọi file được sửa) kéo cả các file đó vào phạm vi coverage của U4. | Xác nhận trong units-generation rằng U4 chịu trách nhiệm coverage cho các file đã sửa, và khối lượng này đã được tính vào ước lượng U4. | New |
| R-08 | Minor | units-generation > DoD-2 (đo bằng lcov theo từng file) | Việc đo coverage theo từng file chỉ có ý nghĩa nếu quy trình xác định rõ cách đọc `lcov.info`. Theo team.md, AI không chạy lệnh được, nên người dùng phải tự chạy `flutter test --coverage` và báo kết quả. | Ghi vào DoD-2 lệnh kiểm tra theo file và cách người dùng báo lại kết quả cho từng unit. | New |

### Summary

Bản sửa đã xử lý các điểm chính của R-01 đến R-06. Thứ tự rủi ro của U1 rõ ràng. Quyền sở hữu theme có một chủ duy nhất. DAG đã có cạnh u5→u2 cùng hợp đồng JourneyOutcome. DoD chung được áp dụng cho mọi unit. Còn hai điểm nhỏ không chặn: R-07 và R-08. R-04 chuyển thành Accepted risk vì iOS chỉ được xác minh sau. Verdict READY với 0 Critical, 0 Major còn mở.
