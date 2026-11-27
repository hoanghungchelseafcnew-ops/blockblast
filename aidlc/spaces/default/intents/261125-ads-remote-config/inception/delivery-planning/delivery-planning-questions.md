# Câu hỏi lập kế hoạch giao hàng: Quảng cáo và Remote Config

Bước này chọn thứ tự làm bốn unit. Một Bolt là một lượt xây dựng cho một phần việc, kết thúc bằng một thứ chạy được. Theo `unit-of-work-dependency.md`, `u1-ads-core` phải làm đầu tiên vì ba unit còn lại đều phụ thuộc nó, nên câu hỏi chủ yếu là thứ tự của `u2-reward-ads`, `u3-banner` và `u4-update-and-share` sau đó. Thực hành của đội yêu cầu làm một bản mỏng chạy xuyên suốt trước (một phiên bản tối thiểu chạy hết đường đi để chứng minh các phần nối được với nhau), và đó chính là `u1-ads-core`. (`team-practices.md`)

## Q1. Thứ tự làm ba unit còn lại

Mỗi unit có rủi ro và giá trị khác nhau: `u2-reward-ads` rủi ro cao nhất vì đổi luồng thua ván, `u3-banner` mang doanh thu và rủi ro thấp, `u4-update-and-share` rủi ro thấp và giá trị gián tiếp.

Sau `u1-ads-core`, bạn muốn làm theo thứ tự nào?

- A. Rủi ro trước: `u2-reward-ads`, rồi `u3-banner`, rồi `u4-update-and-share`
- B. Giá trị trước: `u3-banner`, rồi `u2-reward-ads`, rồi `u4-update-and-share`
- C. Việc dễ trước: `u4-update-and-share`, rồi `u3-banner`, rồi `u2-reward-ads`
- D. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:A

## Q2. Có chấm điểm theo mô hình chính thức không

Mô hình WSJF (Weighted Shortest Job First) xếp hạng việc bằng điểm: (giá trị cộng mức khẩn cấp cộng giá trị giảm rủi ro) chia cho kích thước công việc. Với chỉ ba unit còn lại, cách này có thể thừa.

- A. Không, sắp xếp theo lý do định tính (rủi ro và giá trị) ghi trong tài liệu
- B. Có, chấm điểm WSJF cho từng unit
- C. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:A

## Q3. Kích thước mỗi Bolt

- A. Mỗi unit là một Bolt, tổng cộng bốn Bolt
- B. Chia `u1-ads-core` thành hai Bolt (nền tảng, rồi interstitial), ba unit còn lại mỗi unit một Bolt
- C. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:A

## Q4. Nhiều Bolt cùng lúc hay lần lượt

Đội có một developer duy nhất.

- A. Lần lượt, từng Bolt một
- B. Song song khi sơ đồ phụ thuộc cho phép
- C. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:A

## Q5. Những thứ bên ngoài có thể làm chậm công việc

Mình đề xuất danh sách dưới đây dựa trên các bước trước. Mỗi mục ghi bên sở hữu, thời gian chờ và Bolt bị ảnh hưởng.

| Mục | Bên sở hữu | Thời gian | Bolt ảnh hưởng | Nếu chậm |
|-----|-----------|-----------|----------------|----------|
| Trang cửa hàng thật (link cho popup và chia sẻ) | Bạn, qua Google Play Console và App Store Connect | Phụ thuộc thời gian duyệt của cửa hàng | `u4-update-and-share` | Dùng link giả và đổi qua Firebase sau |
| Tài khoản và ad unit của ba mạng | Bạn (đã có) | Không | `u1-ads-core` | Dùng quảng cáo thử |
| Quảng cáo thật (không phải quảng cáo thử) | Mạng quảng cáo | Phụ thuộc mạng duyệt ứng dụng | `u1-ads-core`, `u2-reward-ads`, `u3-banner` | Kiểm thử bằng quảng cáo thử, quảng cáo thật khi ứng dụng lên cửa hàng |
| Giá trị cấu hình trên Firebase Console | Bạn | Ngay lập tức | tất cả | Dùng giá trị mặc định |

