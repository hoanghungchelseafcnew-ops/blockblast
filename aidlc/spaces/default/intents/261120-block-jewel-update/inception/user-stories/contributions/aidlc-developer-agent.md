**Collaborator:** aidlc-developer-agent

## Contribution
Soạn bởi người điều phối thay mặt vai developer (subagent không có công cụ file).
- Sinh khối cần nhận bảng và level; `BoardEngine` hiện chỉ có `BlockSource` không tham số nên cần đổi chữ ký hoặc thêm lớp chọn khối.
- Duyệt tìm khối đặt vừa là O(64 × số hình); đủ nhanh cho luồng UI.
- Chia sẻ ở Victory dùng lại `ScoreShareService` và `ScreenshotController` của `GameScreen`, chỉ cần thêm nút và truyền callback.
- Gỡ splash native: phải sửa tay `styles.xml`, `launch_background.xml`, storyboard và gỡ `flutter_native_splash`.
- Story US4.6 đúng kích thước; US4 tách 6 story là hợp lý.

## Positions
None.
