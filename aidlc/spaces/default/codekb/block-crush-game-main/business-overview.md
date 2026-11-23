# Business Overview

## Mục đích
Game puzzle xếp khối trên mobile (Flutter). Người chơi kéo thả khối vào lưới 8×8 để lấp đầy và xóa hàng hoặc cột, ghi điểm và tạo combo.

## Chức năng chính
- **Journey**: 36 level, chia thành 6 gem (level lớn) × 6 level con. Mỗi level có mốc điểm (target) lấy từ Firebase Remote Config, có bản mặc định khi không tải được.
- **Endless**: chơi không có mốc điểm, lưu điểm cao.
- **Victory**: màn thắng có 3 biến thể (level con, mở khóa gem, hoàn thành hành trình).
- **Game Over**: hiện điểm, nút chia sẻ ảnh chụp, chơi lại hoặc về menu.
- Khối đặc biệt: băng (cần phá 2 lần) và bom (nổ vùng 3×3).
- Tiến trình lưu cục bộ bằng SharedPreferences; có analytics và âm thanh.

## Tên sản phẩm hiện tại
"Block Crush" (tên hiển thị), phụ đề "Gemstone Journey", package `block_blast`.

## Giới hạn
Chuỗi UI chỉ tiếng Anh. Một người phát triển, build và phát hành thủ công.
