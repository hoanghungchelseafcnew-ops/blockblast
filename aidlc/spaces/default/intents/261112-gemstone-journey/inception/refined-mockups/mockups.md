# Refined Mockups — Gemstone Journey

## Sources

- [wire] `ideation/rough-mockups/wireframes.md`, `user-flow.md` (W-1..W-6, W-2a, W-5a)
- [stories] `inception/user-stories/stories.md` (US1.x–US8.x)
- [req] `inception/requirements-analysis/requirements.md`
- [prac] `inception/practices-discovery/team-practices.md`: UI chỉ dùng tiếng Anh
- [ds] `design-system-mapping.md`
- [Q1]–[Q7] `refined-mockups-questions.md`

Thiết bị: điện thoại, màn hình dọc, thiết kế cho khung 390×844 logical px. Toàn bộ chuỗi UI bằng tiếng Anh. [req NFR7, NFR8]

---

## M-0 Splash (mới) — US6.1 [Q7]

```
┌──────────────────────────────┐
│                              │
│                              │
│          [ icon.png ]        │
│        BLOCK CRUSH           │  display, Righteous
│     ◆ Gemstone Journey ◆     │  caption, white70
│                              │
│            ● ● ●             │  chỉ báo đang tải
└──────────────────────────────┘
```
- Chờ `fetchAndActivate()` tối đa **2 giây**. Xong hoặc hết thời gian thì sang M-1. Lỗi thì dùng config đã cache hoặc mặc định, không báo lỗi cho người chơi. [Q7] [req FR3.2]
- Nền `#0F0C29` (giống native splash hiện tại).

## M-1 Home — US5.1, US5.2, US5.3, US4.1, US1.1

**State A: đang trong hành trình**
```
┌──────────────────────────────┐
│                         [⚙]  │  48×48dp
│                              │
│         BLOCK                │  display 60
│         CRUSH                │
│     ◆ Gemstone Journey ◆     │
│                              │
│        ◆  (gem 2D)           │  viên đá của level hiện tại, 96dp
│      Emerald · Sanding       │  title
│      Level 22 of 36          │  caption
│                              │
│   ┌──────────────────────┐   │
│   │       ▶  PLAY        │   │  GemPrimaryButton 280×64
│   └──────────────────────┘   │
│                              │
└──────────────────────────────┘
nền: ảnh Emerald·Sanding blur + gradient #228B22→#0F0C29
```
**State B: chưa có dữ liệu lưu.** Nhãn hiển thị "Rose Quartz · Rough Stone" và "Level 1 of 36". [stories US1.1]
**State C: đã hoàn thành hành trình.** Hiển thị 6 viên đá xếp hàng ngang, nhãn "Journey Complete", phụ đề "Endless · Best 12,400". Nút vẫn là PLAY. [stories US4.1]

- Không có Daily Gift và không có thẻ chế độ chơi. [stories US5.2] [wire]

## M-1s Settings sheet — US5.3

```
┌──────────────────────────────┐
│ SETTINGS                     │  headline
│                              │
│ 🔊  Sound Effects     [ ●━ ] │  Switch, lưu `sound_muted`
│                              │
└──────────────────────────────┘
```
- Bỏ phần THEME (Neon/Wood/Jewel). [stories US5.3, US5.4]

## M-2 Game (level) — US2.4, US2.3, US7.1, US1.7

```
┌──────────────────────────────┐
│ [←]  Amethyst · Shaping  BEST│
│                         3,900│  caption
│ 2,850 / 4,200            67% │  body / caption
│ ┃██████████████░░░░░░░░┃     │  LevelProgressBar 8dp, viền trắng 1.5dp
├──────────────────────────────┤
│ ░ ảnh nền blur + phủ 50% ░░░ │
│  ┌────────────────────────┐  │
│  │      BOARD 8×8          │  │  giữ GameBoard hiện có
│  └────────────────────────┘  │
│                              │
│   [block]  [block]  [block]  │
└──────────────────────────────┘
```
- `%` = floor(score / target × 100), giới hạn 0–99 khi score < target. Chỉ hiển thị 100% khi đã đạt mốc. Ví dụ: 2850/4200 = 67,86% hiển thị **67%**. [Q2]
- Nhãn combo ("COMBO x2", "INCREDIBLE!") giữ nguyên ở dưới header. [stories US2.2]
- Ảnh nền: hiện asset ngay. Nếu ảnh mạng về sau thì cross-fade **300ms** sang ảnh mạng. Ảnh của level N+1 được precache trong nền. [Q3] [stories US7.2, US7.3]
- Điểm vừa ≥ target thì chuyển ngay sang M-4 hoặc M-5, ngay sau animation xóa dòng (180ms). [stories US2.3]

## M-2e Game (endless) — US4.4

```
┌──────────────────────────────┐
│ [←]       Endless      BEST  │
│                       12,400 │
│ SCORE  1,200                 │
├──────────────────────────────┤
│ ░ ảnh Ruby·Bling blur ░░░░░░ │
│        BOARD + blocks        │
└──────────────────────────────┘
```
- Không có target, không có thanh tiến độ. [stories US4.1, US4.4]

