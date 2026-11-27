# Yêu cầu hiệu năng: u3-banner

Nguồn: `functional-spec.md`, `requirements.md` (FR2, NFR2), `contract-summary.md` (hợp đồng 2, `BannerResult`) và `nfr-requirements-questions.md`.

| ID | Yêu cầu | Tiêu chí pass | Nguồn |
|----|---------|---------------|-------|
| NFR2.15 | Vào màn chơi không chờ banner: bàn cờ và khay khối dùng được ngay, banner tải ở nền | Kiểm thử widget: với banner đang tải treo, người chơi vẫn đặt được khối | NFR2, BR7.4 |
| NFR2.16 | Mỗi mạng có thời hạn 5 giây khi tải banner, tối đa một lần tải banner tại một thời điểm cho mỗi lần vào màn chơi | Kiểm thử đơn vị với mạng treo và với hai yêu cầu liền nhau | BR2.5, BR7.3 |
| NFR2.17 | Banner đang hiện được làm mới theo cài đặt trong bảng điều khiển của từng mạng; ứng dụng không tự tải lại banner khi banner đang hiện | Kiểm thử đơn vị: chuyển ván không gọi tải lại; xem lại cài đặt làm mới trong bảng điều khiển AdMob và AppLovin trước khi phát hành | Q1, BR7.7 |
| NFR2.18 | Khi banner hiện, bố cục chỉ đổi một lần và bàn cờ, khay khối không bị che trên màn hình cao 640 dp | Kiểm thử widget trên kích thước màn hình ngắn | AC4.1.6, BR7.4 |

## Assumptions & Open Questions

None.
