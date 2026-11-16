# Wireframes — Gemstone Journey (low-fidelity)

## Sources

- [intent] `ideation/intent-capture/intent-statement.md` (người chơi casual mobile, mục tiêu rõ ràng cho mỗi lượt chơi)
- [scope] `ideation/scope-definition/scope-document.md`
- [Q1]–[Q10] `rough-mockups-questions.md` (Q1 đã sửa, Q10 cập nhật theo Requested Changes Feedback)
- [gate] Phản hồi Request Changes của người dùng ở cổng phê duyệt (R-01 đến R-06, ngôn ngữ)
- [code] `lib/features/home/screens/home_screen.dart`, `lib/features/game/screens/game_screen.dart`

## Thay đổi scope

S-07 "Giao diện chọn level" (FR-07) **bị bỏ khỏi đợt này**: không có màn hình chọn level lớn và level con. [Q2] [Q3] [Q8] Scope document đã duyệt vẫn còn ghi S-07, nên thay đổi này cần được phản ánh ở bước Requirements Analysis.

Daily Gift hiện có trên Home **bị bỏ**. [Q10]

Thiết bị hỗ trợ: chỉ điện thoại, màn hình dọc. [Q6]

**Ngôn ngữ giao diện: chỉ tiếng Anh.** Mọi chữ trên màn hình (nút, thông báo, nhãn) đều bằng tiếng Anh. Đợt này không có đa ngôn ngữ. [gate]

## Danh sách màn hình

| ID | Màn hình | Trạng thái | Nguồn |
|----|----------|-----------|-------|
| W-1 | Home | Sửa: 1 nút PLAY, giữ Settings, bỏ Daily Gift | [Q1] [Q10] [gate] |
| W-2 | Game (đang chơi) | Sửa: header theo level, nền blur | [Q4] [scope] |
| W-2a | Exit confirmation dialog | Mới: hỏi xác nhận khi bấm ← hoặc Back của máy | [gate] |
| W-3 | Game Over overlay | Sửa nhẹ: thêm thông báo quay về Rough Stone | [Q5] |
| W-4 | Victory: hoàn thành level con | Mới | [scope] |
| W-5 | Victory: hoàn thành level lớn (unlock đá quý 2D) | Mới | [scope] |
| W-5a | Journey Complete: hoàn thành level 36 | Mới: chúc mừng, không có CONTINUE | [gate] |
| W-6 | Settings | Giữ nguyên | [Q10] [code] |

---

## W-1 Home

```
+--------------------------------+
|                          [⚙️]  |  <- Settings (giữ nguyên)
|                                |
|        BLOCK PUZZLE            |
|      ◆ Gemstone Journey ◆      |
|                                |
|     Amethyst · Shaping         |  <- level hiện tại (từ tiến trình đã lưu)
|                                |
|   +------------------------+   |
|   |        ▶  PLAY         |   |  <- vào thẳng W-2 ở level hiện tại
|   +------------------------+   |
|                                |
+--------------------------------+
```
- Không còn thẻ Classic / Time Attack (S-01: chỉ Classic). [Q1] [scope]
- Không còn popup Daily Gift. [Q10]
- Nhãn nút là **PLAY**. [gate]
- Người chơi mới hoặc chưa có dữ liệu lưu: hiển thị "Rose Quartz · Rough Stone". [Q9]
- Đã hoàn thành level 36: hiển thị "Journey Complete". Bấm PLAY sẽ chơi lại Ruby · Bling. [gate] [assumption]
- **A11y:** h1 = tiêu đề game. Landmark: header (⚙️), main (PLAY). Focus đầu tiên vào nút PLAY. Vùng chạm ≥ 48dp. [Q7]

## W-2 Game (đang chơi)

```
+--------------------------------+
| [←]  Amethyst · Shaping   [⚙️] |
| 2,850 / 4,200                  |
| [██████████░░░░░░░░] 68%       |  <- thanh tiến độ tới mốc điểm
+--------------------------------+
|  ░░ ảnh nền level (blur) ░░░░  |
|  +--------------------------+  |
|  |                          |  |
|  |       GAME BOARD         |  |
|  |      (Classic, 8x8)      |  |
|  |                          |  |
|  +--------------------------+  |
|   [block] [block] [block]      |
+--------------------------------+
```
- Header: tên level, điểm hiện tại / mốc điểm, thanh tiến độ. [Q4]
- Ảnh nền của level con hiển thị blur phía sau board. [scope]
- Đạt mốc điểm thì chuyển sang W-4, sang W-5 nếu là level Bling, hoặc sang W-5a nếu là Ruby · Bling (level 36). [scope] [gate]
- Bấm [←] hoặc nút Back / cử chỉ quay lại của hệ thống sẽ mở W-2a. Không thoát ngay. [gate]
- **A11y:** h1 = tên level. Landmark: header (tiến độ), main (board). Thanh tiến độ có nhãn dạng chữ, không chỉ là thanh màu. [Q7]

## W-2a Exit confirmation dialog

