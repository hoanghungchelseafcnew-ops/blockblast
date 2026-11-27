# Thành phần giao diện: u4-update-and-share

Nguồn: `functional-spec.md`, `rules.md`, `components.md` (`HomeScreen`), `contract-summary.md` và `unit-of-work.md`. Mọi chuỗi giao diện chỉ dùng tiếng Anh (NFR4).

## UpdatePopup (mới)

```
Dialog (theo màu gem hiện tại của Home)
  Text "Update available"
  Text "A new version of Block Jewel is ready. Update now for the latest fixes and features."
  Row
    TextButton "LATER"        (key update-popup-later)
    GemPrimaryButton "UPDATE" (key update-popup-update)
```

| Thuộc tính | Kiểu | Ý nghĩa |
|-----------|------|---------|
| `palette` | bảng màu gem | Màu nút UPDATE |
| `onUpdate` | callback | Mở cửa hàng (BR8.6) |

Popup đóng được bằng back hay chạm ra ngoài, tính như LATER (BR8.6).

## Thay đổi ở HomeScreen

- Sau khung hình đầu và sau khi luồng đồng ý quảng cáo xong, gọi kiểm tra phiên bản. Có bản mới và popup chưa hiện trong lần mở này thì mở `UpdatePopup` (BR8.4, BR8.5).
- Không mở popup khi Home không còn là màn trên cùng, ví dụ người chơi đã bấm PLAY.

## Nội dung chia sẻ

Không có thành phần giao diện mới. `ScoreShareService` nhận đường dẫn cửa hàng của nền tảng và nối vào cuối văn bản (BR9.1).

## Trợ năng

Nút cao tối thiểu 48 dp (UPDATE 56 dp). Popup có tiêu đề để trình đọc màn hình đọc được.

## Assumptions & Open Questions

None.
