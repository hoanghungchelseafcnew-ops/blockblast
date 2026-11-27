# Yêu cầu bảo mật và độ đúng dữ liệu: u2-reward-ads

Nguồn: `functional-spec.md`, `rules.md`, `requirements.md` (NFR2, NFR3, NFR7), `security-requirements.md` của `u1-ads-core` và `nfr-requirements-questions.md`. Unit này không thêm khóa, định danh hay dữ liệu cá nhân mới; rủi ro chính là độ đúng của tiến trình người chơi.

| ID | Yêu cầu | Tiêu chí pass | Nguồn |
|----|---------|---------------|-------|
| NFR2.12 | Thua được ghi nhận đúng một lần cho mỗi ván thua, kể cả khi người chơi bấm nhiều nút hoặc ứng dụng bị tắt rồi mở lại | Kiểm thử: bấm PLAY AGAIN rồi BACK TO MENU chỉ hạ tiến trình một lần; dấu lần thua chưa ghi nhận được xử lý đúng một lần khi mở lại | BR6.8, BR6.7 |
| NFR2.13 | Nhận thưởng không bao giờ hạ tiến trình hay bỏ viên đá đang có | Kiểm thử: sau khi nhận thưởng, tiến trình đã lưu vẫn là level đang chơi | BR6.3, FR3.5 |
| NFR2.14 | Lỗi khi lưu hoặc xóa dấu lần thua chưa ghi nhận được ghi log và không làm hỏng ván chơi | Kiểm thử với kho lưu giả ghi lỗi | NFR2 |
| NFR3.2 | Luồng reward kiểm thử được bằng bản giả của `AdsService`, không cần SDK thật | Có kiểm thử đơn vị và widget dùng bản giả | NFR3 |
| NFR7.2 | Các kiểm thử hiện có của `LevelGameController` và `ProgressRepository` được cập nhật theo thời điểm ghi nhận thua mới và vẫn xanh | Bạn chạy `flutter test` và báo kết quả | NFR7, ADR-003 |

## Mối đe dọa đã cân nhắc

- Chơi lại không giới hạn khi tắt mạng: chấp nhận theo ADR-007 và Q2 của functional-design.
- Tắt ứng dụng khi đang ở lớp phủ Game Over để tránh bị hạ tiến trình: được chặn bằng dấu lần thua chưa ghi nhận (BR6.7).

## Assumptions & Open Questions

None.
