# NFR Design Questions — U1 `u1-journey-skeleton`

Hầu hết giải pháp đã được chốt ở NFR Requirements và Functional Design:
- Timeout cho Firebase init và fetch.
- Hàng đợi ghi FIFO, dirty retry, chế độ chỉ-đọc.
- Validate cấu hình và URL.
- Log qua `GjLog`.

Còn 2 lựa chọn thiết kế cần bạn quyết định.

---

## Q1. Cấu hình mặc định (JSON 36 mốc điểm trong file requirements) đặt ở đâu trong app?

A. Hằng số Dart (`const` trong `lib/core/firebase/default_level_config.dart`). Không cần đọc file nên luôn sẵn sàng ngay và dễ unit test
B. File asset `assets/config/level_config_default.json`, đọc lúc khởi động. Dễ sửa nhưng cần thêm bước đọc bất đồng bộ và một nguồn lỗi nữa
X. Other (please specify)

[Answer]:A

---

## Q2. Khi ProgressRepository ở chế độ chỉ-đọc (đọc prefs lỗi 2 lần), log cảnh báo thế nào? (góp ý R-11)

A. Một dòng `warn` khi vào chế độ chỉ-đọc, và **một dòng duy nhất** cho các lần ghi bị bỏ qua (dòng đầu tiên). Các lần ghi sau thì im lặng
B. Mỗi lần ghi bị bỏ qua đều log một dòng
X. Other (please specify)

[Answer]:A

---

Trả lời trong chat được, ví dụ: "1A 2A"

---

## Consolidated Summary Confirmation

Does this all look correct before I generate the artifact?

- Q1: Cấu hình mặc định là hằng số Dart trong `lib/core/firebase/default_level_config.dart`
- Q2: Chế độ chỉ-đọc log 1 dòng `warn` khi bắt đầu và 1 dòng cho lần ghi bị bỏ qua đầu tiên. Các lần ghi sau thì im lặng

- Looks correct
- Request changes

[Answer]: Looks correct
