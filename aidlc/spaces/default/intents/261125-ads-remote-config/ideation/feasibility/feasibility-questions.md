# Câu hỏi khả thi và ràng buộc: Quảng cáo và Remote Config

Bối cảnh từ mã nguồn hiện tại: dự án Flutter đã có `firebase_core`, `firebase_remote_config` (hiện chỉ đọc tham số `level_config`) và `firebase_analytics`, chưa có thư viện quảng cáo nào. Ứng dụng Android có `applicationId` là `com.h2.game.block_blast`, và iOS có mục tiêu triển khai tối thiểu 13.0.

## Q1. Dự án Firebase dùng cho các tham số quảng cáo

Remote Config hiện đã chạy trong dự án Firebase của game cho tham số level. Câu hỏi này xác nhận các tham số quảng cáo mới (`ads_priority`, cờ bật/tắt reward, các số N, thông tin phiên bản) nằm ở đâu.

Các tham số mới sẽ nằm ở đâu?

- A. Cùng dự án Firebase và cùng Remote Config đang dùng cho level
- B. Một dự án Firebase khác
- C. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:A

## Q2. Cách chạy mediation giữa ba mạng quảng cáo

Mô tả của bạn cần `ads_priority` (ví dụ `admob,unity,applovin`) quyết định thứ tự mediation. Có hai hướng kỹ thuật khác nhau về độ phức tạp, nên câu hỏi này ghi nhận mong muốn của bạn nếu đã có.

Bạn nghiêng về hướng nào?

- A. Ứng dụng tự chạy thứ tự gọi từng mạng theo `ads_priority` (nếu mạng đầu không có quảng cáo thì thử mạng kế)
- B. Dùng mediation có sẵn của một mạng chính, `ads_priority` chỉ chọn mạng nào đứng đầu
- C. Not yet defined (chưa xác định, nhờ đánh giá ở bước thiết kế)
- X. Other (please specify)

[Answer]:A

## Q3. Thời gian và ngân sách

Câu hỏi này xác định mức gấp để bước lập kế hoạch cân đối phạm vi cho phù hợp.

Có mốc thời gian hoặc giới hạn ngân sách nào không?

- A. Không có mốc thời gian cố định (None), không có ngân sách riêng
- B. Cần xong trong vài ngày
- C. Cần xong trong 1 đến 2 tuần
- D. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:A

## Q4. Khu vực phát hành

Bạn đã xác nhận cần xử lý sự đồng ý của người dùng (GDPR/ATT hoặc tương đương). Khu vực phát hành quyết định có cần hộp thoại đồng ý cho người dùng EU/EEA hay không.

Ứng dụng được phát hành ở những khu vực nào?

- A. Toàn cầu, gồm cả EU/EEA
- B. Chỉ các khu vực ngoài EU/EEA
- C. Chỉ một vài quốc gia cụ thể (nêu rõ ở Other)
- D. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:A

## Q5. Độ tuổi người chơi và chính sách cửa hàng

Nếu game nhắm tới trẻ em, cả Google Play và App Store đều có quy định riêng về quảng cáo, và nhiều mạng quảng cáo có chế độ riêng cho nội dung dành cho trẻ em.

Đối tượng người chơi của game là ai?

- A. Đối tượng chung, không nhắm riêng tới trẻ em
- B. Có thể bao gồm trẻ em dưới 13 tuổi
- C. Not yet defined (chưa xác định, cần tìm hiểu)
- X. Other (please specify)

[Answer]:X hướng tới trên 13 tuổi

## Q6. Thiết bị để thử quảng cáo

Quảng cáo thật và quảng cáo thử cần chạy trên thiết bị hoặc giả lập, và việc build iOS cần máy Mac. Câu hỏi này xác định bạn kiểm tra được trên nền tảng nào.

Bạn có thể kiểm tra trên nền tảng nào?

- A. Cả Android và iOS
- B. Chỉ Android
- C. Chỉ iOS
- D. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:A

## Q7. Đường dẫn cửa hàng cho popup cập nhật và nội dung chia sẻ

Hạng mục (5) và (6) dùng `android_url` và `ios_url`. Câu hỏi này xác nhận các đường dẫn đó đã tồn tại chưa.

Ứng dụng đã có trang trên cửa hàng chưa?

- A. Đã có trang trên cả Google Play và App Store
- B. Chỉ có trên Google Play
- C. Chỉ có trên App Store
- D. Chưa phát hành trên cửa hàng nào
- E. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:X  chưa phát hành trên nền tảng nào, hiện tại có thể chỉ để 1 link giả, sau khi lên store config link thật sau

## Q8. Rào cản tổ chức

Câu hỏi này ghi nhận mọi thứ có thể chặn hoặc làm chậm công việc, như thời gian chờ duyệt tài khoản quảng cáo hay đóng băng phát hành.

Có rào cản nào đã biết không?

- A. Không có (None)
- B. Có, nằm ở phía mạng quảng cáo (duyệt tài khoản, duyệt ad unit)
- C. Có, nằm ở phía cửa hàng ứng dụng (duyệt bản phát hành)
- D. Có, khác (nêu rõ ở Other)
- E. Not identified (chưa xác định)
- X. Other (please specify)

[Answer]:C

## Consolidated Summary Confirmation

Does this all look correct before I generate the artifact?

- Looks correct
- Request changes

[Answer]: Looks correct
