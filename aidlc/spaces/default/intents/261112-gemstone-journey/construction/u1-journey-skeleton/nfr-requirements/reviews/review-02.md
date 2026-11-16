## Review

**Verdict:** READY
**Reviewer:** aidlc-architecture-reviewer-agent
**Iteration:** 2

Người điều phối chép nguyên văn review do reviewer trả về (reviewer không có công cụ file). Reviewer đánh giá dựa trên bản mô tả thay đổi.

### Findings

| ID | Severity | Location | Finding | Required action | Status |
|---|---|---|---|---|---|
| R-01 | Major | nfr-requirements > NFR6.8, NFR6.8.1, bảng graceful-degradation | Hành vi đã được xác định rõ. Hàng đợi ghi chỉ chạy sau khi load() kết thúc và các lần ghi sớm được xếp hàng. Lỗi load() thì thử lại 1 lần, sau đó repository chuyển sang READ-ONLY cho cả phiên. Có unit test cho cả hai trường hợp (lỗi 1 lần và 2 lần) và test "save trước load". Không còn mơ hồ và không còn rủi ro ghi đè dữ liệu thật bằng giá trị mặc định. | Không còn việc cần làm. | Resolved |
| R-02 | Major | nfr-requirements > NFR9.1, NFR8 | NFR9 có tiêu chí đo được: PLAY ≥48×48dp và tương phản 4.32:1 trên large text với ngưỡng AA ≥3:1. NFR8 N/A có bằng chứng (Info.plist cho phép 3 hướng, manifest không khóa) và có chủ sở hữu là U4. | Không còn việc cần làm. | Resolved |
| R-03 | Major | nfr-requirements > NFR6.2, NFR6.2.1 | Việc bắt mọi loại lỗi (Exception, Error) cùng timeout đã được nêu, có test fake cho throw và hang. Trường hợp thiếu plist trên iOS có đường xử lý và được hoãn có chủ đích sang Build & Test vì không có Mac. Việc hoãn này được ghi rõ và phù hợp với unit-of-work R-04. | Không còn việc cần làm. | Resolved |
| R-04 | Major | nfr-requirements > NFR6.10 và bảng dòng log kỳ vọng | Quy tắc "một dòng warn/error cho mỗi NGUYÊN NHÂN fallback cộng 2 dòng info" đã nhất quán, và bảng kỳ vọng có 5 kịch bản. Mâu thuẫn "đúng một dòng" đã hết. | Không còn việc cần làm. | Resolved |
| R-05 | Minor | nfr-requirements > NFR11.6, traceability | NFR6.14 đã chuyển sang NFR11.6, danh sách traceability được cập nhật, và nguồn gốc của NFR6.10–6.13 được ghi chú. | Không còn việc cần làm. | Resolved |
| R-06 | Minor | nfr-requirements > NFR6.1, NFR5.2 | Hai mục đã nói rõ 3.5s không gồm thời gian đọc SharedPreferences. | Không còn việc cần làm. | Resolved |
| R-07 | Minor | nfr-requirements > NFR4.2, NFR4.3 | Đã xác nhận shared_preferences ^2.2.3 có sẵn trong pubspec. Tiêu chí kiểm tra NFR4.2 gồm pub get, analyze và build apk --debug. | Không còn việc cần làm. | Resolved |
| R-08 | Minor | nfr-requirements > NFR11.3, NFR11.4 | Đơn vị 65,536 byte UTF-8 và quy tắc URL (cho phép/cấm) đã đầy đủ, có bộ test biên cụ thể. | Không còn việc cần làm. | Resolved |
| R-09 | Minor | nfr-requirements > NFR6.5, NFR10.2 | NFR6.5 giờ đo được ("tối đa 2 lần fetch mỗi thiết bị mỗi 24h"). NFR10.2 yêu cầu sửa widget_test.dart trước và tách mục tiêu coverage của U1 (≥80% cho các tệp U1 tạo hoặc sửa) khỏi mục tiêu toàn codebase (đo ở Build & Test). | Không còn việc cần làm. | Resolved |
| R-10 | Minor | nfr-requirements > rủi ro bucket không ghim | Rủi ro được chấp nhận có chủ sở hữu (U4) và điều kiện xem lại (trước lần tải ảnh mạng đầu tiên). | Không còn việc cần làm. | Accepted risk |
| R-11 | Minor | nfr-requirements > NFR6.8.1 và NFR6.10 | Chế độ READ-ONLY làm mọi thao tác ghi bị bỏ qua kèm log warn. Nếu mỗi lần ghi bị bỏ qua đều phát một dòng warn, quy tắc "một dòng cho mỗi nguyên nhân" của NFR6.10 sẽ bị phá. Brief không nói rõ có gộp dòng hay không. | Khi duyệt, kiểm tra rằng dòng warn READ-ONLY chỉ phát một lần mỗi phiên, hoặc ghi rõ ngoại lệ trong NFR6.10. | New |
| R-12 | Minor | nfr-requirements > NFR6.2 (timeout) | Brief nêu có timeout cho Firebase.initializeApp() nhưng không nêu giá trị. Nếu giá trị không nằm trong ngân sách 3.5s của NFR6.1 thì không kiểm chứng được. | Khi duyệt, kiểm tra giá trị timeout là số cụ thể và nằm trong ngân sách 3.5s. | New |
| R-13 | Minor | nfr-requirements > NFR11.4 | URL chứa `..` bị từ chối "sau khi chuẩn hóa". Cần xác định thứ tự: kiểm tra trên chuỗi đã chuẩn hóa, và cả dạng mã hóa phần trăm (`%2e%2e`). Đây là điểm kiểm thử, không phải lỗ hổng, vì host đã bị khóa. | Thêm test `%2e%2e` nếu chưa có. | New |

### Summary

Cả ba mục Major của vòng 1 (R-01 đến R-03) đã được xử lý bằng hành vi đơn nghĩa và có test tương ứng. Không còn mục Critical hay Major nào mở. Ba ghi chú Minor mới (R-11 đến R-13) không chặn READY, và vì không đọc được artifact nên cần xác nhận chúng khi duyệt. Một developer có thể xây dựng unit này mà không cần hỏi thêm kiến trúc sư.
