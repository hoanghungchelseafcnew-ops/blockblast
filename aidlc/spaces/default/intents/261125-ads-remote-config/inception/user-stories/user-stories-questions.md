# Kế hoạch user stories: Quảng cáo và Remote Config

Các yêu cầu `FR1` đến `FR8` và `NFR1` đến `NFR7` trong `requirements.md` là đầu vào. Mức ưu tiên của cả sáu hạng mục đã chốt là Must Have. Các câu hỏi dưới đây chỉ hỏi cách viết stories.

## Q1. Các nhân vật (personas)

Người dùng trực tiếp của tính năng là người chơi. Nhà phát triển cũng dùng Remote Config để điều chỉnh quảng cáo, và nhiều yêu cầu (FR1, FR5) chỉ có ý nghĩa với người này.

Cần những nhân vật nào?

- A. Hai nhân vật: người chơi (từ 13 tuổi trở lên) và nhà phát triển vận hành cấu hình trên Firebase
- B. Chỉ người chơi, các yêu cầu cấu hình viết thành điều kiện trong stories của người chơi
- C. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:B

## Q2. Cách chia stories

Câu hỏi này xác định các stories được nhóm theo trục nào.

Chia theo cách nào?

- A. Theo tính năng, khớp với các mục trong backlog: nền tảng cấu hình và đồng ý, interstitial, reward ads, banner, popup cập nhật, link chia sẻ
- B. Theo nhân vật
- C. Theo luồng người chơi (mở app, vào màn chơi, thua, chia sẻ)
- D. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:A

## Q3. Độ nhỏ của mỗi story

Stories nhỏ dễ kiểm thử hơn nhưng nhiều hơn. Luồng reward ads có nhiều trạng thái (điều kiện hiện nút, xem đủ, đóng sớm, quảng cáo chưa sẵn sàng).

Chọn độ nhỏ nào?

- A. Một story cho mỗi hành vi người dùng thấy được (ví dụ nút reward hiện, nhận thưởng, đóng sớm là ba stories riêng), mỗi story có 3 đến 5 tiêu chí chấp nhận
- B. Một story cho mỗi tính năng, với nhiều tiêu chí chấp nhận hơn
- C. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:B

## Consolidated Summary Confirmation

- Nhân vật: chỉ người chơi, các yêu cầu cấu hình viết thành điều kiện trong stories của người chơi (Q1)
- Cách chia: theo tính năng, khớp backlog (Q2)
- Độ nhỏ: một story cho mỗi tính năng, với nhiều tiêu chí chấp nhận hơn (Q3)

Does this all look correct before I generate the artifact?

- Looks correct
- Request changes

[Answer]: Looks correct
