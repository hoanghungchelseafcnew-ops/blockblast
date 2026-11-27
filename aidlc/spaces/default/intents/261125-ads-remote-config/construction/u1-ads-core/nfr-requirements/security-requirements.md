# Yêu cầu bảo mật và quyền riêng tư: u1-ads-core

Nguồn: `functional-spec.md`, `rules.md`, `requirements.md`, `contract-summary.md` và `nfr-requirements-questions.md`. Unit này là thư viện nền tảng quảng cáo, không có đăng nhập hay phân quyền người dùng, nên trọng tâm là khóa, định danh và đồng ý của người dùng.

## Yêu cầu chi tiết

| ID | Yêu cầu | Tiêu chí pass | Nguồn |
|----|---------|---------------|-------|
| NFR2.1 | Mọi lỗi từ SDK quảng cáo, đồng ý hoặc cấu hình được bắt và trả về như kết quả, không làm ứng dụng dừng | Giả lập lỗi ở từng SDK thì game vẫn chạy | NFR2, BR2.4 |
| NFR2.2 | Mỗi mạng có thời hạn chờ 5 giây | Giả lập mạng treo thì sau 5 giây chuyển sang mạng kế | NFR2, BR2.5 |
| NFR2.3 | Không lưu khóa bí mật phía máy chủ trong mã nguồn hay Remote Config. ID ứng dụng, ID đơn vị quảng cáo và SDK key của AppLovin (định danh gắn với ứng dụng, đi kèm bản phát hành) nằm trong cấu hình Android và iOS cùng tệp hằng số | Quét mã nguồn và `RemoteConfigClient` không thấy khóa bí mật | Q4 của nfr-requirements |
| NFR2.4 | ID thử dùng trong bản debug, ID thật chỉ trong bản phát hành, và người phát triển không bấm vào quảng cáo thật của mình | Bản debug dùng ID thử | BR5.2 |
| NFR2.5 | Không có quảng cáo nào được yêu cầu trước khi đồng ý của người dùng được xử lý | Kiểm thử trạng thái đồng ý ở từng nhánh | FR8.1, BR3.1 |
| NFR2.6 | Người dùng từ chối đồng ý thì chỉ nhận quảng cáo không cá nhân hóa | Kiểm thử với trạng thái từ chối | FR8.2, BR3.2 |
| NFR2.7 | Bộ đếm lưu bền chỉ chứa số đếm và một cờ, không chứa dữ liệu cá nhân | Xem lại `AdCounterState` | `entities.md` |

## Chỉ tiêu liên quan từ yêu cầu chung

| ID | Yêu cầu | Tiêu chí pass | Nguồn |
|----|---------|---------------|-------|
| NFR1.1 | Khởi tạo quảng cáo và đồng ý chạy nền và không chặn màn Splash. Hạn chót khởi động 3,5 giây vẫn đúng | Giả lập quảng cáo treo mà Splash vẫn sang Home trong 3,5 giây | NFR1, BR1.4 |
| NFR3.1 | Mã SDK quảng cáo nằm sau interface có bản giả, độ phủ dòng tối thiểu 80% toàn codebase, `test/widget_test.dart` pass trước khi đo | Bạn chạy `flutter test --coverage` và báo kết quả | NFR3, `team-practices.md` |
| NFR6.1 | Cấu hình quảng cáo mới có hiệu lực trong tối đa khoảng 12 giờ, theo `minimumFetchInterval` hiện có, giữ nguyên | `minimumFetchInterval` vẫn là 12 giờ | NFR6 |
| NFR7.1 | Kiểm thử hiện có vẫn xanh sau khi mở rộng `RemoteConfigClient` và cập nhật bản giả | Bạn chạy `flutter test` và báo kết quả | NFR7, ADR-004 |

## Mối đe dọa đã cân nhắc

- Người chơi tắt mạng để nhận thưởng reward ads miễn phí: ghi nhận và chấp nhận theo quyết định ADR-007. Không thuộc unit này.
- Lộ khóa ký ứng dụng: `android/.gitignore` đã bỏ qua `key.properties` và `*.jks`. Không đổi.
- Hai tệp Firebase đang được theo dõi trong git (`google-services.json`, `GoogleService-Info.plist`) chứa khóa API phía client, chấp nhận được nhưng nên hạn chế theo ứng dụng trong Firebase và Google Cloud. (`evidence.md` của practices-discovery)

## Nhắc cho lúc phát hành

Khi thêm quảng cáo, khai báo dữ liệu trên Google Play (Data safety) và trên App Store (App Privacy) cho các SDK quảng cáo, và khai báo đối tượng từ 13 tuổi trở lên. Đây là việc của bạn trên các cửa hàng, không phải việc của mã nguồn. (`feasibility-assessment.md`)

## Assumptions & Open Questions

None.