```
+--------------------------------+
|   +------------------------+   |
|   |   Quit this level?     |   |
|   |                        |   |
|   | Your current score     |   |
|   | will be lost.          |   |
|   |                        |   |
|   |  [ CANCEL ]  [ QUIT ]  |   |
|   +------------------------+   |
+--------------------------------+
```
- Mở khi bấm [←] trên header hoặc nút Back / cử chỉ quay lại của hệ thống trong lúc chơi. [gate]
- CANCEL: đóng dialog, chơi tiếp. QUIT: về W-1 Home. [gate]
- [assumption] QUIT bỏ ván đang chơi, không tính là thua. Level đã lưu giữ nguyên.
- **A11y:** h2 = "Quit this level?". Landmark: dialog. Focus đầu tiên vào CANCEL (lựa chọn an toàn). [Q7]

## W-3 Game Over overlay

```
+--------------------------------+
|           GAME OVER            |
|                                |
|     FINAL SCORE: 2,850         |
|     Target: 4,200              |
|                                |
|  You will return to            |
|  Amethyst · Rough Stone        |
|                                |
|   [  ↻ PLAY AGAIN  ]           |
|   [  BACK TO MENU  ]           |
+--------------------------------+
```
- Giữ overlay hiện tại, thêm thông báo quay về Rough Stone của level lớn hiện tại. [Q5] [scope]
- PLAY AGAIN: chơi lại từ Rough Stone của level lớn hiện tại. [gate]
- [assumption] Khi thua, level đã lưu được đặt về Rough Stone ngay. Vì vậy BACK TO MENU rồi bấm PLAY trên Home cũng vào Rough Stone.
- Thua ngay ở Rough Stone: thông báo vẫn hiển thị "You will return to <Gem> · Rough Stone". [gate] [assumption]
- **A11y:** h2 = "GAME OVER". Landmark: main (overlay dạng dialog). Focus đầu tiên vào PLAY AGAIN. [Q7]

## W-4 Victory: hoàn thành level con

```
+--------------------------------+
|  ✦  *  confetti ↑  *   ✦       |
|  +--------------------------+  |
|  |  ẢNH NỀN LEVEL (rõ nét)  |  |
|  |       ~ glow ~           |  |
|  +--------------------------+  |
|       LEVEL COMPLETE!          |
| Congratulations! Shaping       |
|        Completed!              |
|     4,350 / 4,200              |
|   [     CONTINUE  ▶     ]      |
+--------------------------------+
```
- Confetti, glow, âm thanh victory. CONTINUE chuyển sang level con tiếp theo. [scope]
- **A11y:** h1 = "Level Complete!". Landmark: main. Focus đầu tiên vào CONTINUE. Hiệu ứng chỉ mang tính trang trí. [Q7]

## W-5 Victory: hoàn thành level lớn (Bling)

```
+--------------------------------+
|  ✦ sparkle ✦  confetti  ✦      |
|          ◆ (2D, xoay)          |  <- animation unlock đá quý 2D
|      🎉 Amethyst Unlocked!     |
|  +--------------------------+  |
|  |  ẢNH NỀN BLING (rõ nét)  |  |
|  +--------------------------+  |
|     7,200 / 7,000              |
|   [     CONTINUE  ▶     ]      |
+--------------------------------+
```
- Gồm mọi hiệu ứng của W-4, thêm animation unlock đá quý 2D (không dùng 3D) và âm thanh unlock. [scope]
- **A11y:** h1 = "[Tên đá] Unlocked!". Landmark: main. Focus đầu tiên vào CONTINUE. [Q7]

## W-5a Journey Complete (hoàn thành level 36, Ruby · Bling)

```
+--------------------------------+
|  ✦ sparkle ✦  confetti  ✦      |
|        ◆ ◆ ◆ ◆ ◆ ◆             |  <- 6 viên đá đã sưu tập
|    🎉 Ruby Unlocked!           |
|    JOURNEY COMPLETE!           |
| You have collected all 6 gems! |
|     352,000 / 350,000          |
|                                |
|   [     BACK TO MENU     ]     |  <- không có CONTINUE
+--------------------------------+
```
- Gồm mọi hiệu ứng chúc mừng của W-5. **Không hiển thị nút CONTINUE.** [gate]
- [assumption] Dùng một nút BACK TO MENU để về W-1, tránh ngõ cụt.
- **A11y:** h1 = "Journey Complete!". Landmark: main. Focus đầu tiên vào BACK TO MENU. Kết quả được truyền đạt bằng chữ, không chỉ bằng hiệu ứng. [Q7]

## Assumptions & Open Questions

- [assumption] Nút [←] ở W-2 (sau khi QUIT) và BACK TO MENU ở W-3/W-5a đều về W-1 Home.
- [assumption] Kích thước board giữ nguyên như code hiện tại. "8x8" trong wireframe chỉ là minh họa.
- [assumption] Hành vi của Home sau khi hoàn thành level 36 (nhãn "Journey Complete", PLAY chơi lại Ruby · Bling) cần xác nhận ở bước Requirements Analysis.
- [assumption] Không có màn xem bộ sưu tập đá quý. Đây là hệ quả có chủ ý của việc bỏ S-07.
