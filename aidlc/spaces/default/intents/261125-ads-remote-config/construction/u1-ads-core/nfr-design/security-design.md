# Thiết kế bảo mật và quyền riêng tư: u1-ads-core

Nguồn: `security-requirements.md`, `tech-stack-decisions.md`, `functional-spec.md` và `contract-summary.md`. Các quyết định đã chốt ở các bước trước nên bước này không có câu hỏi mới, chỉ gom lại thành thiết kế. Tài liệu không chứa mã triển khai.

## Thiết kế theo yêu cầu

| ID | Thiết kế | Nơi áp dụng |
|----|----------|-------------|
| NFR1.1 | Khởi tạo quảng cáo và đồng ý chạy bất đồng bộ sau khi màn Splash đã chuyển, không đưa vào chuỗi bước có hạn chót 3,5 giây. `AppBootstrap` chỉ nạp cấu hình và đếm lần mở, rồi khởi chạy hai việc nền | `AppBootstrap`, `AdMediator`, `ConsentService` |
| NFR2.1 | Mỗi lời gọi SDK nằm trong một lớp bọc bắt mọi lỗi và biến thành kết quả (không có quảng cáo, lỗi, đóng sớm). Không có ngoại lệ nào thoát ra khỏi `AdNetworkAdapters` | `AdNetworkAdapters` |
| NFR2.2 | Mỗi lần tải một mạng có đồng hồ đếm 5 giây. Hết hạn thì bỏ kết quả muộn của mạng đó và thử mạng kế | `AdMediator` |
| NFR2.3 | Mọi ID và SDK key nằm trong một tệp hằng số riêng cho từng nền tảng và từng mạng. Không có khóa bí mật phía máy chủ. `RemoteConfigClient` không đọc khóa nào ngoài bộ tham số của hợp đồng 1 | tệp hằng số, `RemoteConfigClient` |
| NFR2.4 | Một cờ build (debug hoặc phát hành) chọn bộ ID thử hoặc ID thật tại một chỗ duy nhất | tệp hằng số |
| NFR2.5 | `AdMediator` hỏi `ConsentService` trước khi xin bất kỳ quảng cáo nào. Khi trạng thái là chưa xử lý hoặc cần hỏi thì trả "không có quảng cáo" | `AdMediator`, `ConsentService` |
| NFR2.6 | Trạng thái từ chối được truyền xuống mỗi adapter như một yêu cầu quảng cáo không cá nhân hóa | `AdNetworkAdapters` |
| NFR2.7 | `AdCounters` chỉ lưu hai số và một cờ qua kho lưu có interface. Không lưu mã định danh quảng cáo hay dữ liệu cá nhân | `AdCounters` |
| NFR3.1 | Mỗi SDK nằm sau một interface (`AdNetworkAdapter`, kho lưu của `AdCounters`, nguồn cấu hình của `AdsConfig`, cổng đồng ý của `ConsentService`) có bản giả trong `test/fakes/`. Logic điều phối (`AdMediator`, `AdCounters`, `AdsConfig`) có kiểm thử đơn vị không cần SDK thật | các khối trên |
| NFR6.1 | Không đổi `minimumFetchInterval` 12 giờ và `fetchTimeout` 2 giây của `FirebaseRemoteConfigClient` | `FirebaseRemoteConfigClient` |
| NFR7.1 | Mở rộng `RemoteConfigClient` bằng các hàm đọc theo kiểu và giữ nguyên `readLevelConfig`. Cập nhật `FakeRemoteConfigClient` để kiểm thử cũ vẫn chạy | `RemoteConfigClient`, `test/fakes/fake_remote_config_client.dart` |

## Luồng dữ liệu nhạy cảm

Không có dữ liệu cá nhân nào do ứng dụng tự lưu. Các SDK quảng cáo và SDK đồng ý tự xử lý các định danh của riêng chúng, và việc khai báo dữ liệu này trên Google Play (Data safety) và App Store (App Privacy) là việc của bạn lúc phát hành. (`security-requirements.md`)

## Assumptions & Open Questions

None.
