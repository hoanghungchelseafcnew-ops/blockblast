# Tech Stack Decisions: u3-tray-algorithm

Nguồn: technology-stack.md (code KB), functional-spec.md, rules.md (BR5.1–BR5.4), requirements.md (NFR1, NFR2, NFR3, NFR5).

## Quyết định công nghệ

| ID | Quyết định | Lý do |
|---|---|---|
| NFR5.1 | Dart thuần, không thêm gói; `flutter analyze` sạch, `dart format`, theo `flutter_lints` | quy ước team |
| NFR5.2 | Mã nằm trong `lib/features/<feature>/logic/` hoặc `lib/core/*`, không phụ thuộc Flutter widget; `TrayGenerator`, `DifficultyProfile` là lớp thuần, `Random` tiêm qua constructor hoặc tham số | kiến trúc feature-first; test theo seed (BR5.2) |
| NFR5.3 | Mọi hằng số cân bằng ở một lớp `DifficultyConstants` (BR5.1) | chỉnh mà không sửa logic |
| NFR5.4 | Bộ giải là tìm kiếm theo chiều sâu có ngân sách nút, thoát sớm; không dùng isolate hay thread | bảng 8×8 và khay 3 khối đủ nhỏ; ngân sách bảo vệ luồng UI, tránh độ phức tạp của isolate |

## Hiệu năng

| ID | Yêu cầu | Cách kiểm |
|---|---|---|
| NFR1.1 | Chuẩn bị một khay (gồm bộ giải strict, relaxed, fallback) dưới 16 ms ở trường hợp xấu nhất trên máy tầm trung | test hiệu năng trên bảng đầy 60–90%; người dùng đo trên máy thật vì AI không chạy được |
| NFR1.2 | Bộ giải duyệt tối đa `solverNodeBudget` (khởi điểm 20000) nút và `maxStrictCandidates` + `maxRelaxedCandidates` (khởi điểm 30 + 30) ứng viên cho mỗi lần chuẩn bị | test đếm nút; ngân sách cạn không gây Game Over sai (BR5.4) |
| NFR1.3 | Bảng nhiều ô trống (độ đầy dưới 60%) thường tìm được khay strict ở ứng viên đầu tiên; thời gian trung bình thấp hơn đáng kể mức trần | test đo thời gian trung bình trên nhiều seed |

## Tính đúng đắn và kiểm thử

| ID | Yêu cầu | Cách kiểm |
|---|---|---|
| NFR2.1 | Bảng có ít nhất 3 ô trống thì không bao giờ Game Over ở bước chuẩn bị khay (BR1.5); khay trả về luôn đặt hết được ít nhất theo mức tier ghi trên khay | test thuộc tính trên nhiều seed và nhiều bảng sinh ngẫu nhiên |
| NFR2.3 | Khay đạt tier strict thì cả 6 thứ tự đều có cách đặt hết (kiểm độc lập bằng bộ kiểm tra trong test) | test đối chiếu với bộ giải vét cạn trên bảng nhỏ |
| NFR2.4 | Cùng bảng, level, seed cho cùng khay (BR5.2) | test seed |
| NFR3.1 | Unit test cho `DifficultyProfile` (tỉ lệ ở level 1, 18, 36; bảng trên và dưới 60%), `TrayGenerator` (khối cứu, tối đa 2 khối lớn, ba tier, Game Over), bộ giải; cập nhật test Game Over hiện có | quy ước team |
| NFR3.2 | Coverage dòng tối thiểu 80% toàn codebase; `test/widget_test.dart` pass; người dùng chạy `flutter analyze` và `flutter test --coverage` rồi báo kết quả | quy ước team |
