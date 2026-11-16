# Feasibility Questions — Gemstone Journey

Bối cảnh:
- Codebase hiện tại là một app Flutter (`pubspec.yaml`: package `block_blast`, SDK ^3.9.2). App lưu dữ liệu cục bộ bằng `shared_preferences`, quản lý state bằng `provider`, có âm thanh qua `audioplayers` và chưa tích hợp Firebase.
- Market Research đã chọn Firebase Remote Config, Firebase Analytics, quảng cáo và in-app purchase, với quy mô mục tiêu trên 100.000 người chơi.

---

## Q1. Game cần tích hợp với những hệ thống bên ngoài nào?

A. Chỉ Firebase (Remote Config, Analytics)
B. Firebase + SDK quảng cáo (ví dụ AdMob) + in-app purchase của store
C. Như B, cộng thêm đăng nhập hoặc lưu tiến trình trên cloud (đồng bộ giữa các thiết bị)
D. Chưa xác định
X. Other (please specify)

[Answer]:B

---

## Q2. Tiến trình level của người chơi (level đã mở khóa, điểm cao) được lưu ở đâu?

A. Chỉ lưu cục bộ trên thiết bị (`shared_preferences`), mất khi gỡ app
B. Lưu cục bộ, sau này có thể thêm đồng bộ cloud
C. Lưu trên cloud ngay từ đầu
D. Chưa xác định
X. Other (please specify)

[Answer]:A

---

## Q3. Game sẽ phát hành ở thị trường nào?

A. Chỉ Việt Nam
B. Toàn cầu, bao gồm EU (áp dụng GDPR, cần consent)
C. Toàn cầu, trừ EU
D. Chưa xác định
X. Other (please specify)

[Answer]:C

---

## Q4. Đối tượng người chơi có bao gồm trẻ em (dưới 13 tuổi) không?

A. Không. Game nhắm đến người từ 13 tuổi trở lên
B. Có. Game nhắm cả đến trẻ em (áp dụng COPPA và chính sách Families của Google Play)
C. Không nhắm đến trẻ em, nhưng không chặn trẻ em chơi
D. Chưa xác định
X. Other (please specify)

[Answer]:A

---

## Q5. Kỹ năng hiện tại của developer với Flutter và Firebase như thế nào?

A. Thành thạo Flutter, đã từng dùng Firebase
B. Thành thạo Flutter, chưa dùng Firebase
C. Đang học Flutter
D. Not applicable
X. Other (please specify)

[Answer]:A

---

## Q6. Ràng buộc về ngân sách và thời gian là gì?

A. Không có ngân sách (chỉ dùng gói miễn phí), không có deadline cứng
B. Không có ngân sách, có deadline cụ thể (vui lòng ghi rõ)
C. Có ngân sách nhỏ cho asset/dịch vụ, không có deadline cứng
D. Có ngân sách và có deadline (vui lòng ghi rõ)
X. Other (please specify)

[Answer]:A

---

## Q7. Ảnh nền cho 36 level lấy từ đâu?

A. Đã có sẵn ảnh
B. Tự thiết kế hoặc tạo bằng AI
C. Mua asset có bản quyền
D. Chưa xác định
X. Other (please specify)

[Answer]:A 

---

## Q8. Có cần đổi package/application ID của app không?

A. Có, đổi sang một ID mới (vui lòng ghi rõ ID)
B. Không, giữ nguyên ID hiện tại
C. Chưa xác định
X. Other (please specify)

[Answer]:A đổi package tất cả các nền tảng là com.h2.game.block_blast 

---

## Q9. Có trở ngại nào khác không (công việc khác cạnh tranh thời gian, thiết bị test iOS)?

A. Không có trở ngại
B. Không có thiết bị hoặc Mac để build và test iOS
C. Thời gian làm dự án bị hạn chế (làm bán thời gian)
D. Cả B và C
X. Other (please specify)

[Answer]:A

---

## Q10. Dự án có dùng AWS hoặc hạ tầng cloud nào ngoài Firebase không?

A. Không. Chỉ dùng Firebase
B. Có dùng AWS (vui lòng ghi rõ dịch vụ)
C. Có dùng cloud khác (vui lòng ghi rõ)
D. Not applicable
X. Other (please specify)

[Answer]:A

---

## Hướng dẫn trả lời

1. **Guide Me**: tôi hỏi lần lượt từng câu
2. **Edit File**: điền trực tiếp vào các tag `[Answer]:`
3. **Chat**: trả lời tự do qua chat

Ví dụ: `[Answer]: A` hoặc `[Answer]: X. mô tả của bạn`

---

## Consolidated Summary Confirmation

Does this all look correct before I generate the artifact?

- Q1: Tích hợp Firebase (Remote Config, Analytics), SDK quảng cáo và in-app purchase của store
- Q2: Tiến trình chỉ lưu cục bộ trên thiết bị (`shared_preferences`)
- Q3: Phát hành toàn cầu, trừ EU
- Q4: Không nhắm đến trẻ em (13+)
- Q5: Thành thạo Flutter, đã từng dùng Firebase
- Q6: Không có ngân sách (chỉ dùng gói miễn phí), không có deadline cứng
- Q7: Ảnh nền cho 36 level đã có sẵn
- Q8: Đổi package trên tất cả nền tảng sang `com.h2.game.block_blast`
- Q9: Không có trở ngại
- Q10: Không dùng AWS, chỉ dùng Firebase

- Looks correct
- Request changes

[Answer]:Looks correct
