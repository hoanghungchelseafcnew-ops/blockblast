# Functional Design Questions — U1 `u1-journey-skeleton`

Bối cảnh:
- U1 là walking skeleton: mở app → config → Home → PLAY → thắng → level kế tiếp → lưu tiến trình.
- Phần lớn quy tắc đã chốt ở requirements, domain design (ADR-008/009/010) và contract (C1–C5, E1, E3).
- Tôi đã kiểm tra: hai file Firebase đã nằm đúng chỗ, và package/bundle ID khớp (`com.h2.game.block_blast` / `com.h2.game.blockBlast`).

Câu hỏi bên dưới chỉ hỏi những hành vi **riêng của U1** còn mở.

---

## Q1. Nếu khởi tạo Firebase thất bại (thiếu file cấu hình, lỗi mạng lúc init) thì sao?

A. App vẫn chạy bình thường ở chế độ offline: dùng config mặc định, log lỗi, `config_source = default`. Không hiện lỗi cho người chơi
B. Hiện màn lỗi và không cho chơi
X. Other (please specify)

[Answer]:A

---

## Q2. Ở U1 (trước khi U2 làm Game Over mới), màn Game Over xử lý thế nào?

A. Giữ overlay hiện có. PLAY AGAIN chơi lại **cùng level**, chưa reset về Rough Stone. Tạm giữ REVIVE và SHARE, U2 sẽ thay
B. Bỏ REVIVE ngay ở U1 (đúng FR11.3 sớm hơn), phần còn lại giữ nguyên
X. Other (please specify)

[Answer]:A

---

## Q3. Màn Victory tạm thời ở U1 trình bày thế nào?

A. Overlay đơn giản trên màn chơi: "Level Complete!", "<score> / <target>", nút CONTINUE. Không có hiệu ứng (U3 làm)
B. Một màn riêng (route mới) tối giản, để U3 chỉ cần thay nội dung
X. Other (please specify)

[Answer]:A

---

## Q4. Tutorial lần đầu ("DRAG BLOCKS TO THE BOARD!") ở U1?

A. Giữ nguyên hành vi: hiện ở lần chơi đầu, tắt sau lần đặt khối đầu tiên. Chuyển việc lưu `tutorial_completed` sang `ProgressRepository`
B. Giữ nguyên, vẫn đọc/ghi SharedPreferences trực tiếp như cũ
X. Other (please specify)

[Answer]:A

---

Trả lời trong chat được, ví dụ: "1A 2A 3A 4A"

---

## Consolidated Summary Confirmation

Does this all look correct before I generate the artifact?

- Q1: Firebase init lỗi thì app vẫn chạy offline với config mặc định, log lỗi, `config_source = default`, không hiện lỗi
- Q2: Giữ overlay Game Over hiện có. PLAY AGAIN chơi lại cùng level. Tạm giữ REVIVE và SHARE (U2 thay)
- Q3: Victory tạm là overlay đơn giản: "Level Complete!", "<score> / <target>", CONTINUE, không có hiệu ứng
- Q4: Giữ tutorial lần đầu. Lưu `tutorial_completed` qua `ProgressRepository`

- Looks correct
- Request changes

[Answer]: Looks correct
