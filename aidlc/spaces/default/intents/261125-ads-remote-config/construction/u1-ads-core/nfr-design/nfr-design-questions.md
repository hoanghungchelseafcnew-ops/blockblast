# Câu hỏi thiết kế phi chức năng: u1-ads-core

Hầu hết quyết định đã có (thời hạn 5 giây cho mỗi mạng, bắt mọi lỗi SDK, không chờ khi interstitial chưa sẵn sàng, khởi tạo chạy nền). Hai điều còn lại là cách thử lại khi tải trước thất bại và cách ghi lại sự kiện quảng cáo. Bản thiết kế hiện có nằm ở `security-design.md`, `logical-components.md` và `traceability.json` cùng thư mục.

## Q1. Thử lại khi tải trước quảng cáo thất bại

Khi tải trước interstitial thất bại hoặc hết 5 giây ở mọi mạng, `InterstitialSlot` vẫn chưa sẵn sàng. Cần quy tắc khi nào thử tải lại, để không bỏ lỡ nhiều lượt hiện nhưng cũng không gọi mạng liên tục.

Thử lại như thế nào?

- A. Thử lại khi người chơi bấm Start lần kế tiếp (không chờ), tối đa một lần tải tại một thời điểm, và không thử lại theo đồng hồ
- B. Thử lại theo đồng hồ: sau 30 giây, rồi 60 giây, rồi 120 giây, sau đó dừng cho đến lần bấm Start kế tiếp
- C. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:A

## Q2. Ghi lại sự kiện quảng cáo

Cần biết quảng cáo có chạy đúng không (hiện, không có quảng cáo, lỗi, hết thời hạn) mà không làm ứng dụng chậm hoặc ghi dữ liệu cá nhân.

Ghi ở đâu?

- A. Chỉ ghi một dòng vào nhật ký của ứng dụng (`GjLog`) cho mỗi sự kiện, không gửi lên Firebase Analytics
- B. Ghi vào nhật ký và gửi một số sự kiện đã chọn lên Firebase Analytics (ví dụ quảng cáo đã hiện, không có quảng cáo, lỗi)
- C. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:A

## Consolidated Summary Confirmation

- Thử lại khi tải trước thất bại: thử lại khi người chơi bấm Start lần kế tiếp, tối đa một lần tải tại một thời điểm, không thử lại theo đồng hồ (Q1)
- Ghi sự kiện quảng cáo: chỉ một dòng vào nhật ký của ứng dụng, không gửi lên Firebase Analytics (Q2)
- Hai điều trên đã được thêm vào `logical-components.md`, các tài liệu còn lại giữ nguyên

Does this all look correct before I generate the artifact?

- Looks correct
- Request changes

[Answer]: Looks correct
