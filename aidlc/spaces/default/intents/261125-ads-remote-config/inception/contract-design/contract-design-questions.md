# Câu hỏi thiết kế hợp đồng: Quảng cáo và Remote Config

Một hợp đồng là thỏa thuận giữa hai bên về dữ liệu đi qua ranh giới, cách đi và điều gì xảy ra khi lỗi. Ở đây có hai loại ranh giới:

- **Giữa các unit**: `u1-ads-core` cung cấp cho `u2-reward-ads`, `u3-banner` và `u4-update-and-share` (`unit-of-work-dependency.md`). Đây là các interface trong cùng ứng dụng.
- **Ra ngoài ứng dụng**: các tham số trên Firebase Remote Config. Bạn đặt giá trị trên Firebase, và mọi bản ứng dụng đã phát hành đều đọc cùng bộ tham số này, kể cả bản cũ.

## Q1. Chính sách thay đổi các tham số trên Firebase

Khi bạn phát hành bản mới có thể muốn đổi tham số, trong khi người dùng bản cũ vẫn đọc cùng giá trị trên Firebase.

Chính sách nào áp dụng?

- A. Chỉ thêm khóa mới. Không đổi ý nghĩa hay kiểu của khóa đã phát hành. Bản cũ bỏ qua khóa lạ và vẫn hoạt động.
- B. Khi cần đổi ý nghĩa, tạo khóa mới có hậu tố phiên bản (ví dụ `ads_priority_v2`) và giữ khóa cũ cho bản cũ.
- C. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:A

## Q2. Thời hạn chờ khi gọi từng mạng quảng cáo

Khi thử từng mạng theo `ads_priority`, một mạng có thể chậm hoặc treo. Cần một thời hạn để chuyển sang mạng kế mà không làm người chơi chờ lâu.

Thời hạn chờ cho mỗi mạng là bao nhiêu?

- A. 3 giây cho mỗi mạng, hết hạn thì coi như không có quảng cáo và thử mạng kế
- B. 5 giây cho mỗi mạng
- C. Not yet defined (chưa xác định, để bước thiết kế hạ tầng quyết định)
- X. Other (please specify)

[Answer]:B

## Q3. Bên sở hữu các hợp đồng

Cần một bên có quyền sửa mỗi hợp đồng và đồng ý thay đổi với bên dùng nó.

Ai sở hữu?

- A. `u1-ads-core` sở hữu mọi hợp đồng (interface của `AdMediator`, `AdsConfig`, `AppUpdateChecker` và bộ tham số Firebase), và ba unit còn lại chỉ là bên dùng
- B. Mỗi unit sở hữu hợp đồng của phần nó cung cấp
- C. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:A

## Q4. Khi tham số Firebase thiếu hoặc sai kiểu

Bạn đã chốt: giá trị sai kiểu hoặc không hợp lệ được coi như thiếu và dùng mặc định. Câu hỏi này xác định cách ghi lại để bạn biết có lỗi.

Xử lý thế nào?

- A. Dùng mặc định và ghi một dòng cảnh báo vào nhật ký của ứng dụng (như `GjLog`), không báo gì cho người chơi
- B. Dùng mặc định và gửi một sự kiện phân tích để bạn thấy trên Firebase
- C. Dùng mặc định và không ghi gì
- D. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:A

## Consolidated Summary Confirmation

- Chính sách tham số Firebase: chỉ thêm khóa mới, không đổi ý nghĩa hay kiểu của khóa đã phát hành, bản cũ bỏ qua khóa lạ (Q1)
- Thời hạn chờ: 5 giây cho mỗi mạng quảng cáo, hết hạn thì coi như không có quảng cáo và thử mạng kế (Q2)
- Sở hữu: `u1-ads-core` sở hữu mọi hợp đồng, ba unit còn lại là bên dùng (Q3)
- Tham số thiếu hoặc sai: dùng mặc định và ghi một dòng cảnh báo vào nhật ký của ứng dụng, không báo cho người chơi (Q4)

Does this all look correct before I generate the artifact?

- Looks correct
- Request changes

[Answer]: Looks correct
