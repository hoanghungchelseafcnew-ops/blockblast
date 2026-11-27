# Câu hỏi yêu cầu phi chức năng và chọn thư viện: u1-ads-core

Unit này là kiểu `library` nên chỉ cần tài liệu bảo mật, chọn thư viện (tech stack) và truy vết. Các chỉ tiêu hiệu năng và độ tin cậy chính đã ghi trong `requirements.md` (NFR1 đến NFR7) và `contract-summary.md` (thời hạn chờ 5 giây cho mỗi mạng). Dự án hiện chưa có thư viện quảng cáo nào (`technology-stack.md`), nên câu hỏi chủ yếu là chọn thư viện.

Lưu ý theo thực hành của đội: AI chỉ sửa `pubspec.yaml`, còn bạn là người chạy `flutter pub get`, `flutter analyze` và `flutter test`.

## Q1. Thư viện cho ba mạng quảng cáo

Bạn đã chọn để ứng dụng tự chạy thứ tự gọi từng mạng theo `ads_priority` (không dựa vào lớp mediation của một mạng).

- A. Mỗi mạng dùng thư viện chính thức riêng: `google_mobile_ads` cho AdMob, `unity_ads_plugin` cho Unity Ads, `applovin_max` cho AppLovin MAX, và ứng dụng tự điều phối giữa ba thư viện
  - Ưu: đúng với quyết định đã chốt. Nhược: ba SDK cùng lúc làm tăng kích thước ứng dụng và rủi ro xung đột phiên bản.
- B. Chỉ dùng `google_mobile_ads` và gắn adapter mediation của Unity và AppLovin vào AdMob
  - Ưu: một SDK chính. Nhược: trái với quyết định đã chốt (thứ tự do `ads_priority` điều khiển trong ứng dụng).
- C. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:A

## Q2. Thư viện cho sự đồng ý của người dùng

Cần hộp thoại đồng ý cho người dùng EU/EEA và xin phép theo dõi trên iOS.

- A. Dùng phần đồng ý (UMP) đi kèm `google_mobile_ads` cho EU/EEA, và thư viện `app_tracking_transparency` cho iOS
  - Ưu: UMP là công cụ chuẩn của Google, ít thư viện thêm. Nhược: thêm một thư viện cho iOS.
- B. Dùng một nền tảng quản lý đồng ý (CMP) của bên thứ ba
  - Ưu: có nhiều tùy chỉnh. Nhược: thêm chi phí và phụ thuộc, vượt phạm vi đội một người.
- C. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:A

## Q3. Thư viện đọc phiên bản đang cài

Cần cho unit sau (`u4-update-and-share`) nhưng nên chọn cùng lúc để `pubspec.yaml` thống nhất.

- A. `package_info_plus`
- B. Chọn lúc làm `u4-update-and-share`
- C. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:A

## Q4. Khóa và định danh của các mạng quảng cáo

Bạn đã cho biết các mạng bạn dùng không có khóa bí mật. Riêng AppLovin MAX yêu cầu một SDK key đặt trong cấu hình Android và iOS (đây là định danh gắn với ứng dụng và đi kèm trong bản phát hành, không phải khóa bí mật phía máy chủ).

Xử lý thế nào?

- A. Chấp nhận: ID ứng dụng, ID đơn vị quảng cáo và SDK key của AppLovin nằm trong cấu hình Android và iOS cùng tệp hằng số, và không bao giờ lưu khóa bí mật phía máy chủ trong mã nguồn hay Remote Config
- B. Khác (nêu rõ ở Other)
- X. Other (please specify)

[Answer]:A

## Q5. Chỉ tiêu phi chức năng bổ sung

Đã có sẵn: khởi động không bị chặn quá 3,5 giây (NFR1), lỗi quảng cáo không dừng game (NFR2), không chờ khi interstitial chưa sẵn sàng (quy tắc BR4.4), thời hạn 5 giây cho mỗi mạng (BR2.5).

- A. Không thêm chỉ tiêu nào
- B. Thêm chỉ tiêu (nêu rõ ở Other, ví dụ mức tăng kích thước ứng dụng cho phép)
- C. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:A

## Consolidated Summary Confirmation

- Thư viện quảng cáo: mỗi mạng dùng thư viện chính thức riêng, gồm `google_mobile_ads`, `unity_ads_plugin` và `applovin_max`, ứng dụng tự điều phối (Q1)
- Đồng ý của người dùng: dùng UMP đi kèm `google_mobile_ads` cho EU/EEA, và `app_tracking_transparency` cho iOS (Q2)
- Đọc phiên bản đang cài: `package_info_plus` (Q3)
- Khóa và định danh: ID ứng dụng, ID đơn vị quảng cáo và SDK key của AppLovin nằm trong cấu hình Android và iOS cùng tệp hằng số, không lưu khóa bí mật phía máy chủ trong mã nguồn hay Remote Config (Q4)
- Chỉ tiêu bổ sung: không thêm chỉ tiêu nào ngoài những chỉ tiêu đã có (Q5)

Does this all look correct before I generate the artifact?

- Looks correct
- Request changes

[Answer]: Looks correct
