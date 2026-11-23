# Bolt Plan

Nguồn: requirements.md (FR/NFR), components.md (domain design), unit-of-work.md và unit-of-work-dependency.md (units generation, DAG không có cạnh nào), unit-of-work-story-map.md, stories.md.

Một Bolt là một lượt xây dựng một phần công việc, kết thúc bằng thứ chạy được. Kế hoạch có 3 Bolt, mỗi Bolt một unit, làm lần lượt.

## Bolt 1: u1-app-shell (walking skeleton)
- **Unit:** U1 `u1-app-shell`. Walking skeleton là một bản mỏng chạy xuyên suốt, xây trước để chứng minh các phần ghép được.
- **Definition of Done:** app tên "Block Jewel"; chỉ một màn splash thấy được (Android dưới 12 và iOS); nền khởi động `#0F0C29`; `flutter_native_splash` đã gỡ; mở app, bấm PLAY, chơi 1 level (mốc điểm từ Remote Config hoặc fallback), thắng thì sang level kế, tiến trình được lưu; test cũ nhắc 'BLOCK CRUSH' đã cập nhật; `flutter analyze` sạch và `flutter test` pass.
- **Confidence hypothesis:** nếu app đổi tên và khởi động mà vẫn chơi được đến hết 1 level, nền tảng ổn để thêm hai tính năng còn lại.
- **Expected demo:** mở app trên thiết bị, thấy một splash rồi Home "Block Jewel", chơi thắng 1 level.

## Bolt 2: u3-tray-algorithm
- **Unit:** U3 `u3-tray-algorithm` (rủi ro lớn nhất: cân bằng độ khó).
- **Definition of Done:** `TrayGenerator`, `DifficultyProfile` hoạt động trong Journey và Endless (level 18); mọi story US4.1–US4.6 có test; test thuộc tính trên nhiều seed cho thấy khay luôn có nước đi khi bảng còn ô trống; coverage dòng của phần mới đạt ít nhất 80%.
- **Confidence hypothesis:** người chơi không còn thua vì ba khối đều không đặt vừa khi bảng chưa đầy, và level 36 khó hơn level 1 theo số liệu test.
- **Expected demo:** chơi vài ván ở level 1 và level 36, so sánh cảm giác; log hoặc test thống kê tỉ lệ khối.

## Bolt 3: u2-victory-share
- **Unit:** U2 `u2-victory-share`.
- **Definition of Done:** nút SHARE ở 3 biến thể Victory; ảnh chụp toàn màn hình mở khung chia sẻ với văn bản "Block Jewel"; lỗi chia sẻ chỉ ghi log; widget test dùng `ScoreShareService` giả; Game Over share vẫn hoạt động.
- **Confidence hypothesis:** ảnh chia sẻ đầy đủ bảng và overlay trên thiết bị thật, không làm hỏng CONTINUE.
- **Expected demo:** thắng level con, level mở khóa gem và level 36 rồi bấm SHARE.

## Kiểm tra thứ tự theo DAG
DAG không có cạnh nào, nên mọi thứ tự đều hợp lệ; không có chỗ nào lệch thứ tự topo.
