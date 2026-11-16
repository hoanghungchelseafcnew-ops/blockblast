# Personas — Gemstone Journey

## Sources

- `inception/requirements-analysis/requirements.md`
- `ideation/intent-capture/intent-statement.md`, `stakeholder-map.md`
- `user-stories-questions.md` (Q2)

## P1 — Casual Player (ưu tiên 1)

- **Vai trò:** người chơi game casual trên điện thoại Android hoặc iOS, độ tuổi 13+, chơi màn hình dọc, chỉ dùng tiếng Anh.
- **Mục tiêu:**
  - Có mục tiêu rõ ràng ở mỗi lượt chơi.
  - Cảm thấy mình tiến bộ khi mở khóa đá quý.
  - Chơi được cả khi không có mạng.
- **Pain points:** game endless hiện tại không có đích đến nên dễ chán. Mất tiến trình hoặc gặp màn hình khó hiểu cũng làm họ bỏ game.
- **Bối cảnh:** phiên chơi ngắn trong lúc rảnh, có thể thoát giữa chừng bất cứ lúc nào, thường dùng máy tầm trung.

## P2 — Developer/Owner (ưu tiên 2)

- **Vai trò:** stakeholder duy nhất của dự án. Người này phát triển, cấu hình Remote Config và Firebase project, build và phát hành thủ công.
- **Mục tiêu:**
  - Chỉnh độ khó (mốc điểm) và ảnh nền mà không cần phát hành bản mới.
  - Đo session time, retention và tỉ lệ hoàn thành level.
  - Phát hành dưới package `com.h2.game.*`.
- **Pain points:** không có CI hay git, và tự build trên máy khác. Vì vậy cấu hình và fallback phải chạy ổn ngay cả khi Firebase lỗi.

## Quan hệ

P2 tạo ra trải nghiệm cho P1. Mọi story của P2 đều phục vụ mục tiêu retention của P1.
