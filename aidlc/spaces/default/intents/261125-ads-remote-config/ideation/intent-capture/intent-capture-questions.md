# Câu hỏi làm rõ ý định: Quảng cáo và Remote Config

## Sources

- [desc] Initial description: "Thiết lập quảng cáo và Remote Config trên Firebase: (1) banner ở màn chơi, chỉ hiện từ lần vào thứ N (mặc định lần 3, N cấu hình được); (2) nút xem reward ads để tiếp tục ở level hiện tại thay vì quay về Rough Stone khi thua, có cờ bật/tắt trên Firebase; (3) interstitial ads sau mỗi N lần bấm Start, N cấu hình trên Firebase; (4) ads_priority (ví dụ admob,unity,applovin) quyết định thứ tự mediation cho banner, reward và interstitial; (5) config android_version, android_url, ios_version, ios_url để kiểm tra phiên bản và hiện popup cập nhật; (6) dùng android_url và ios_url trong nội dung chia sẻ."
- [scope] Workflow-selected scope: `feature`.
- [memory:M1] `aidlc/spaces/default/memory/project.md#Mandated`: "ALWAYS dùng tiếng Anh cho mọi chuỗi hiển thị trên UI của game, không hỗ trợ đa ngôn ngữ. (affirmed 2026-11-20)"
- [memory:M2] `aidlc/spaces/default/memory/team.md#Way of Working`: "Một developer duy nhất, có dùng git để giữ lịch sử phiên bản (đã xác nhận ở phỏng vấn, thay cho ghi chú cũ \"không dùng git\"). Quy ước nhánh và merge theo mặc định của org (trunk-based, nhánh ngắn hạn); AI sinh code và người dùng tự commit."

## Q1. Vấn đề kinh doanh cần giải quyết

Mô tả của bạn gồm 6 hạng mục về quảng cáo và cấu hình từ xa. Câu hỏi này xác định lý do chính phía sau toàn bộ nhóm hạng mục đó, để các bước sau ưu tiên đúng.

Vấn đề chính cần giải quyết là gì?

- A. Tạo doanh thu từ quảng cáo trong game
- B. Điều chỉnh hành vi quảng cáo từ xa (qua Firebase) mà không cần phát hành lại ứng dụng
- C. Cả A và B
- D. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:C

## Q2. Khách hàng và nỗi đau của họ

Câu hỏi này xác định ai bị ảnh hưởng trực tiếp bởi quảng cáo, nút reward và popup cập nhật.

Ai là đối tượng hưởng lợi hoặc chịu tác động chính?

- A. Người chơi cuối trên cả Android và iOS (nỗi đau: thua phải quay lại Rough Stone, bản cũ không biết để cập nhật)
- B. Người chơi cuối chỉ trên Android
- C. Chỉ chính nhà phát triển (người vận hành quảng cáo và cấu hình)
- D. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:A

## Q3. Thế nào là thành công (chọn tất cả đáp án phù hợp)

Câu hỏi này cần số đo cụ thể để sau này kiểm tra được hạng mục có đạt hay không. (select all that apply)

Các chỉ số nào quan trọng với bạn?

- A. Doanh thu quảng cáo trên mỗi người dùng hoạt động hàng ngày tăng
- B. Tỷ lệ người chơi bấm xem reward ads khi thua
- C. Tỷ lệ người dùng cập nhật lên phiên bản mới sau khi thấy popup
- D. Tỷ lệ giữ chân người chơi (retention) không giảm sau khi thêm quảng cáo
- E. Not yet defined (chưa xác định mức mục tiêu cụ thể)
- X. Other (please specify)

[Answer]:A, B, C, D

## Q4. Lý do làm ngay bây giờ

Câu hỏi này xác định điều gì thúc đẩy sáng kiến này, để các bước sau cân đối độ gấp.

Điều gì là động lực chính?

