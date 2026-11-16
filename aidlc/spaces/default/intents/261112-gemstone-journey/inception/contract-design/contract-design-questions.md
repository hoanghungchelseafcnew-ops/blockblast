# Contract Design Questions — Gemstone Journey

Bối cảnh:
- App là **một khối Flutter duy nhất**. Ranh giới giữa các unit là **API Dart nội bộ**, gọi đồng bộ hoặc qua `Future` theo ADR-004. Không có REST hay message queue nội bộ.
- Có **3 ranh giới với bên ngoài**, tức là dữ liệu sống lâu hơn một phiên bản app:
  1. **JSON `level_config` trên Firebase Remote Config.** Bạn chỉnh trên console, app đọc.
  2. **Schema event Analytics.** App gửi lên Firebase, bạn đọc trên console hoặc BigQuery.
  3. **Dữ liệu SharedPreferences.** Bản app mới phải đọc được dữ liệu do bản cũ ghi.

Các quy tắc lỗi/timeout đã chốt ở các bước trước: Remote Config timeout 2 giây rồi fallback, mọi lỗi đều log và dùng mặc định, không retry chủ động. Vì vậy các câu hỏi dưới đây chỉ xoay quanh phiên bản và thay đổi schema.

---

## Q1. Versioning của JSON `level_config` trên Remote Config?

A. Giữ trường `version` (số nguyên). App chấp nhận mọi `version` ≥ 1 và **bỏ qua trường lạ** (thay đổi thêm trường là an toàn). Nếu cần đổi cấu trúc gây vỡ, dùng **key mới** (ví dụ `level_config_v2`) thay vì sửa key cũ
B. App chỉ chấp nhận đúng `version = 1`. Version khác thì dùng mặc định
X. Other (please specify)

[Answer]:A

---

## Q2. Đổi tên hoặc tham số event Analytics thì sao?

A. Coi tên event và tên tham số là cố định. Chỉ được **thêm** tham số mới. Muốn đổi thì tạo event mới (ví dụ `level_complete_v2`) để không làm hỏng số liệu cũ
B. Được đổi tự do (dự án mới, chưa có số liệu)
X. Other (please specify)

[Answer]:A

---

## Q3. Schema dữ liệu lưu trên máy (SharedPreferences) qua các phiên bản app?

A. Thêm key `prefs_schema_version` = 1. Khi đọc thấy version thấp hơn thì chạy migration (lần này: gỡ `high_score`, `high_score_time`, `theme_index`, `last_login_date`). Key lạ thì bỏ qua. Key hỏng thì dùng mặc định cho riêng key đó
B. Không versioning. Chỉ đọc từng key, hỏng thì dùng mặc định
X. Other (please specify)

[Answer]:B

---

Trả lời trong chat được, ví dụ: "1A 2A 3A"

---

## Consolidated Summary Confirmation

Does this all look correct before I generate the artifact?

- Q1: JSON `level_config` có trường `version` ≥ 1, bỏ qua trường lạ. Thay đổi gây vỡ thì dùng key mới (`level_config_v2`)
- Q2: Tên event và tham số Analytics cố định, chỉ được thêm. Muốn đổi thì tạo event mới (`..._v2`)
- Q3: SharedPreferences không có versioning. Đọc từng key, key hỏng thì dùng mặc định. Các key cũ vẫn được gỡ một lần (ADR-009)

- Looks correct
- Request changes

[Answer]: Looks correct
