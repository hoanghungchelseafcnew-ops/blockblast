# Scope Definition Questions — Gemstone Journey

Bối cảnh:
- File requirements (DocumentKB `01a1cee8-…`) có FR-01 đến FR-08: Classic mode, điểm theo level, Remote Config, Analytics, ảnh nền, màn hình Victory, giao diện chọn level, lưu tiến trình. Ngoài ra có NFR-01 đến NFR-06: tái sử dụng code và asset, đổi package, hạn chế dependency, hiệu năng, hỗ trợ offline.
- File requirements **không** nhắc đến quảng cáo hay in-app purchase. Tuy vậy, ở Market Research Q3 và Feasibility Q1 bạn đã chọn quảng cáo + IAP.

---

## Q1. Quảng cáo và in-app purchase có nằm trong scope của đợt này không?

A. Không. Đợt này chỉ làm đúng file requirements (FR-01 đến FR-08), quảng cáo/IAP để intent sau
B. Có. Làm cả quảng cáo và IAP trong đợt này
C. Chỉ thêm quảng cáo, IAP để sau
D. Chưa xác định
X. Other (please specify)

[Answer]:A

---

## Q2. Ảnh nền lấy từ Firebase Storage (theo FR-05) hay chỉ dùng ảnh trong assets?

A. Làm đầy đủ FR-05: ưu tiên Firebase Storage (URL trong Remote Config), dự phòng bằng ảnh trong assets
B. Chỉ dùng ảnh trong assets, không dùng Firebase Storage
C. Đợt này dùng assets, Firebase Storage để sau
D. Chưa xác định
X. Other (please specify)

[Answer]:A

---

## Q3. Hiệu ứng viên đá quý 3D xoay (FR-06, ghi "nếu có thể") thì xử lý thế nào?

A. Nice-to-have: thay bằng animation 2D xoay/sáng lấp lánh, 3D để sau
B. Must-have: phải có 3D
C. Bỏ hẳn
D. Chưa xác định
X. Other (please specify)

[Answer]:A

---

## Q4. Đổi package (NFR-03) có làm cho cả iOS không?

A. Có. Android dùng `com.h2.game.block_blast`, iOS dùng `com.h2.game.blockBlast` (iOS không cho phép `_`)
B. Có. iOS dùng ID khác (vui lòng ghi rõ)
C. Chỉ đổi cho Android như trong file requirements
D. Chưa xác định
X. Other (please specify)

[Answer]:A

---

## Q5. Mục "Sync dữ liệu khi có kết nối trở lại" trong NFR-06 nghĩa là gì?

A. Chỉ là gửi lại analytics và fetch lại Remote Config khi có mạng (tiến trình vẫn lưu cục bộ, đúng với Feasibility Q2)
B. Đồng bộ tiến trình lên cloud
C. Bỏ yêu cầu này
D. Chưa xác định
X. Other (please specify)

[Answer]:A

---

## Q6. Thứ tự ưu tiên khi triển khai là gì?

A. Value-first: hệ thống level, tiến trình, chọn level → Victory → Firebase → đổi package
B. Dependency-first: đổi package, Firebase setup → level system → UI → Victory
C. Risk-first: Firebase và Remote Config trước (rủi ro tích hợp), sau đó đến level và UI
D. Chưa xác định
X. Other (please specify)

[Answer]:B

---

## Q7. Với ảnh nền (đã có sẵn) và âm thanh mới (`victory`, `unlock`), có thể bắt đầu bằng placeholder không?

A. Có. Dùng ảnh và âm thanh có sẵn hoặc placeholder trước, thay thế sau (theo NFR-02)
B. Không. Phải dùng asset hoàn chỉnh ngay từ đầu
C. Not applicable
X. Other (please specify)

[Answer]:A

---

## Hướng dẫn trả lời

1. **Guide Me** · 2. **Edit File** · 3. **Chat**

Ví dụ: `[Answer]: A` hoặc `[Answer]: X. mô tả của bạn`

---

## Consolidated Summary Confirmation

Does this all look correct before I generate the artifact?

- Q1: Đợt này chỉ làm đúng file requirements (FR-01 đến FR-08). Quảng cáo/IAP để intent sau
- Q2: Làm đầy đủ FR-05: ảnh từ Firebase Storage, dự phòng bằng assets
- Q3: Đá quý 3D là nice-to-have, thay bằng animation 2D
- Q4: Đổi package cả hai nền tảng: Android `com.h2.game.block_blast`, iOS `com.h2.game.blockBlast`
- Q5: "Sync" = gửi lại analytics và fetch lại Remote Config. Tiến trình vẫn lưu cục bộ
- Q6: Dependency-first: đổi package, Firebase setup → level system → UI → Victory
- Q7: Được dùng placeholder cho asset, thay thế sau

- Looks correct
- Request changes

[Answer]: Looks correct
