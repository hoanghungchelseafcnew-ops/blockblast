# Câu hỏi yêu cầu phi chức năng: u2-reward-ads

Không cần thư viện mới: reward dùng lại ba SDK đã thêm ở `u1-ads-core`. Bạn đã chọn tải trước quảng cáo reward, và khi bấm nút mà không có quảng cáo thì thưởng ngay (ADR-007). Hai câu dưới đây chốt các chỉ tiêu còn lại.

## Q1. Thời điểm tải trước quảng cáo reward

Tải trước sớm thì quảng cáo sẵn sàng hơn khi người chơi thua, nhưng tốn dữ liệu và bộ nhớ dù người chơi có thể không bao giờ thua.

- A. Tải trước khi bắt đầu mỗi level ở Journey (sau khi đồng ý đã xử lý), và tải lại ngay sau mỗi lần hiện
- B. Chỉ tải khi lớp phủ Game Over hiện
- C. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:A

## Q2. Thời gian chờ tối đa sau khi bấm nút

Nếu quảng cáo đã tải xong thì hiện ngay. Nếu đang tải dở lúc bấm nút, có thể chờ một chút hoặc thưởng ngay.

- A. Không chờ: chưa sẵn sàng là thưởng ngay
- B. Chờ tối đa 2 giây, rồi thưởng ngay nếu vẫn chưa có
- C. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:A
