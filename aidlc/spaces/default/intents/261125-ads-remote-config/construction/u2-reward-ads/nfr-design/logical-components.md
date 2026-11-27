# Thành phần logic: u2-reward-ads

Nguồn: `components.md`, `security-design.md`, `performance-design.md`, `tech-stack-decisions.md` của unit này (không thêm thư viện mới) và `logical-components.md` của `u1-ads-core`.

| Thành phần | Thay đổi | Miền lỗi | Cách cô lập |
|-----------|----------|----------|-------------|
| `AdMediator` | Thêm ô reward và thao tác `reward()` | SDK quảng cáo | Không ném lỗi, trả `earned`, `closed_early` hoặc `no_ad` |
| `AdNetworkAdapters` | Thêm tải và hiện reward | Mỗi SDK | Bắt mọi lỗi, thời hạn 5 giây |
| `LevelGameController` | Hoãn ghi nhận thua, luồng thưởng | Tiến trình người chơi | Một hàm ghi nhận thua duy nhất, cờ chặn chạy lặp, khóa `pending_loss_level` |
| `AppBootstrap` | Ghi nhận lần thua còn treo khi mở lại | Khởi động | Bắt lỗi, không chặn hạn chót 3,5 giây |
| `GameOverOverlay` | Nút reward và dòng nhỏ | Giao diện | Chỉ vẽ theo thuộc tính |

Không có thay đổi hạ tầng.

## Assumptions & Open Questions

None.
