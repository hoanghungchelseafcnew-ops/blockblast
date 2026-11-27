# Thành phần giao diện: u3-banner

Nguồn: `functional-spec.md`, `rules.md`, `components.md` (`GameScreen`), `contract-summary.md` (`BannerResult`) và `unit-of-work.md`. Banner không có chuỗi hiển thị nào của game, nên không thêm chuỗi giao diện mới (NFR4).

## Cấu trúc màn chơi (Journey và Endless)

```
Scaffold
  Stack
    Nền level
    SafeArea
      Column
        Phần đầu (điểm, mốc, thanh tiến độ)
        Vùng chữ combo
        Expanded: bàn cờ và khay khối
        AdBannerSlot                 (mới, cao 0 khi không có banner)
    Lớp phủ Game Over / Victory      (phủ toàn màn hình, kể cả banner)
```

## AdBannerSlot (mới, dùng chung)

| Thuộc tính | Kiểu | Ý nghĩa |
|-----------|------|---------|
| `ads` | dịch vụ quảng cáo | Lấy banner theo hợp đồng 2 |

| Trạng thái | Hiển thị |
|-----------|----------|
| Chưa đủ điều kiện, đang tải, ẩn | Không chiếm chỗ (BR7.4, BR7.5) |
| Đang hiện | Banner rộng bằng màn hình, cao theo banner thích ứng, nằm trong vùng an toàn dưới cùng (BR7.4) |

Hành vi:
- Tự yêu cầu banner khi hiện lần đầu, và một lần nữa khi ứng dụng quay lại từ nền nếu chưa thử (BR7.1, BR7.2).
- Giữ banner suốt lần vào màn chơi, kể cả khi đổi ván; giải phóng khi màn chơi đóng (BR7.7).
- Dùng chung cho `GameScreen` và `EndlessGameScreen` (BR7.8).

## Trợ năng

Banner do SDK vẽ. Vùng banner không đè lên nút hay ô nào của game, nên vùng chạm của game giữ nguyên (AC4.1.6).

## Assumptions & Open Questions

None.
