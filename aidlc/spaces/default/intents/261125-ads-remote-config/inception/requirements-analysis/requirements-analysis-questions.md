# Câu hỏi phân tích yêu cầu: Quảng cáo và Remote Config

Sáu hạng mục, phần xử lý đồng ý người dùng và các quyết định đã chốt ở giai đoạn trước là đầu vào của các câu hỏi này. Các câu hỏi dưới đây chỉ hỏi những chi tiết còn thiếu để viết yêu cầu kiểm chứng được. Mọi chuỗi hiển thị trên giao diện chỉ dùng tiếng Anh.

Các hạng mục được đánh số như sau:

- Hạng mục 1: banner ở màn chơi, chỉ hiện từ lần vào thứ N
- Hạng mục 2: nút xem reward ads để tiếp tục level hiện tại, có cờ bật/tắt
- Hạng mục 3: interstitial sau mỗi N lần bấm Start
- Hạng mục 4: `ads_priority` quyết định thứ tự mạng cho banner, reward và interstitial
- Hạng mục 5: kiểm tra phiên bản và popup cập nhật
- Hạng mục 6: link cửa hàng trong nội dung chia sẻ

## Q1. Thế nào là "một lần vào" màn chơi cho banner (hạng mục 1)

Banner chỉ hiện từ lần vào thứ N (mặc định N là 3). Cần định nghĩa lần vào là gì để đếm đúng.

Một lần vào được tính khi nào?

- A. Mỗi lần màn chơi của một level được mở, kể cả khi chơi lại
- B. Mỗi lần mở ứng dụng rồi vào màn chơi lần đầu trong phiên
- C. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:X mỗi lần mở ứng dụng

## Q2. Tên các tham số trên Firebase và giá trị mặc định

Các tham số cần có trên Remote Config. Tên dưới đây là đề xuất để thống nhất ngay từ đầu, và giá trị mặc định dùng khi không tải được cấu hình.

| Tham số | Ý nghĩa | Mặc định đề xuất |
|---------|---------|------------------|
| `banner_start_visit` | Banner chỉ hiện từ lần vào thứ N | 3 |
| `reward_enabled` | Bật hoặc tắt nút reward ads | true |
| `interstitial_every_n_starts` | Interstitial sau mỗi N lần bấm Start | 3 |
| `ads_priority` | Thứ tự mạng, ví dụ `admob,unity,applovin` | `admob,unity,applovin` |
| `android_version`, `android_url`, `ios_version`, `ios_url` | Phiên bản mới nhất và link cửa hàng | rỗng |

Bạn chấp nhận tên và giá trị mặc định này không?

- A. Chấp nhận như bảng trên
- B. Đổi tên hoặc giá trị mặc định (nêu rõ ở Other)
- C. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:A

## Q3. Giới hạn số lần xem reward ads (hạng mục 2)

Nút reward ads hiện khi thua. Câu hỏi này xác định có giới hạn số lần dùng hay không.

Giới hạn như thế nào?

- A. Một lần cho mỗi ván thua, không giới hạn số ván
- B. Một lần cho mỗi level, kể cả khi thua nhiều ván ở level đó
- C. Không giới hạn
- D. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:A

## Q4. Trạng thái ván chơi sau khi xem xong reward ads (hạng mục 2)

Bạn đã chốt: các ô trên bàn cờ được xóa sạch và người chơi chơi tiếp ở level đó. Câu hỏi này làm rõ ba chi tiết còn lại: điểm, khay khối, và việc game hiện đang ghi nhận thua và hạ tiến trình ngay khi hết nước đi.

Sau khi xem xong quảng cáo thì sao?

- A. Giữ nguyên điểm đã có, giữ nguyên khay khối hiện tại, và không ghi nhận thua nên tiến trình không bị hạ
- B. Giữ nguyên điểm đã có, đổi sang khay khối mới, và không ghi nhận thua nên tiến trình không bị hạ
- C. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:X - Điểm hiện tại về 0 để chơi lại tại level đó , khay khối mới chỉ level k bị hạ thôi

## Q5. Khi người chơi đóng quảng cáo sớm hoặc quảng cáo không sẵn sàng (hạng mục 2)

Reward ads chỉ nên thưởng khi người chơi xem đủ. Câu hỏi này xác định phản ứng khi không đủ điều kiện.

