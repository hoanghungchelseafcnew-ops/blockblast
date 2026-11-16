# Infrastructure Design Questions — U1 `u1-journey-skeleton`

U1 không có server. Hạ tầng chỉ gồm Firebase project (gói Spark) mà bạn đã tạo, cùng cấu hình build Android/iOS. Còn 2 điểm cần bạn xác nhận.

---

## Q1. Dùng bao nhiêu Firebase project?

A. **Một** project cho cả debug lẫn release (đơn giản, phù hợp với gói miễn phí). Thận trọng khi publish Remote Config, vì thay đổi sẽ ảnh hưởng ngay tới người chơi thật
B. Hai project (dev và prod) tách theo build flavor. Thêm cấu hình Gradle/Xcode và một bộ file cấu hình nữa
X. Other (please specify)

[Answer]:A

---

## Q2. Có giới hạn API key Firebase trên Google Cloud console không? (khuyến nghị bảo mật)

A. Có. Giới hạn key Android theo package `com.h2.game.block_blast` cùng SHA-1, key iOS theo bundle `com.h2.game.blockBlast`. Bạn tự làm trước khi phát hành, không chặn U1
B. Không cần lúc này
X. Other (please specify)

[Answer]:B

---

Trả lời trong chat được, ví dụ: "1A 2A"

---

## Consolidated Summary Confirmation

Does this all look correct before I generate the artifact?

- Q1: Một Firebase project cho cả debug và release. Thận trọng khi publish Remote Config
- Q2: Chưa giới hạn API key Firebase trên console lúc này (rủi ro chấp nhận, có thể làm trước khi phát hành)

- Looks correct
- Request changes

[Answer]: Looks correct
