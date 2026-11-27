# Phác thảo giao diện: Quảng cáo và Remote Config

Nguồn: `intent-statement.md`, `scope-document.md`, `intent-backlog.md` và `rough-mockups-questions.md`. Đây là bản phác thảo mức thấp, chưa phải thiết kế cuối. Mọi chuỗi hiển thị trên giao diện chỉ dùng tiếng Anh, nên các nhãn trong sơ đồ là chữ hiển thị thật. Thiết bị mục tiêu là điện thoại hướng dọc. (Q7)

## Màn 1: Màn chơi có banner

Banner nằm dưới cùng màn chơi (Q1). Banner chỉ hiện từ lần vào thứ N, và ẩn hẳn không chừa khoảng trống khi quảng cáo không tải được. (Q1, Q6, `scope-document.md` hạng mục 1)

```
+----------------------------------+
|  Level 3              [Pause]    |
+----------------------------------+
|                                  |
|         +--------------+         |
|         |  Game board  |         |
|         |              |         |
|         +--------------+         |
|                                  |
|     [block] [block] [block]      |
|                                  |
+----------------------------------+
|            BANNER AD             |
+----------------------------------+
```

Ghi chú trợ năng: tiêu đề h1 là tên level, vùng chính là bàn cờ, điểm vào bàn phím là nút Pause. (Q8: chưa có yêu cầu riêng)

## Màn 2: Lớp phủ khi thua có nút reward ads

Nút xem reward ads nằm trong lớp phủ khi thua, cạnh các lựa chọn hiện có. Nút chỉ hiện khi cờ bật trên Firebase và quảng cáo đã sẵn sàng. (Q2, Q6, `scope-document.md` hạng mục 2)

```
+----------------------------------+
|                                  |
|          Game Over               |
|                                  |
|   +--------------------------+   |
|   |  Watch ad to try again   |   |
|   +--------------------------+   |
|   +--------------------------+   |
|   |        Retry             |   |
|   +--------------------------+   |
|   +--------------------------+   |
|   |        Home              |   |
|   +--------------------------+   |
|                                  |
+----------------------------------+
```

Chỉ các nhãn "Watch ad to try again" là phác thảo cho nút mới. Các nút "Retry" và "Home" ở đây chỉ minh họa vị trí tương đối với các lựa chọn hiện có và cần đối chiếu với `game_over_overlay.dart` ở bước thiết kế. (Q2)

Sau khi xem xong quảng cáo, người chơi bắt đầu lại level hiện tại từ đầu thay vì về Rough Stone. (Q3)

Ghi chú trợ năng: tiêu đề h1 là "Game Over", vùng chính là danh sách nút, điểm vào bàn phím là nút "Watch ad to try again". (Q8)

## Màn 3: Popup cập nhật trên màn Home

Popup tùy chọn, hiện khi vào màn Home, có hai nút. (Q4, Q5, `scope-document.md` hạng mục 5)

```
+----------------------------------+
|             Home                 |
|     +----------------------+     |
|     |   Update available   |     |
|     |                      |     |
|     |  A new version is    |     |
|     |  ready to download.  |     |
|     |                      |     |
|     |  [Update]  [Later]   |     |
|     +----------------------+     |
|            [PLAY]                |
+----------------------------------+
```

Nút Update mở trang cửa hàng theo `android_url` hoặc `ios_url`. Nút Later đóng popup. (Q4, `scope-document.md` hạng mục 5)

Ghi chú trợ năng: tiêu đề h2 là "Update available", vùng chính là hộp thoại, điểm vào bàn phím là nút Update. (Q8)

## Màn 4: Nội dung chia sẻ

Nội dung chia sẻ có thêm link cửa hàng lấy từ `android_url` hoặc `ios_url`. Đây là văn bản, không thêm màn hình mới. (`scope-document.md` hạng mục 6)

```
Share text (English):
"I cleared level 3 in Block Blast! Play here: <store link>"
```

Câu chữ trên chỉ là ví dụ minh họa vị trí của link. Câu chữ thật của nội dung chia sẻ hiện tại cần giữ theo mã nguồn và được xác nhận ở bước sau.

## Assumptions & Open Questions

None.