Xử lý thế nào?

- A. Đóng sớm thì không thưởng và quay lại lớp phủ Game Over; quảng cáo chưa sẵn sàng thì ẩn nút reward
- B. Đóng sớm thì vẫn thưởng; quảng cáo chưa sẵn sàng thì ẩn nút reward
- C. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:A

## Q6. Phạm vi quảng cáo ở chế độ Endless

Game có chế độ Endless dùng cùng lớp phủ Game Over. Phạm vi đã chốt không nói riêng về Endless.

Quảng cáo áp dụng thế nào ở chế độ Endless?

- A. Không có quảng cáo nào ở Endless, chỉ áp dụng cho chế độ Journey
- B. Có đủ banner, reward và interstitial như Journey
- C. Chỉ banner và interstitial, không có reward ads
- D. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:C

## Q7. Những hành động được đếm là "lần bấm Start" (hạng mục 3)

Interstitial hiện sau mỗi N lần bấm Start và hiện ngay sau khi bấm, trước khi vào màn chơi.

Những hành động nào được tính là một lần bấm Start?

- A. Chỉ nút PLAY ở màn Home
- B. Nút PLAY ở Home và nút PLAY AGAIN ở lớp phủ Game Over
- C. Mọi lần bắt đầu một level, kể cả sau khi thắng và sang level kế
- D. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:B

## Q8. Lưu bộ đếm và khoảng cách tối thiểu giữa hai interstitial (hạng mục 1 và 3)

Câu hỏi này xác định bộ đếm lần vào và lần bấm Start có được lưu khi thoát ứng dụng không, và có cần khoảng cách thời gian tối thiểu không.

Bạn chọn thế nào?

- A. Lưu bền (giữ khi thoát ứng dụng), không có khoảng cách thời gian tối thiểu
- B. Chỉ đếm trong một phiên chạy, không có khoảng cách thời gian tối thiểu
- C. Lưu bền, và có khoảng cách thời gian tối thiểu giữa hai interstitial (nêu số giây ở Other)
- D. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:A

## Q9. Thứ tự mạng và cách xử lý khi cấu hình sai hoặc thiếu (hạng mục 4)

`ads_priority` là chuỗi tên mạng cách nhau bằng dấu phẩy. Ứng dụng tự chạy thứ tự gọi từng mạng. Câu hỏi này xác định hành vi khi giá trị thiếu, sai tên mạng, hoặc mạng đứng đầu không có quảng cáo.

Xử lý thế nào?

- A. Thiếu hoặc rỗng thì dùng thứ tự mặc định `admob,unity,applovin`; tên mạng lạ thì bỏ qua; mạng đứng đầu không có quảng cáo thì thử lần lượt các mạng còn lại trong danh sách
- B. Thiếu hoặc rỗng thì không hiện quảng cáo; mạng đứng đầu không có quảng cáo thì thử lần lượt các mạng còn lại
- C. Thiếu hoặc rỗng thì dùng thứ tự mặc định; chỉ thử mạng đứng đầu, không thử mạng khác
- D. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:A

## Q10. So sánh phiên bản và tần suất hiện popup (hạng mục 5)

Bản cài đặt hiện là `1.0.0+1`. Popup hiện khi bản cài đặt thấp hơn `android_version` hoặc `ios_version` tương ứng, và là tùy chọn có hai nút Update và Later, hiện khi vào Home.

Quy tắc so sánh và tần suất như thế nào?

- A. So phiên bản (ví dụ 1.0.0, không so số build); popup hiện mỗi lần vào Home sau khi mở ứng dụng, tối đa một lần cho mỗi lần mở ứng dụng
- B. So phiên bản và số build; popup hiện mỗi lần vào Home
- C. So phiên bản; popup hiện tối đa một lần mỗi ngày
- D. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:A

## Q11. Khi link cửa hàng rỗng hoặc không hợp lệ (hạng mục 5 và 6)

Ứng dụng chưa phát hành, và bạn dự định dùng link giả tạm thời rồi đổi qua cấu hình sau. Câu hỏi này xác định hành vi khi link rỗng hoặc không phải địa chỉ web hợp lệ.

Xử lý thế nào?

- A. Popup cập nhật không hiện; nội dung chia sẻ giữ nguyên, không thêm link
- B. Popup vẫn hiện nhưng ẩn nút Update; nội dung chia sẻ giữ nguyên, không thêm link
- C. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:A

