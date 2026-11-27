# Thành phần logic: u3-banner

Nguồn: `components.md`, `security-design.md`, `performance-design.md`, `tech-stack-decisions.md` của unit này (không thêm thư viện mới), `functional-spec.md` và `logical-components.md` của `u1-ads-core`.

| Thành phần | Thay đổi | Miền lỗi | Cách cô lập |
|-----------|----------|----------|-------------|
| `AdMediator` | Thêm `banner(width)` trả `BannerResult`, và thông báo mỗi lần mở được ghi | SDK quảng cáo | Không ném lỗi, trả `shown` hoặc `hidden` |
| `AdNetworkAdapters` | AdMob và AppLovin thêm tải banner; Unity trả "không có" | Mỗi SDK | Bắt mọi lỗi, thời hạn 5 giây |
| `AdUnitIds` | Thêm ID banner | Cấu hình | ID thử ở bản debug |
| `AdBannerSlot` (mới) | Vùng banner dùng chung cho `GameScreen` và `EndlessGameScreen` | Giao diện | Cao 0 khi không có banner, giải phóng khi đóng |
| `GameScreen`, `EndlessGameScreen` | Thêm `AdBannerSlot` dưới cùng cột | Giao diện | Lớp phủ vẫn phủ toàn màn hình |

Không có thay đổi hạ tầng.

## Assumptions & Open Questions

None.
