## Review

**Verdict:** NOT-READY
**Reviewer:** aidlc-product-lead-agent
**Iteration:** 1

Giới hạn của review này: reviewer không có công cụ đọc/ghi file trong phiên này. Mọi finding dựa trên mô tả artifact trong brief, chưa đối chiếu với file thật. Đây là review tư vấn (advisory) một lượt, không có vòng sửa. Người điều phối đã chép nguyên văn nội dung review của reviewer vào file này.

### Findings

| ID | Severity | Location | Finding | Required action | Status |
|---|---|---|---|---|---|
| R-01 | Critical | rough-mockups > luồng người dùng / W-5 (sau level 36 Ruby Bling) | Hành vi sau level 36 chưa được định nghĩa. W-5 có nút CONTINUE nhưng không có "level tiếp theo". Người chơi hoàn thành toàn bộ game sẽ gặp trạng thái bế tắc. Màn Home cũng không nói PLAY làm gì khi đã xong. | Người dùng chọn một hành vi và mockup thể hiện nó: màn "Hoàn thành hành trình", hoặc chơi lại level 36, hoặc quay về Home và PLAY bắt đầu lại. Ghi rõ phần còn lại của trạng thái đã lưu. | New |
| R-02 | Major | rough-mockups > W-3 Game Over / luồng thất bại | Quy tắc thua dễ gây hiểu lầm và chưa nhất quán. "You will return to <gem> · Rough Stone" nghĩa là thua ở bất kỳ sub-level nào cũng quay về sub-level đầu của gem hiện tại. Brief chỉ nói "keep existing" nên không rõ đây là hành vi hiện có hay hành vi mới. Brief cũng không nói PLAY AGAIN và BACK TO MENU có thay đổi tiến độ đã lưu hay không. Với Rough Stone (đã ở sub-level đầu) thì dòng thông báo vô nghĩa. | Quy định rõ: thua ở sub-level 1 thì hiện câu gì; BACK TO MENU và PLAY AGAIN có ghi đè tiến độ lưu không; thông báo này có hiện trước khi bắt đầu chơi không. Cần có tiêu chí kiểm thử cho từng nhánh. | New |
| R-03 | Major | rough-mockups > W-4/W-5 vs W-3 và tiến độ lưu | Chưa có quy tắc lưu tiến độ. Không có màn chọn level, nên "saved current level" là thứ duy nhất xác định vị trí người chơi. Chưa rõ thời điểm lưu (khi thắng, hay khi bấm CONTINUE) và chuyện gì xảy ra nếu thoát app ở W-4/W-5. Người chơi cũng không còn cách nào đến lại một level đã mở khóa. | Ghi rõ thời điểm lưu và hành vi khi thoát giữa chừng. Xác nhận rằng không có đường quay lại level cũ là chủ đích, vì mất khả năng chọn level là hệ quả của việc bỏ S-07/FR-07. | New |
| R-04 | Major | rough-mockups > W-2 nút ← và "back buttons go Home" | Bấm ← giữa ván chưa có quy tắc. Ván có bị bỏ không, có hỏi xác nhận không, tiến độ ván có giữ không. Đây là assumption còn mở, và nó gây mất dữ liệu người chơi. Brief cũng không nói nút Back của hệ thống (Android) hay cử chỉ quay lại có hành xử giống nút ← không. | Chốt hành vi (xác nhận, tự lưu, hoặc bỏ ván) cho cả nút ← và Back hệ thống, và vẽ nó vào mockup. | New |
| R-05 | Minor | rough-mockups > W-5 | Hai yêu cầu dễ sai: "Bling" chỉ gắn với 6 sub-level cuối của mỗi gem, nhưng brief gọi level 36 là "Ruby Bling". W-5 có âm thanh mở khóa nhưng chưa nêu quy tắc khi tắt tiếng thiết bị hoặc cài đặt âm thanh trong Settings. Hiệu ứng xoay 2D và confetti cũng chưa có phương án cho "giảm chuyển động". | Nêu rõ âm thanh tuân theo cài đặt hiện có, và có phương án tĩnh cho người dùng tắt hiệu ứng. Xác nhận cách đặt tên Bling cho từng gem. | New |
| R-06 | Minor | rough-mockups > ghi chú a11y của W-1…W-6 | Ghi chú a11y mới ở mức cơ bản và còn mơ hồ. "Contrast" chưa có ngưỡng đo được (ví dụ ≥ 4.5:1 cho chữ). Thanh tiến độ ở W-2 và "score/target" cần nhãn đọc được cho trình đọc màn hình. Nền mờ ở W-2 có thể làm giảm tương phản của khối và bảng. Chưa có trạng thái lỗi/trống (chưa có dữ liệu lưu thì hiện gì ở W-1). | Thay "contrast" bằng ngưỡng cụ thể. Thêm nhãn cho progress bar. Nêu trạng thái người chơi mới ở W-1. | New |
| R-07 | Minor | rough-mockups > W-1 Home | Nhãn "current level" ở W-1 và nút PLAY/JOURNEY: brief gọi cả hai tên. Chưa nói nhãn hiển thị ra sao với người chơi mới (Rose Quartz > Rough Stone) và sau khi xong game. Daily Gift bị bỏ nên cần xác nhận không còn tham chiếu nào trong luồng hoặc trong Settings. | Chốt một tên nút duy nhất và định dạng nhãn level. Xác nhận không còn tham chiếu Daily Gift. | New |

### Summary

Phạm vi sau các quyết định của người dùng gọn và rõ, nhưng còn một lỗ hổng chặn (R-01: không có gì xảy ra sau level 36) và ba điểm lớn về tiến độ lưu, nhánh thua và nút quay lại (R-02 đến R-04). Cả ba điểm đó đều dẫn đến việc dev phải quay lại hỏi, nên reviewer đánh NOT-READY. Vì đây là review tư vấn, người duyệt có thể chấp nhận phần còn mở rồi ghi lại quyết định.