Danh sách này đúng chưa?

- A. Đúng, giữ nguyên
- B. Cần thêm hoặc sửa (nêu rõ ở Other)
- X. Other (please specify)

[Answer]:A

## Q6. Điều bạn lo nhất (select all that apply)

Điều bạn chọn sẽ được xử lý sớm trong kế hoạch.

- A. Reward ads đổi luồng thua ván và có thể làm hỏng lưu tiến trình
- B. Xử lý đồng ý của người dùng ở EU và iOS
- C. Thời gian chờ quảng cáo khi thử nhiều mạng
- D. Tích hợp ba SDK quảng cáo cùng lúc
- E. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:A, B, C, D

## Q7. Bản mỏng chạy xuyên suốt: cách chứng minh và lệnh kiểm tra

`u1-ads-core` là bản mỏng. Cách chứng minh dự kiến: mở ứng dụng, bấm PLAY đủ N lần với quảng cáo thử của một mạng thì interstitial hiện rồi vào màn chơi, và khi tắt mạng thì ứng dụng vẫn chạy bằng giá trị mặc định.

Công cụ cần một lệnh kiểm tra thật của dự án để chạy ở mỗi điểm kiểm tra của Unit. Thực hành của đội ghi bạn tự chạy `flutter analyze` và `flutter test --coverage` rồi báo kết quả, AI chỉ sinh code và test.

Bạn muốn xử lý lệnh kiểm tra thế nào?

- A. Chọn lệnh `flutter analyze && flutter test --coverage` để công cụ chạy ở mỗi điểm kiểm tra
- B. Hoãn chọn lệnh. Bạn tự chạy và báo kết quả, điểm kiểm tra đầu tiên sẽ hỏi lại trước khi xác minh
- C. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:B

## Q8. Cách bố trí người làm ở giai đoạn xây dựng

- A. Một phiên làm việc, lần lượt từng Unit, theo cài đặt hiện có (mỗi Unit có điểm kiểm tra riêng)
- B. Mỗi đội sở hữu một Unit và tự duyệt (không áp dụng khi chỉ có một developer)
- C. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:A

## Consolidated Summary Confirmation

- Thứ tự: `u1-ads-core` trước, rồi `u2-reward-ads`, rồi `u3-banner`, rồi `u4-update-and-share` (rủi ro trước) (Q1)
- Chấm điểm: không dùng WSJF, sắp xếp theo lý do định tính (Q2)
- Kích thước Bolt: mỗi unit là một Bolt, tổng cộng bốn Bolt (Q3)
- Thực hiện: lần lượt từng Bolt một (Q4)
- Phụ thuộc bên ngoài: đúng như danh sách đề xuất (trang cửa hàng thật, tài khoản và ad unit, quảng cáo thật, giá trị cấu hình trên Firebase) (Q5)
- Điều lo nhất, xử lý sớm: reward ads đổi luồng thua ván, đồng ý ở EU và iOS, thời gian chờ quảng cáo, tích hợp ba SDK. Ba mối lo sau nằm trong `u1-ads-core` nên được xử lý ngay ở Bolt đầu, và mối lo đầu là unit đầu tiên sau đó (Q6)
- Bản mỏng chạy xuyên suốt: `u1-ads-core`. Lệnh kiểm tra hoãn chọn: bạn tự chạy `flutter analyze` và `flutter test --coverage` rồi báo kết quả, điểm kiểm tra đầu tiên sẽ hỏi lại trước khi xác minh (Q7)
- Bố trí: một phiên làm việc, lần lượt từng Unit, theo cài đặt hiện có (Q8)

Does this all look correct before I generate the artifact?

- Looks correct
- Request changes

[Answer]: Looks correct
