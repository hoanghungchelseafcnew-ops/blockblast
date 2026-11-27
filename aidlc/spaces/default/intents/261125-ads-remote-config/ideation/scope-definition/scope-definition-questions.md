# Câu hỏi xác định phạm vi: Quảng cáo và Remote Config

Sáu hạng mục trong ý định ban đầu được đánh số như sau, và các câu hỏi dưới đây dùng đúng các số này:

- Hạng mục 1: banner ở màn chơi, chỉ hiện từ lần vào thứ N
- Hạng mục 2: nút xem reward ads để tiếp tục ở level hiện tại, có cờ bật/tắt
- Hạng mục 3: interstitial ads sau mỗi N lần bấm Start
- Hạng mục 4: `ads_priority` quyết định thứ tự mediation cho banner, reward và interstitial
- Hạng mục 5: kiểm tra phiên bản và hiện popup cập nhật bằng `android_version`, `android_url`, `ios_version`, `ios_url`
- Hạng mục 6: dùng `android_url` và `ios_url` trong nội dung chia sẻ

## Q1. Hạng mục bắt buộc có trong bản đầu tiên (select all that apply)

Câu hỏi này xác định phạm vi tối thiểu mang lại giá trị. Hạng mục không chọn ở đây vẫn có thể nằm trong phạm vi nhưng được làm sau.

Hạng mục nào là Must Have, tức không có thì bản phát hành không đạt mục tiêu?

- A. Hạng mục 1 (banner)
- B. Hạng mục 2 (reward ads)
- C. Hạng mục 3 (interstitial)
- D. Hạng mục 4 (`ads_priority`)
- E. Hạng mục 5 và 6 (kiểm tra phiên bản, popup cập nhật và link trong nội dung chia sẻ)
- X. Other (please specify)

[Answer]:X - tất cả hạn mục đều là must have

## Q2. Hạng mục có thể hoãn (select all that apply)

Câu hỏi này xác định hạng mục nào có thể bị đẩy sang đợt sau nếu công việc bị chậm, để kế hoạch có chỗ co giãn.

Hạng mục nào là Should Have hoặc Could Have, tức hoãn được mà bản phát hành vẫn dùng được?

- A. Hạng mục 1 (banner)
- B. Hạng mục 2 (reward ads)
- C. Hạng mục 3 (interstitial)
- D. Hạng mục 4 (`ads_priority`)
- E. Hạng mục 5 và 6 (phiên bản và link chia sẻ)
- F. None (không có hạng mục nào hoãn được)
- X. Other (please specify)

[Answer]:F

## Q3. Thứ tự làm ưu tiên

Câu hỏi này quyết định bước lập kế hoạch sau xếp thứ tự công việc theo tiêu chí nào.

Bạn muốn ưu tiên theo hướng nào?

- A. Giá trị trước: làm hạng mục mang lại doanh thu hoặc lợi ích lớn nhất trước
- B. Rủi ro trước: làm hạng mục rủi ro hoặc chưa chắc chắn nhất trước (ví dụ xử lý đồng ý người dùng, tích hợp ba mạng)
- C. Phụ thuộc trước: làm phần nền mà các hạng mục khác cần trước
- D. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:A

## Q4. Phần dùng chung giữa các hạng mục

Hạng mục 1, 2 và 3 đều hiển thị quảng cáo, và hạng mục 4 quyết định thứ tự mạng cho cả ba. Cả bốn đều đọc tham số từ Remote Config. Câu hỏi này xác nhận cách tách công việc.

Bạn muốn tách công việc như thế nào?

- A. Làm phần nền dùng chung trước (đọc cấu hình, thứ tự mạng, tải quảng cáo), sau đó thêm từng loại quảng cáo
- B. Làm từng hạng mục độc lập, trùng lặp phần nền nếu cần
- C. Not yet defined (chưa xác định, để bước thiết kế quyết định)
- X. Other (please specify)

[Answer]:A

## Q5. Xử lý đồng ý người dùng có nằm trong phạm vi không

Ở bước đầu bạn đã xác nhận cần xử lý sự đồng ý (GDPR/ATT hoặc tương đương), và phát hành toàn cầu gồm EU/EEA. Việc này không nằm trong sáu hạng mục nhưng ảnh hưởng đến việc hiển thị quảng cáo.

Xử lý đồng ý người dùng thuộc phạm vi của đợt này không?

- A. Có, là một phần bắt buộc của việc hiển thị quảng cáo trong đợt này
- B. Không, để một đợt sau
- C. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:A

## Q6. Những việc nằm ngoài phạm vi (select all that apply)

Câu hỏi này ghi rõ ranh giới để tránh mở rộng ngoài ý muốn. Mọi việc bạn không chọn thì không bị coi là loại trừ, mà chỉ là chưa xác nhận.

Việc nào dưới đây chắc chắn nằm ngoài phạm vi đợt này?

- A. Gói trả tiền để tắt quảng cáo
- B. Các loại quảng cáo khác sáu hạng mục (native, app open)
- C. Màn hình hoặc báo cáo doanh thu riêng trong ứng dụng
- D. Hỗ trợ đa ngôn ngữ cho chuỗi giao diện
- E. None (không loại trừ thêm việc nào)
- X. Other (please specify)

[Answer]:A

## Q7. Mốc thời hạn gắn với từng hạng mục

Ở bước khả thi bạn xác nhận không có mốc thời gian cố định. Câu hỏi này kiểm tra lại xem có mốc nào gắn riêng cho một hạng mục không.

Có hạng mục nào gắn với thời hạn cứng không?

- A. Không có (None)
- B. Có, hạng mục 5 và 6 cần xong trước ngày phát hành lên cửa hàng
- C. Có, hạng mục khác (nêu rõ ở Other)
- D. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:A

## Consolidated Summary Confirmation

Does this all look correct before I generate the artifact?

- Looks correct
- Request changes

[Answer]: Looks correct