## M-2a Quit dialog — US2.5, US4.4

```
┌──────────────────────────────┐
│ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ │  scrim đen 60%
│  ┌────────────────────────┐  │
│  │  Quit this level?      │  │  headline 24
│  │  Your current score    │  │  body
│  │  will be lost.         │  │
│  │                        │  │
│  │ [ CANCEL ]   [ QUIT ]  │  │  mỗi nút ≥ 48dp, CANCEL được focus
│  └────────────────────────┘  │
└──────────────────────────────┘
```
- Ở chế độ endless, nội dung đổi thành "Quit? Your score will be saved." [stories US4.4]

## M-3 Game Over (level) — US2.6, US2.7, US1.4

```
┌──────────────────────────────┐
│          🏆                   │
│        GAME OVER             │  headline 44
│    FINAL SCORE  2,850        │
│    Target       4,200        │
│                              │
│  You will return to          │
│  Amethyst · Rough Stone      │  title, màu gemPrimary
│                              │
│  [  ↻  PLAY AGAIN        ]   │  GemPrimaryButton
│  [  ⤴  SHARE SCORE       ]   │  nền blueAccent (giữ)
│       BACK TO MENU           │  SecondaryTextButton
└──────────────────────────────┘
```
- Không có REVIVE. [stories US2.6]
- **M-3e (endless):** hiển thị FINAL SCORE và BEST, không có Target hay thông báo quay về Rough Stone. [stories US4.4]

## M-4 Victory: level con — US3.1, US3.4

```
┌──────────────────────────────┐
│  ✦  ·  ✧  confetti ↑  ·  ✦   │  màu gemPrimary/gemSecondary/white
│ ┌──────────────────────────┐ │
│ │                          │ │
│ │   ẢNH NỀN RÕ NÉT 1:1     │ │  glow gemPrimary, pulse 1.2s
│ │                          │ │
│ └──────────────────────────┘ │
│      Level Complete!         │  headline
│ Congratulations! Shaping     │  body
│        Completed!            │
│    4,350 / 4,200 · BEST 4,350│  caption
│                              │
│  [      CONTINUE  ▶      ]   │  hiện ngay, focus mặc định
└──────────────────────────────┘
```
- CONTINUE hiện và bấm được ngay. Bấm thì dừng confetti, glow và âm thanh victory, rồi chuyển sang M-2 của level kế tiếp. Nút bị khóa sau lần bấm đầu tiên. [Q1] [stories US3.1]

## M-5 Victory: unlock đá quý (Bling 1–5) — US3.2, US1.3

```
┌──────────────────────────────┐
│ ✦ sparkle ✦  confetti  ✦     │
│            ◆                 │  GemUnlockAnimation: scale 0→1,
│        (xoay Y 2D)           │  xoay 360°, shimmer 1.5s
│   🎉 Amethyst Unlocked!       │  headline
│ ┌──────────────────────────┐ │
│ │  ẢNH BLING RÕ NÉT        │ │
│ └──────────────────────────┘ │
│    7,200 / 7,000             │
│  [      CONTINUE  ▶      ]   │  → Blue Topaz · Rough Stone
└──────────────────────────────┘
```
- Âm thanh `unlock.wav` phát sau `victory`, trừ khi đang mute. [stories US3.2]

## M-5a Journey Complete — US3.3

```
┌──────────────────────────────┐
│ ✦ sparkle ✦  confetti  ✦     │
│   ◆   ◆   ◆   ◆   ◆   ◆      │  6 viên đá, lần lượt sáng lên
│    🎉 Ruby Unlocked!          │
│    JOURNEY COMPLETE!         │  display 40
│ You have collected all 6 gems│  body
│    352,000 / 350,000         │
│                              │
│  [     BACK TO MENU      ]   │  GemPrimaryButton, không có CONTINUE
└──────────────────────────────┘
```

## Ma trận story → màn hình

| Màn | Stories |
|-----|---------|
| M-0 | US6.1, US6.2 |
| M-1 / M-1s | US1.1, US4.1, US5.1, US5.2, US5.3, US5.4 |
| M-2 / M-2e | US1.7, US2.2, US2.3, US2.4, US4.2, US4.4, US7.1, US7.2, US7.3 |
| M-2a | US2.5, US4.2, US4.4 |
| M-3 / M-3e | US1.4, US1.5, US2.6, US2.7, US4.3, US4.4 |
| M-4 / M-5 / M-5a | US1.2, US1.3, US1.6, US3.1, US3.2, US3.3, US3.4 |

## Assumptions & Open Questions

- [assumption] Ảnh viên đá 2D cho 6 đá quý (`assets/gemstones/<gem>.png`, theo cấu trúc thư mục đề xuất trong file requirements) chưa có. Có thể dùng placeholder: icon `Icons.diamond` tô màu `gemPrimary`.
- [assumption] Home hiển thị thêm "Level N of 36" như thông tin phụ.