- A. Cần bắt đầu tạo doanh thu từ game
- B. Cần điều khiển quảng cáo mà không phải gửi bản cập nhật lên cửa hàng ứng dụng mỗi lần đổi
- C. Có nhiều người vẫn dùng bản cũ, cần kéo họ cập nhật
- D. Cơ hội/ý tưởng mới, không có áp lực cụ thể
- E. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:A, C, 

## Q5. Người quyết định phạm vi và ưu tiên

Câu hỏi này xác nhận ai quyết định và ai chỉ góp ý. Ghi chú nhóm hiện tại ghi nhận chỉ có một developer [memory:M2].

Ai quyết định phạm vi và ưu tiên của sáng kiến này?

- A. Chỉ bạn (developer duy nhất) quyết định
- B. Bạn quyết định, có người khác chỉ góp ý (ví dụ nhà đầu tư, bạn bè thử game)
- C. Có người khác cùng quyết định
- D. Not identified (chưa xác định)
- X. Other (please specify)

[Answer]:A

## Q6. Yêu cầu giao tiếp và báo cáo

Câu hỏi này xác định có ai cần được cập nhật tiến độ hoặc kết quả không.

Có yêu cầu giao tiếp hay nhịp báo cáo nào không?

- A. Không có (None), chỉ mình bạn theo dõi
- B. Có, cần báo cáo ngắn khi hoàn tất từng hạng mục
- C. Có, cần báo cáo định kỳ (hàng tuần hoặc theo đợt phát hành)
- D. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:A

## Q7. Mạng quảng cáo dùng cho mediation

Mô tả của bạn nêu `ads_priority` ví dụ `admob,unity,applovin` quyết định thứ tự mediation [desc]. Câu hỏi này xác định tình trạng sẵn sàng của các mạng quảng cáo, vì chúng ảnh hưởng đến việc thực hiện.

Tình trạng các tài khoản và ad unit của các mạng này như thế nào?

- A. Đã có tài khoản và ad unit cho cả ba mạng (AdMob, Unity, AppLovin)
- B. Chỉ một số mạng đã sẵn sàng (nêu rõ ở Other)
- C. Chưa có mạng nào, sẽ tạo sau
- D. Not yet defined (chưa xác định), cần tư vấn
- X. Other (please specify)

[Answer]:A

## Q8. Ràng buộc chính sách và quyền riêng tư

Quảng cáo trên Android và iOS thường kèm các yêu cầu về chính sách cửa hàng và sự đồng ý của người dùng (ví dụ GDPR, App Tracking Transparency của iOS). Câu hỏi này chỉ ghi nhận ràng buộc đã biết, chưa quyết định cách giải quyết.

Có ràng buộc pháp lý hoặc chính sách nào bạn đã biết cần tuân thủ không?

- A. Không có ràng buộc nào đã biết (None)
- B. Có, cần xử lý đồng ý của người dùng (GDPR/ATT hoặc tương đương)
- C. Có, chỉ chính sách cửa hàng (Google Play, App Store)
- D. Not identified (chưa xác định, cần tìm hiểu ở bước khả thi)
- X. Other (please specify)

[Answer]:B

## Q9. Xác nhận phạm vi sản phẩm

Quy trình được khởi tạo với phạm vi `feature` [scope], đây là phạm vi do quy trình chọn, chưa phải điều bạn đã xác nhận. Câu hỏi này phân biệt hai việc: xác nhận phạm vi quy trình, và xác định ranh giới sản phẩm thực sự bạn muốn.

Ranh giới sản phẩm bạn muốn là gì?

- A. Đúng 6 hạng mục trong mô tả ban đầu (banner, reward ads, interstitial, ads_priority, kiểm tra phiên bản, link trong nội dung chia sẻ), không hơn
- B. Chỉ một số hạng mục trong 6 hạng mục (nêu rõ hạng mục nào ở Other)
- C. 6 hạng mục và thêm các việc liên quan khác (nêu rõ ở Other)
- D. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:A

## Consolidated Summary Confirmation

Does this all look correct before I generate the artifact?

- Looks correct
- Request changes

[Answer]: Looks correct
