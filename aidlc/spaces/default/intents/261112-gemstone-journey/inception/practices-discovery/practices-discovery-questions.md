# Practices Discovery Questions — Gemstone Journey

Những gì đã kiểm tra được:
- Thư mục dự án **chưa phải git repo** và chưa có CI.
- Test hiện có đang hỏng.
- Máy này chưa có `flutter` trên PATH, nên tôi chưa build hay test được.

Các câu trả lời bên dưới sẽ được lưu làm quy ước lâu dài của bạn, dùng cho cả các dự án sau. Ngoại lệ là câu Q8: câu đó ghi ràng buộc cho riêng dự án này.

---

## Q1. Bạn quản lý code bằng git như thế nào?

A. Khởi tạo git. Làm trên nhánh `main`, mỗi tính năng làm trên một nhánh ngắn rồi squash-merge vào `main` (mặc định)
B. Khởi tạo git và commit thẳng lên `main` (dự án một người)
C. Không dùng git
X. Other (please specify)

[Answer]:C

---

## Q2. Có nên làm một bản chạy được từ đầu đến cuối trước không?

"Walking skeleton" là một phiên bản tối giản chạy xuyên suốt toàn bộ luồng, được làm đầu tiên để kiểm chứng các phần ghép được với nhau trước khi làm tính năng thật. Ở dự án này, đó có thể là: bấm PLAY, chơi 1 level với mốc điểm lấy từ Remote Config, thắng thì sang level 2, và tiến trình được lưu lại.

A. Có. Làm bản xuyên suốt tối giản trước, sau đó mới hoàn thiện từng phần
B. Không. Làm lần lượt từng phần theo thứ tự đã chọn (dependency-first)
C. Theo mặc định của scope `feature`
X. Other (please specify)

[Answer]:A

---

## Q3. Bạn viết test theo cách nào?

A. Viết code trước, viết test sau cho từng phần (test-after, mặc định)
B. Viết test trước rồi mới viết code (TDD)
C. Chỉ viết test cho logic quan trọng (level, điểm, tiến trình, config), không viết cho UI
X. Other (please specify)

[Answer]:A

---

## Q4. Ngưỡng coverage 80% áp dụng cho phạm vi nào?

A. Cho code mới và code bị sửa trong dự án này (logic level, controller, service)
B. Cho toàn bộ codebase
C. Không đặt ngưỡng cứng
X. Other (please specify)

[Answer]:B

---

## Q5. Bạn build và phát hành app như thế nào?

A. Build thủ công trên máy (`flutter build appbundle` / `flutter build ipa`), upload tay lên Play Console và App Store Connect
B. Muốn thiết lập CI/CD (ví dụ GitHub Actions, Codemagic) để build và phát hành tự động
C. Đợt này chỉ build để test trên máy, chưa phát hành
X. Other (please specify)

[Answer]:A

---

## Q6. Lệnh nào dùng để kiểm tra code trước khi coi là xong?

A. `flutter analyze` + `flutter test` (cần cài Flutter vào PATH của máy này)
B. Như A, thêm `dart format --set-exit-if-changed .`
C. Tôi tự chạy trên máy khác. AI chỉ viết code, không chạy được build
X. Other (please specify)

[Answer]:A

---

## Q7. Có nên tách logic game ra khỏi màn hình không?

Hiện toàn bộ logic nằm trong `GameScreen`. Đề xuất là đưa logic và state vào controller/service (ChangeNotifier qua `provider`), màn hình chỉ lo hiển thị.

A. Có. Đây là quy ước bắt buộc cho code mới (dùng `game_controller.dart` đang rỗng)
B. Có, nhưng chỉ khuyến khích, không bắt buộc
C. Không. Giữ nguyên cách viết hiện tại
X. Other (please specify)

[Answer]:A

---

## Q8. Có ràng buộc cứng nào cần ghi lại không? (chọn nhiều nếu cần)

A. ALWAYS: chuỗi hiển thị trên UI chỉ dùng tiếng Anh
B. NEVER: không để Firebase Storage cho phép ghi công khai
C. NEVER: không bắt lỗi rồi bỏ qua im lặng. Phải log lỗi và có fallback
D. Không có ràng buộc nào
X. Other (please specify)

[Answer]:A

---

Ví dụ trả lời trong chat: "1A 2B 3A 4A 5A 6A 7A 8ABC"

---

# Follow-up Questions

## Q9. Q1 "Không dùng git" xung đột với quy ước chung của tổ chức. Bạn muốn xử lý thế nào?

Quy ước org (`org.md` → Way of Working) yêu cầu trunk-based trên `main` và squash-merge. Không có git thì:
- Không quay lại được khi AI sinh code sai, vì không có bản ghi thay đổi để rollback.
- Ở giai đoạn Construction, không tách được từng phần việc ra nhánh hoặc worktree riêng. Mọi thay đổi ghi thẳng vào thư mục dự án.

A. Đồng ý khởi tạo git, commit thẳng lên `main` (vẫn phù hợp với trunk-based)
B. Đồng ý khởi tạo git, dùng nhánh ngắn rồi squash-merge (như mặc định)
C. Vẫn không dùng git. Tôi chấp nhận rủi ro, và mọi thay đổi ghi trực tiếp vào thư mục
X. Other (please specify)

[Answer]: C

---

## Q10. Q6 cần `flutter` trên PATH của máy này, nhưng hiện tại chưa có. Bạn muốn làm thế nào?

A. Tôi sẽ cài Flutter (hoặc thêm vào PATH) trước giai đoạn Construction
B. Flutter đã có ở đường dẫn khác (vui lòng ghi rõ đường dẫn)
C. Tôi tự chạy `flutter analyze` / `flutter test` trên máy khác và báo kết quả
X. Other (please specify)

[Answer]: X. bạn cứ gen code để t tự build trên máy khác

---

## Consolidated Summary Confirmation

Does this all look correct before I generate the artifact?

- Q1, Q9: Không dùng git. Chấp nhận rủi ro không rollback được, mọi thay đổi ghi trực tiếp vào thư mục (lệch khỏi quy ước trunk-based của org)
- Q2: Có walking skeleton. Làm trước một bản xuyên suốt tối giản
- Q3: Test-after. Viết code trước, test sau cho từng phần
- Q4: Ngưỡng coverage 80% cho toàn bộ codebase
- Q5: Build thủ công và upload tay lên các store
- Q6, Q10: Kiểm tra bằng `flutter analyze` + `flutter test`. AI chỉ sinh code, người dùng tự build và test trên máy khác rồi báo kết quả
- Q7: Bắt buộc tách logic sang controller/service cho code mới
- Q8: ALWAYS: chuỗi hiển thị trên UI chỉ dùng tiếng Anh

- Looks correct
- Request changes

[Answer]: Looks correct
