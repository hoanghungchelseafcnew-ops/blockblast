# Security Design: u3-tray-algorithm

Nguồn: security-requirements.md, tech-stack-decisions.md, functional-spec.md (BR5.2, BR5.4).

U3 không có xác thực, phân quyền, mã hóa hay lưu trữ. Thiết kế chỉ cần bảo đảm tính cô lập, an toàn đầu vào và không treo luồng UI.

| Yêu cầu | Giải pháp thiết kế |
|---|---|
| NFR6.1 Không IO, không gửi dữ liệu ra ngoài | `TrayGenerator`, `DifficultyProfile` và bộ giải là lớp thuần Dart. Không import `dart:io`, `shared_preferences`, `firebase_*`, `provider` hay `flutter/widgets`. Đầu vào là `board`, `level`, `Random`; đầu ra là `TrayResult`. |
| NFR6.2 Log không chứa dữ liệu cá nhân | Log lỗi bộ giải qua `GjLog` chỉ ghi `level`, số ô đã lấp và `tier` đã thử. Không ghi nội dung bảng nếu không cần. |
| NFR7.1 Level đầu vào an toàn, không đổi dữ liệu đã lưu | Hàm tính `t` kẹp `level` vào 1..36 trước khi dùng. U3 không đọc hay ghi khóa lưu trữ nào. |
| NFR7.2 Không thêm quyền hay gói | Không đổi `pubspec.yaml` hay manifest. |
| NFR4.1 Chuỗi tiếng Anh | U3 không có chuỗi hiển thị. |
| NFR2.2 Bền với đầu vào bất thường | Bộ giải bọc trong try/catch tại ranh giới `TrayGenerator.prepare`. Ngoại lệ được ghi log và xử lý như "chưa chứng minh được" ở tier hiện tại, rơi về tier kế tiếp. Ngân sách nút cố định chặn vòng lặp dài. Không có đệ quy không giới hạn: độ sâu tối đa là 3 (số khối). |

## Mối đe dọa và kiểm soát

| Mối đe dọa | Kiểm soát |
|---|---|
| Bộ giải chạy lâu làm treo luồng UI (từ chối dịch vụ cục bộ) | `solverNodeBudget` cho mỗi lần chuẩn bị, giới hạn `maxStrictCandidates` và `maxRelaxedCandidates`, thoát sớm khi tìm được cách đặt, tier fallback không cần tìm kiếm khi còn từ 3 ô trống |
| Khay không hợp lệ đến người chơi | `TrayResult` chỉ mang khay đã đạt một tier hoặc `gameOver`; ngoại lệ không bao giờ tạo khay rỗng |
| Kết quả không tái hiện được khi lỗi | Tất định theo seed (BR5.2); ngân sách tính theo nút, không theo đồng hồ |
