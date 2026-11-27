# Mockups chi tiết: Quảng cáo và Remote Config

Nguồn: `wireframes.md`, `user-flow.md`, `stories.md`, `requirements.md`, `team-practices.md` và `refined-mockups-questions.md`. Mọi chuỗi giao diện chỉ dùng tiếng Anh. Thiết bị là điện thoại hướng dọc.

## Thay đổi so với phác thảo và yêu cầu đã duyệt

- **Reward ads**: sau khi xem xong (hoặc khi không có quảng cáo), điểm về 0, các ô được xóa sạch, khay khối mới và người chơi chơi tiếp ở chính level đó. Cách này thay cho ghi chú "bắt đầu lại level từ đầu" trong `wireframes.md` và `user-flow.md`. (Q4 của approval-handoff)
- **Nút reward luôn hiện khi cờ bật**: nút hiện khi `reward_enabled` là true. Quảng cáo được tải trước, và nếu bấm mà không có quảng cáo thì thưởng ngay không cần xem. Điều này thay thế yêu cầu ẩn nút khi quảng cáo chưa sẵn sàng trong FR3.1 và AC3.1.2, cần cập nhật lại `requirements.md` và `stories.md` ở bước sau. (Q6, Q8)
- **Banner thích ứng**: banner thích ứng theo chiều rộng màn hình thay vì cỡ chuẩn 50dp. (Q5)

## Màn M1: Màn chơi có banner (US4.1)

```
+----------------------------------+
|  <  Level 3              [Pause] |
|           COMBO x2               |
|                                  |
|        +----------------+        |
|        |  Game board    |        |
|        |  8 x 8         |        |
|        +----------------+        |
|                                  |
|    [block]  [block]  [block]     |
|                                  |
+----------------------------------+
|     BANNER AD (adaptive)         |
+----------------------------------+
```

Banner nằm dưới cùng trong vùng an toàn, với dải nền tối cùng màu giao diện phía sau. Chiều cao do quảng cáo quyết định theo chiều rộng màn hình, và bố cục phía trên co lại để không bị che. Khi banner không tải được, dải này ẩn hẳn và bố cục trở về như không có banner. (Q5, AC4.1.5, AC4.1.6)

## Màn M2: Lớp phủ Game Over có nút reward (US3.1)

```
+----------------------------------+
|                                  |
|            GAME OVER             |
|       FINAL SCORE: 840           |
|          Target: 1000            |
|                                  |
|        You will return to        |
|          Rough Stone             |
|  Watch an ad to stay on this     |
|             level               |
|                                  |
|   +--------------------------+   |
|   | [>] WATCH AD TO TRY AGAIN|   |   nút chính
|   +--------------------------+   |
|   +--------------------------+   |
|   | [R] PLAY AGAIN           |   |   nút phụ
|   +--------------------------+   |
|   +--------------------------+   |
|   | [S] SHARE SCORE          |   |
|   +--------------------------+   |
|          BACK TO MENU            |
+----------------------------------+
```

- Nút WATCH AD TO TRY AGAIN là nút chính (`GemPrimaryButton`) ở trên cùng. PLAY AGAIN chuyển xuống thành nút phụ (`OverlayButton`). (Q1, Q2)
- Dòng nhỏ "Watch an ad to stay on this level" chỉ hiện khi nút reward hiện, bên dưới dòng "You will return to <level>". (Q3)
- Nút reward chỉ có ở chế độ Journey, và hiện khi `reward_enabled` là true và người chơi chưa dùng reward ở ván thua này. Ở Endless, lớp phủ giữ nguyên như hiện tại, không có nút reward và không có dòng "You will return to". (Q6 và Q3 của requirements-analysis, `game_over_overlay.dart`)

## Màn M3: Popup cập nhật trên Home (US5.1)

```
+----------------------------------+
|              Home                |
|                                  |
|    +------------------------+    |
|    |  Update available      |    |
|    |                        |    |
|    |  A new version of      |    |
|    |  Block Jewel is ready. |    |
|    |                        |    |
|    |   [LATER]   [UPDATE]   |    |
|    +------------------------+    |
|                                  |
|             [PLAY]               |
+----------------------------------+
```

Popup dùng mẫu `QuitDialog` (nền `0xFF1C1C2E`, tiêu đề `AppTypography.title()`). Nút LATER bên trái là nút chữ, nút UPDATE bên phải là nút chính. (Q4)

## Trạng thái của các thành phần mới

| Thành phần | Trạng thái | Giao diện |
|-----------|-----------|-----------|
| Banner | chưa tải | Không hiện, bố cục như không có banner |
| Banner | đã tải | Hiện dải banner cao theo chiều rộng màn hình |
| Banner | lỗi | Không hiện, không thông báo lỗi |
| Nút reward | mặc định | Nút chính với nhãn WATCH AD TO TRY AGAIN |
| Nút reward | quảng cáo không có khi bấm | Người chơi nhận thưởng ngay không cần xem (Q6, Q8) |
| Nút reward | cờ tắt hoặc đã dùng ở ván này | Không hiện |
| Popup cập nhật | hiện | Hộp thoại M3 |
| Popup cập nhật | không cần cập nhật, hoặc đường dẫn không hợp lệ | Không hiện |

Không có trạng thái chờ riêng cho nút reward: bạn chọn tải quảng cáo trước, và khi bấm mà có quảng cáo thì quảng cáo hiện, không có thì thưởng ngay. (Q6, Q8)

## Assumptions & Open Questions

None.
