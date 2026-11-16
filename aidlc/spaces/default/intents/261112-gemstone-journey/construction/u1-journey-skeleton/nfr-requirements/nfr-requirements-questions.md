# NFR Requirements Questions — U1 `u1-journey-skeleton`

Đã chốt từ trước (không hỏi lại):
- 60 FPS khi kéo khối (NFR5), chơi offline đầy đủ (NFR6).
- Hạn chót khởi động 3,5 giây (BR1.8). Resolving tối đa 3 giây (BR5.9).
- Không hardcode secret (NFR11). Chỉ thêm `firebase_core` và `firebase_remote_config` (NFR4).
- Coverage ≥ 80% (NFR10). Đối tượng 13+, không phát hành EU.

Review Functional Design còn để lại 3 góp ý (R-11, R-12, R-13). Câu Q1 và Q2 xử lý chúng.

---

## Q1. Đọc SharedPreferences quá 0,5 giây lúc khởi động thì sao? (góp ý R-12, Major)

Nếu dùng mặc định rồi ghi đè lên đĩa, tiến trình thật có thể bị mất vĩnh viễn.

A. Key nào bị cắt do timeout thì vào trạng thái "chưa nạp": **cấm ghi** key đó cho đến khi lần đọc đang chạy xong. Đọc xong thì hợp nhất (giữ level cao hơn, hợp nhất completedLevels). Trong lúc chờ, Home vẫn hiện level 1
B. Không đặt timeout cho phần đọc prefs (đọc cục bộ thường chỉ vài ms). Bootstrap chờ đọc xong, chỉ phần Firebase bị giới hạn thời gian
X. Other (please specify)

[Answer]:B

---

## Q2. URL ảnh có nên chỉ nhận bucket Firebase **của dự án bạn** không? (góp ý R-13)

Hiện tại BR1.3 chấp nhận mọi `<label>.firebasestorage.app`.

A. Có. Chỉ nhận bucket của dự án (lấy `storage_bucket` từ file cấu hình Firebase lúc chạy)
B. Không cần. URL đến từ Remote Config mà chỉ bạn sửa được, nên chấp nhận rủi ro
X. Other (please specify)

[Answer]:B

---

## Q3. Log lỗi và cảnh báo (config hỏng, ghi lỗi, timeout) xuất ra đâu ở U1?

A. Chỉ `debugPrint` (chỉ thấy khi chạy debug). Thêm Crashlytics thì vi phạm NFR4, còn Analytics thì để U5
B. `debugPrint` và lưu 20 log gần nhất trong bộ nhớ để xem bằng màn debug ẩn
X. Other (please specify)

[Answer]:A

---

## Q4. Mục tiêu kích thước app cho U1?

A. Không đặt mục tiêu ở U1. Ảnh nền chưa được khai báo nên APK gần như không đổi. Việc nén ảnh làm ở U4
B. Đặt mục tiêu: APK release ≤ 40MB sau U1
X. Other (please specify)

[Answer]:A

---

Trả lời trong chat được, ví dụ: "1A 2A 3A 4A"

---

## Consolidated Summary Confirmation

Does this all look correct before I generate the artifact?

- Q1: Không đặt timeout cho phần đọc SharedPreferences. Bootstrap chờ đọc xong, chỉ phần Firebase bị giới hạn thời gian (thay phần prefs 0,5s trong BR1.8)
- Q2: Không ghim bucket. Chấp nhận mọi `<label>.firebasestorage.app`, vì URL đến từ Remote Config do người dùng kiểm soát (rủi ro chấp nhận)
- Q3: Log chỉ dùng `debugPrint`. Không thêm Crashlytics
- Q4: Không đặt mục tiêu kích thước APK ở U1, việc nén ảnh làm ở U4

- Looks correct
- Request changes

[Answer]: Looks correct
