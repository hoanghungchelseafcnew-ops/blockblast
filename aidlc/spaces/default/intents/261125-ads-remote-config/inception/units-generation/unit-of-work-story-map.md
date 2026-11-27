# Bản đồ stories và unit

Nguồn: `stories.md`, `unit-of-work.md` và `units-generation-questions.md`.

## Bảng ánh xạ

| Story | Unit ID | Directory | Ghi chú |
|-------|---------|-----------|---------|
| US1.1 | U1 | `u1-ads-core` | Cấu hình từ Firebase và mặc định |
| US1.2 | U1 | `u1-ads-core` | Thứ tự mạng quảng cáo |
| US1.3 | U1 | `u1-ads-core` | Đồng ý của người dùng |
| US2.1 | U1 | `u1-ads-core` | Interstitial, làm cùng U1 để có bản mỏng chạy xuyên suốt |
| US3.1 | U2 | `u2-reward-ads` | Reward ads |
| US4.1 | U3 | `u3-banner` | Banner |
| US5.1 | U4 | `u4-update-and-share` | Popup cập nhật |
| US6.1 | U4 | `u4-update-and-share` | Link trong nội dung chia sẻ |

## Stories trải rộng nhiều unit

Không có story nào thuộc nhiều unit. Hai yêu cầu phi chức năng trải rộng: NFR1 (khởi động không bị chặn) và NFR2 (lỗi quảng cáo không dừng game) áp dụng cho U1, U2 và U3. (`requirements.md`)

## Thứ tự stories trong mỗi unit

- U1: US1.1, rồi US1.2, rồi US1.3, rồi US2.1 (mỗi story sau dùng kết quả của story trước).
- U4: US5.1 và US6.1 độc lập với nhau.

## Kiểm tra độ phủ

- Mọi story (8 trên 8) đều được gán cho một unit.
- Mỗi unit có ít nhất một story: U1 có 4, U2 có 1, U3 có 1, U4 có 2.

## Assumptions & Open Questions

None.
