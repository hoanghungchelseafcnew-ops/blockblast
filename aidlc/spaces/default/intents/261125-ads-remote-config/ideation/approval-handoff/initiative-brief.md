# Bản tóm tắt sáng kiến: Quảng cáo và Remote Config

Bản tóm tắt này gom kết quả của giai đoạn ý tưởng. Nguồn chi tiết nằm ở các tài liệu được nhắc tên dưới đây và ở `approval-handoff-questions.md`.

## Ý định và vấn đề

Game cần tạo doanh thu từ quảng cáo và cần điều chỉnh quảng cáo từ xa qua Firebase mà không phải phát hành lại ứng dụng. Người chơi cuối trên Android và iOS là đối tượng chịu tác động. (`intent-statement.md`)

Chỉ số thành công: doanh thu quảng cáo trên mỗi người dùng hoạt động hàng ngày, tỷ lệ xem reward ads, tỷ lệ cập nhật phiên bản, và retention không giảm. Chưa có mức mục tiêu cụ thể cho các chỉ số này. (`intent-statement.md`)

## Bên liên quan

Developer duy nhất là người quyết định phạm vi và ưu tiên, không có người góp ý khác và không có yêu cầu báo cáo định kỳ. Người chơi cuối trên Android và iOS là bên chịu tác động. (`stakeholder-map.md`)

## Xác nhận thị trường

Market Research đã được bỏ qua vì không có định vị thị trường bên ngoài và ba mạng quảng cáo đã được chọn sẵn kèm tài khoản. (`intent-statement.md`)

## Khả thi và rủi ro

Khả thi với một developer, không có mốc thời gian cố định. Rủi ro chính là xử lý đồng ý người dùng ở EU/EEA và iOS, khai báo nhóm đối tượng trên 13 tuổi, thời gian duyệt trên cửa hàng, và khối lượng tích hợp ba mạng. Bạn đã xem và chấp nhận các rủi ro này. (`feasibility-assessment.md`, `raid-log.md`, Q2)

## Phạm vi

Sáu hạng mục đều bắt buộc, cộng phần xử lý đồng ý người dùng như một phần bắt buộc của việc hiển thị quảng cáo. Gói trả tiền để tắt quảng cáo nằm ngoài phạm vi. Phần nền dùng chung làm trước, sau đó thêm từng loại quảng cáo. (`scope-document.md`, `intent-backlog.md`)

## Hình ảnh khái niệm

- Banner nằm dưới cùng màn chơi. (`wireframes.md`)
- Nút xem reward ads nằm trong lớp phủ khi thua. Sau khi xem xong, các ô trên bàn cờ được xóa sạch và người chơi chơi tiếp ở chính level đó, giữ tiến độ level. Cách này thay thế cách ghi "bắt đầu lại level từ đầu" trong `wireframes.md` và `user-flow.md`. (Q4)
- Popup cập nhật tùy chọn, có nút Update và Later, hiện khi vào màn Home. (`wireframes.md`)
- Quảng cáo interstitial hiện ngay sau khi bấm Start, trước khi vào màn chơi. (Q5)

## Kế hoạch đội

Team Formation đã được bỏ qua. Nguồn lực là thời gian của developer duy nhất, không có ngân sách riêng. (Q3)

## Khuyến nghị

Go: chuyển sang giai đoạn đặc tả (Inception). (Q6)

## Assumptions & Open Questions

None.