## Q12. Cách đưa link vào nội dung chia sẻ (hạng mục 6)

Nội dung chia sẻ hiện là "I scored $score in Block Jewel!" và "I cleared $levelName with $score points in Block Jewel!".

Link được thêm như thế nào?

- A. Thêm link ở cuối văn bản hiện có, ví dụ "I scored 120 in Block Jewel! <link>", chọn link theo hệ điều hành (Android dùng `android_url`, iOS dùng `ios_url`)
- B. Thay câu chữ chia sẻ khác (nêu rõ ở Other)
- C. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:A

## Q13. Khi người dùng từ chối đồng ý quảng cáo

Phần xử lý đồng ý nằm trong phạm vi và bắt buộc. Câu hỏi này xác định điều gì xảy ra khi người dùng từ chối.

Xử lý thế nào?

- A. Vẫn hiện quảng cáo nhưng ở dạng không cá nhân hóa
- B. Không hiện quảng cáo nào cho người dùng đó
- C. Not yet defined (chưa xác định, để bước thiết kế quyết định)
- X. Other (please specify)

[Answer]:A

## Q14. Khởi tạo quảng cáo và khởi động ứng dụng

Ứng dụng có hạn chót 3,5 giây để khởi động xong ở màn Splash. Khởi tạo quảng cáo không nên làm chậm bước này.

Quy tắc nào áp dụng?

- A. Khởi tạo quảng cáo chạy nền, không chặn và không tính vào hạn chót 3,5 giây; nếu chưa xong thì chưa hiện quảng cáo
- B. Khởi tạo quảng cáo nằm trong hạn chót 3,5 giây, quá hạn thì bỏ qua quảng cáo
- C. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:A

## Q15. Làm rõ cách đếm cho banner (câu hỏi bổ sung cho Q1 và Q8)

Ở Q1 bạn trả lời "mỗi lần mở ứng dụng", và ở Q8 bạn chọn lưu bộ đếm bền (giữ khi thoát ứng dụng). Hai câu trả lời này cho thấy bộ đếm của banner là số lần mở ứng dụng, nhưng chưa rõ banner hiện ở những lần mở nào. Với N bằng 3:

Banner hiện như thế nào?

- A. Banner hiện ở mọi màn chơi, từ lần mở ứng dụng thứ 3 trở đi và các lần sau đó
- B. Banner chỉ hiện ở lần mở ứng dụng thứ 3, và không hiện ở các lần khác
- C. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:A

## Consolidated Summary Confirmation

- Banner: bộ đếm là số lần mở ứng dụng, lưu bền, banner hiện ở mọi màn chơi từ lần mở thứ N (mặc định 3) trở đi (Q1, Q8, Q15)
- Tham số Firebase: chấp nhận tên và giá trị mặc định đề xuất (Q2)
- Reward ads: một lần cho mỗi ván thua (Q3); xem xong thì điểm về 0, bàn cờ sạch, khay khối mới, level không bị hạ (Q4); đóng sớm thì không thưởng và ẩn nút khi quảng cáo chưa sẵn sàng (Q5)
- Endless: có banner và interstitial, không có reward ads (Q6)
- Interstitial: đếm lần bấm PLAY ở Home và PLAY AGAIN ở Game Over, lưu bền, không có khoảng cách tối thiểu (Q7, Q8)
- `ads_priority`: thiếu hoặc rỗng thì dùng mặc định, tên lạ bị bỏ qua, mạng đầu không có quảng cáo thì thử các mạng còn lại (Q9)
- Popup cập nhật: chỉ so tên phiên bản, hiện tối đa một lần mỗi lần mở ứng dụng (Q10)
- Link rỗng hoặc không hợp lệ: không hiện popup, nội dung chia sẻ giữ nguyên (Q11)
- Chia sẻ: thêm link ở cuối văn bản, chọn theo hệ điều hành (Q12)
- Từ chối đồng ý: vẫn hiện quảng cáo không cá nhân hóa (Q13)
- Khởi động: khởi tạo quảng cáo chạy nền, không chặn hạn chót 3,5 giây (Q14)

Does this all look correct before I generate the requirements artifact?

- Looks correct
- Request changes

[Answer]: Looks correct
