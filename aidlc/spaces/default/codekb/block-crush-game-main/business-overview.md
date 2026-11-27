# Business Overview

## Mục đích
Game puzzle xếp khối trên mobile (Flutter). Người chơi kéo thả khối vào lưới 8×8 để lấp đầy và xóa hàng hoặc cột, ghi điểm và tạo combo.

## Chức năng chính
- **Journey**: 36 level, chia thành 6 gem (level lớn) × 6 level con. Mỗi level có mốc điểm (target) lấy từ Firebase Remote Config, có bản mặc định khi không tải được.
- **Endless**: chơi không có mốc điểm, lưu điểm cao.
- **Victory**: màn thắng có 3 biến thể (level con, mở khóa gem, hoàn thành hành trình).
- **Game Over**: hiện điểm, nút PLAY AGAIN, SHARE SCORE, BACK TO MENU, và dòng "You will return to <tên level>" (chế độ journey). Khi thua, tiến trình được lưu ngay về level đầu của viên đá hiện tại, trước khi lớp phủ hiện.
- Khối đặc biệt: băng (cần phá 2 lần) và bom (nổ vùng 3×3).
- Tiến trình lưu cục bộ bằng SharedPreferences; có analytics và âm thanh.

## Tên sản phẩm hiện tại
"Block Jewel" (tên hiển thị trong `MaterialApp.title`, Android label và iOS `CFBundleDisplayName`), package `block_blast`. Tên cũ "Block Crush" còn xuất hiện trong lần quét trước và không còn trong mã nguồn đã quét lần này.

## Giới hạn
Chuỗi UI chỉ tiếng Anh. Một người phát triển, build và phát hành thủ công.

## Bối cảnh cho intent 261125-ads-remote-config (quét tập trung)
- Game hiện **chưa có quảng cáo** và Remote Config chỉ dùng khóa `level_config`. Intent này thêm quảng cáo (banner, reward, interstitial, thứ tự mạng `ads_priority`) và các tham số phiên bản và link cửa hàng (`android_version`, `android_url`, `ios_version`, `ios_url`).
- Điểm chạm trong game: bấm PLAY ở Home (đếm lượt Start), màn chơi (banner), lớp phủ Game Over (nút reward), `ScoreShareService` (link trong nội dung chia sẻ), và Home (popup cập nhật).
