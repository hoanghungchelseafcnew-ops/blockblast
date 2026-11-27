# Thiết kế hiệu năng: u3-banner

Nguồn: `performance-requirements.md`, `tech-stack-decisions.md`, `functional-spec.md`, `contract-summary.md` (hợp đồng 2, `BannerResult`) và `nfr-design-questions.md`. Không chứa mã triển khai.

| ID | Thiết kế |
|----|----------|
| NFR2.15 | Vùng banner là một phần tử riêng dưới cùng cột màn chơi, cao 0 cho đến khi có banner. Yêu cầu banner chạy ở nền sau khung hình đầu; bàn cờ và khay khối không chờ nó |
| NFR2.16 | `AdMediator.banner(width)` thử AdMob rồi AppLovin theo thứ tự trong `ads_priority`, bỏ qua Unity, dùng lại đồng hồ 5 giây mỗi mạng. Vùng banner giữ một yêu cầu đang chạy; yêu cầu thứ hai trong lúc đó bị bỏ qua |
| NFR2.17 | Banner đã tải là một đối tượng sống suốt lần vào màn chơi. Đổi ván chỉ dựng lại phần bàn cờ, không tạo yêu cầu banner mới. Làm mới do SDK tự làm theo cài đặt của mạng |
| NFR2.18 | Chiều cao banner thích ứng được tính theo chiều rộng màn hình trước khi tải, và vùng banner nhận đúng chiều cao đó khi banner hiện, nên bố cục chỉ đổi một lần |
| BR7.2 | Theo Q1, `AdsService` thông báo mỗi khi một lần mở được ghi xong. Vùng banner đăng ký nhận thông báo này khi màn chơi mở và hủy khi màn chơi đóng. Khi nhận, nếu chưa thử tải trong lần vào này và điều kiện BR7.1 đã thỏa thì yêu cầu banner. Vì thông báo chỉ đến sau khi bộ đếm đã ghi xong, không có trường hợp hỏi trước khi đếm |

## Assumptions & Open Questions

None.
