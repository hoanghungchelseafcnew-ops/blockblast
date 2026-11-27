# Thiết kế hiệu năng: u2-reward-ads

Nguồn: `performance-requirements.md`, `functional-spec.md`, `contract-summary.md` và `nfr-design-questions.md`. Không chứa mã triển khai.

| ID | Thiết kế |
|----|----------|
| NFR2.8 | Lớp phủ Game Over hiện ngay khi hết nước đi. Việc ghi dấu lần thua chưa ghi nhận bắt đầu cùng lúc; các nút trên lớp phủ chỉ bấm được sau khi ghi xong (Q1). Lần ghi là một giá trị nhỏ vào SharedPreferences nên thời gian chờ thường dưới một khung hình |
| NFR2.9 | `AdMediator` có thêm một ô reward đã tải trước, riêng với ô interstitial. `LevelGameController.start` gọi tải trước reward khi chế độ là Journey; tải lại sau mỗi lần hiện. Một lần tải tại một thời điểm |
| NFR2.10 | `reward()` kiểm tra ô reward: sẵn sàng thì hiện, chưa sẵn sàng hoặc đang tải thì trả `no_ad` ngay |
| NFR2.11 | Dùng lại đồng hồ 5 giây cho mỗi mạng của `AdMediator` |

## Assumptions & Open Questions

None.
