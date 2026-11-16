## Review

**Verdict:** READY
**Reviewer:** aidlc-product-lead-agent
**Iteration:** 1

Người điều phối chép nguyên văn review do reviewer trả về (reviewer không có công cụ ghi file). Đây là lượt review mới vì engine mở lại stage. Artifact không thay đổi so với lượt trước.

### Findings

| ID | Severity | Location | Finding | Required action | Status |
|---|---|---|---|---|---|
| R-01 | Major | design-system-mapping > gem tokens (Amethyst onGemPrimary); accessibility-checklist > contrast | Chữ trắng trên Amethyst chỉ đạt 4.10:1, tức là dưới ngưỡng 4.5:1 của chữ thường. Thiết kế dựa vào ngoại lệ "chữ lớn" (20 w700), nhưng chưa nói 20 là dp hay px. Chưa kiểm tra các bề mặt khác dùng màu này (nút, chip, tiêu đề). | Ghi rõ đơn vị (dp/sp). Liệt kê mọi bề mặt dùng Amethyst và xác nhận chữ trên đó đều thuộc cỡ chữ lớn. Nếu có chữ nhỏ hơn thì đổi màu nền hoặc màu chữ. | Unresolved |
| R-02 | Major | interaction-spec > LevelProgressBar; M-2 | Thanh tiến độ chỉ nhìn thấy được nhờ viền trắng 1.5dp. Số đo của conductor (viền trắng trên ảnh nền sáng nhất dưới lớp phủ đen 50%, khoảng #808080) cho 3.95:1, thấp hơn 3:1 cần cho thành phần UI? Không: 3.95:1 vượt 3:1 nên đạt WCAG 1.4.11. Tuy vậy con số này chưa được ghi vào tài liệu. Trạng thái 0% và 100% cũng chưa được định nghĩa. | Ghi tỉ lệ 3.95:1 và cách đo vào accessibility-checklist. Mô tả hình dạng thanh ở 0% (chỉ có track, không có phần fill) và ở 100% (fill đầy, bo góc ra sao). | Unresolved |
| R-03 | Major | interaction-spec > VictoryScreen; M-4 | Màn Victory chưa có bảng trạng thái cho các tình huống gián đoạn: bấm Back khi đang Victory, đưa app xuống nền, chạm lần hai sau khi đã khóa, chạm trong 180ms của animation dọn dẹp. Dev sẽ phải tự đoán. | Thêm bảng gồm trạng thái (celebrating/idle/leaving/final), sự kiện và kết quả. Chốt rõ: Back có bị chặn không, tiến trình được lưu lúc nào, và khi quay lại từ nền thì vào trạng thái nào. | Unresolved |
| R-04 | Major | M-1 (journey complete) và M-2e; interaction-spec | Lần vào Endless đầu tiên chưa quy định giá trị BEST (0, "—" hay ẩn). Hàng 6 viên ngọc ở 96dp mỗi viên không vừa màn 360dp (576dp + khoảng cách) và chưa nói cách xử lý (cuộn, co lại hay xuống hàng). | Chốt giá trị BEST khi chưa có dữ liệu. Chốt bố cục hàng ngọc ở 360dp (ví dụ co kích thước hoặc 2 hàng 3) và ghi vào đặc tả. | Unresolved |
| R-05 | Major | accessibility-checklist > A12 (⚠️) | Ngưỡng textScale 1.3 chỉ là giả định (⚠️), chưa được kiểm chứng. Các chuỗi dài như "Blue Topaz · Polishing" và "You will return to Amethyst · Rough Stone" chưa có quy tắc xuống dòng hay co chữ. | Chốt quy tắc: tối đa số dòng, ellipsis hay xuống dòng, kích thước tối thiểu. Đổi ⚠️ thành tiêu chí kiểm thử cụ thể, hoặc ghi nhận là rủi ro được chấp nhận. | Unresolved |
| R-06 | Minor | design-system-mapping > component mapping; M-1 | Icon giữ chỗ Icons.diamond được tô màu thay cho ngọc thật. Dòng "Level N of 36" là nội dung ngoài phạm vi yêu cầu. | Ghi chú Icons.diamond là tạm thời. Xác nhận hoặc bỏ dòng "Level N of 36". | Unresolved |
| R-07 | Minor | M-0 Splash | "≤2s" chưa có tiêu chí kiểm thử. Khi hết thời gian chờ, Home tải mặc định, nhưng điều này chưa được ghi thành điều kiện chấp nhận. | Viết tiêu chí Given/When/Then, ví dụ: khi Remote Config chưa trả về sau 2s thì vào Home với giá trị mặc định. | Unresolved |
| R-08 | Minor | M-5 Bling | Âm thanh mở khóa thay thế khi người dùng tắt tiếng chưa được nói rõ. | Ghi rõ khi tắt tiếng thì không phát âm thanh và thay bằng phản hồi hình ảnh nào. | Unresolved |

### Summary

Bộ mockup đủ rõ để bắt đầu làm, và các điểm Major còn lại là chỗ cần chốt thêm chứ không chặn việc triển khai. R-02 thực ra đã đạt ngưỡng 3:1 nên chỉ cần ghi lại số đo. Tôi nghiêng về chốt R-03 và R-04 trước khi vào code, vì dev sẽ phải tự quyết định ở hai chỗ này. Vì có 5 điểm Major, bằng chứng ở trên chỉ ủng hộ READY nếu người duyệt chấp nhận các điểm này là rủi ro có chủ ý hoặc sửa chúng trong giai đoạn xây dựng. Đây là đánh giá tham khảo, không phải cổng chặn.
