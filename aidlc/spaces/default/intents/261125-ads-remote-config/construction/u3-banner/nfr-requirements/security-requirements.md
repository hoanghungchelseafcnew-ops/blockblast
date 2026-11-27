# Yêu cầu bảo mật và độ tin cậy: u3-banner

Nguồn: `functional-spec.md`, `rules.md`, `requirements.md` (NFR2, NFR3), `security-requirements.md` của `u1-ads-core` và `nfr-requirements-questions.md`. Unit này không thêm khóa bí mật hay dữ liệu cá nhân. ID banner là định danh công khai, nằm cùng chỗ với ID của u1 và u2.

| ID | Yêu cầu | Tiêu chí pass | Nguồn |
|----|---------|---------------|-------|
| NFR2.19 | Không yêu cầu banner trước khi đồng ý được xử lý; dùng quảng cáo không cá nhân hóa khi người chơi từ chối | Kiểm thử đơn vị: đồng ý chưa xử lý thì không mạng nào được gọi tải banner | BR3.1, BR3.2, BR7.1 |
| NFR2.20 | Lỗi SDK khi tải hoặc hiện banner được ghi log và chỉ dẫn đến vùng banner ẩn, không dừng game | Kiểm thử đơn vị với mạng giả ném lỗi | NFR2, BR7.9 |
| NFR2.21 | Banner được giải phóng khi rời màn chơi, không giữ tài nguyên của SDK sau khi màn đóng | Kiểm thử widget: đóng màn chơi thì banner được giải phóng | BR7.7 |
| NFR2.22 | Bản debug chỉ dùng ID banner thử, không tạo lượt hiện hay bấm thật | Xem lại `ad_unit_ids.dart` | NFR2.4 của `u1-ads-core` |
| NFR3.3 | Logic banner kiểm thử được bằng bản giả của `AdsService` và `AdNetworkAdapter`, không cần SDK thật | Có kiểm thử đơn vị và widget dùng bản giả | NFR3 |

## Mối đe dọa đã cân nhắc

- Banner che nút của game làm người chơi bấm nhầm vào quảng cáo: được chặn bằng bố cục cột, banner nằm dưới khay khối và không đè lên (BR7.4).
- Mạng quảng cáo nhận dữ liệu cá nhân khi người chơi từ chối: được chặn bằng NFR2.19.

## Assumptions & Open Questions

None.
