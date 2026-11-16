# Interaction Specification — Gemstone Journey

## Sources

- [mock] `mockups.md` (M-0..M-5a)
- [stories] `inception/user-stories/stories.md`
- [req] `inception/requirements-analysis/requirements.md`
- [Q1]–[Q7] `refined-mockups-questions.md`
- Template: `.kiro/knowledge/aidlc-design-agent/component-spec-template.md` (dòng breakpoint thay bằng "phone portrait only", vì NFR8 chỉ hỗ trợ điện thoại màn hình dọc)

## Navigation & transitions

| Từ | Sự kiện | Đến | Transition |
|----|---------|-----|-----------|
| M-0 | fetch xong hoặc hết 2 giây | M-1 | fade 300ms `easeInOut` [Q7] |
| M-1 | PLAY | M-2 (hoặc M-2e nếu `journey_completed`) | fade-through 400ms |
| M-2 | ← hoặc Back của hệ thống | M-2a (dialog) | scale 0.9→1 + fade 300ms |
| M-2a | QUIT | M-1 | pop 300ms |
| M-2 | score ≥ target, level con 1–5 | M-4 | fade 400ms sau animation xóa dòng |
| M-2 | score ≥ target, Bling 1–5 | M-5 | fade 400ms |
| M-2 | score ≥ target, level 36 | M-5a | fade 500ms |
| M-2 | không còn nước đi | M-3 (overlay) | blur 5 + fade/scale như hiện tại |
| M-3 | PLAY AGAIN | M-2 (Rough Stone) | crossfade 300ms |
| M-3 / M-5a | BACK TO MENU | M-1 | pop 300ms |
| M-4 / M-5 | CONTINUE | M-2 (level kế tiếp) | fade 400ms [Q1] |

Mọi transition dùng `Curves.easeInOut` và thời lượng 300–500ms. [req FR6.4]

---

## LevelProgressBar

| Field | Value |
|---|---|
| Component | LevelProgressBar |
| Description | Hiển thị tiến độ điểm so với mốc của level |
| Category | feedback |

### States

| State | Description | Trigger |
|---|---|---|
| default | Fill = floor(score/target×100)%, tối đa 99% khi chưa đạt | điểm thay đổi |
| complete | Fill 100%, nhãn "100%" | score ≥ target (chỉ thoáng qua trước khi sang Victory) |
| hidden | Không render | chế độ endless |

### Props / Inputs

| Prop | Type | Required | Default | Description |
|---|---|---|---|---|
| score | int | yes | — | điểm hiện tại |
| target | int | yes | — | mốc của level (> 0) |
| color | Color | yes | — | `gemPrimary` |

### Responsive Behaviour

| Breakpoint | Behaviour |
|---|---|
| phone portrait | Rộng bằng header trừ padding 20dp, cao 8dp |

### Accessibility

| Requirement | Implementation |
|---|---|
| ARIA role | `Semantics(value: '67 percent')` dạng progress |
| Keyboard interaction | Không tương tác |
| Label / aria-label | "Progress to target: 2,850 of 4,200 points, 67 percent" |
| Contrast ratio | Viền trắng 1.5dp đảm bảo ≥ 3:1 với nền tối cho mọi đá quý |
| Screen reader | Đọc khi focus vào header. Không thông báo liên tục |
| Focus management | — |

Animation: fill tween 250ms `easeOut` mỗi khi điểm đổi.

---

## VictoryScreen (M-4 / M-5 / M-5a)

| Field | Value |
|---|---|
| Component | VictoryScreen |
| Description | Ăn mừng khi hoàn thành level con, đá quý hoặc toàn bộ hành trình |
| Category | feedback |

### States

| State | Description | Trigger |
|---|---|---|
| celebrating | Confetti, glow và âm thanh đang chạy (2–3 giây). CONTINUE đã hiện và bấm được | vào màn hình |
| idle | Hiệu ứng đã xong, glow pulse nhẹ lặp lại | sau 3 giây |
| leaving | CONTINUE bị khóa. Dừng confetti, glow và âm thanh, fade-out | bấm CONTINUE lần đầu [Q1] |
| final (M-5a) | Không có CONTINUE, chỉ có BACK TO MENU | level 36 |

### Props / Inputs

| Prop | Type | Required | Default | Description |
|---|---|---|---|---|
| variant | enum `sub \| gemUnlock \| journeyComplete` | yes | — | quyết định nội dung |
| level | LevelRef (gem, sub, index) | yes | — | |
| score / target / best | int | yes | — | |
| background | ImageProvider | yes | — | ảnh rõ nét |
| onContinue | VoidCallback? | no | null | null khi `journeyComplete` |
| onBackToMenu | VoidCallback? | no | null | chỉ dùng cho `journeyComplete` |

### Responsive Behaviour

| Breakpoint | Behaviour |
|---|---|
| phone portrait | Ảnh vuông rộng 85% màn hình. Nút dính đáy với SafeArea |

### Accessibility

| Requirement | Implementation |
|---|---|
| ARIA role | Màn hình, `Semantics(header: true)` cho tiêu đề |
| Keyboard interaction | Enter/Space trên CONTINUE |
| Label / aria-label | Nút "Continue to <next level>" |
| Contrast ratio | Chữ trắng trên lớp phủ gradient tối ≥ 4.5:1 |
| Screen reader | Đọc "Level Complete! Shaping completed. 4,350 of 4,200 points." |
| Focus management | Focus vào CONTINUE (hoặc BACK TO MENU) khi mở |

**Ngắt hiệu ứng (góp ý R-01):** khi bấm CONTINUE, hệ thống gọi `AnimationController.stop()` cho confetti và glow, `AudioController.stopSfx()`, đặt cờ `_leaving = true` để bỏ qua mọi lần bấm sau, rồi điều hướng. Tiến trình đã được lưu **trước khi** VictoryScreen mở (US1.6), nên việc ngắt không ảnh hưởng dữ liệu. [Q1] [stories US1.6, US3.1]

Âm thanh: `victory` phát khi mở màn. Với `gemUnlock` và `journeyComplete`, `unlock` phát sau khi `victory` kết thúc (hoặc sau 600ms). Mọi âm thanh đều bỏ qua khi `sound_muted`. [stories US5.3]

Reduced motion: nếu `MediaQuery.disableAnimations` bật thì bỏ confetti và xoay, chỉ giữ fade, chữ vẫn đầy đủ. [stories US3.4]

---

## QuitDialog (M-2a)

| Field | Value |
|---|---|
| Component | QuitDialog |
| Description | Xác nhận thoát ván đang chơi |
| Category | feedback |

### States

| State | Description | Trigger |
|---|---|---|
| default (level) | "Quit this level?" / "Your current score will be lost." | ← hoặc Back khi đang ở M-2 |
| default (endless) | "Quit?" / "Your score will be saved." | ← hoặc Back khi đang ở M-2e |

### Props / Inputs

| Prop | Type | Required | Default | Description |
|---|---|---|---|---|
| mode | enum `level \| endless` | yes | — | |
| onQuit / onCancel | VoidCallback | yes | — | |

### Responsive Behaviour

| Breakpoint | Behaviour |
|---|---|
| phone portrait | Rộng 85%, căn giữa |

### Accessibility

| Requirement | Implementation |
|---|---|
| ARIA role | dialog (`AlertDialog`) |
| Keyboard interaction | Back hoặc Escape = CANCEL |
| Label / aria-label | Tiêu đề là nhãn của dialog |
| Contrast ratio | Chữ trắng trên `#1C1C2E` ≥ 4.5:1 |
| Screen reader | Đọc tiêu đề và nội dung khi mở |
| Focus management | Focus vào CANCEL. Đóng dialog thì focus trả về board |

- Hệ thống: dùng `PopScope(canPop: false, onPopInvoked: showQuitDialog)` cho nút Back và cử chỉ quay lại. Dialog đang mở thì Back đóng dialog (= CANCEL). [stories US2.5]
- Trong lúc dialog mở, kéo-thả khối bị chặn. Ván không có timer nên không cần pause.

---

## LevelBackground

| Field | Value |
|---|---|
| Component | LevelBackground |
| Description | Ảnh nền của level: blur khi chơi, rõ nét ở Victory |
| Category | display |

### States

| State | Description | Trigger |
|---|---|---|
| asset | Hiện ảnh asset ngay | vào level |
| network | Cross-fade 300ms sang ảnh mạng | ảnh mạng đã tải xong [Q3] |
| error | Giữ ảnh asset, ghi log | lỗi tải ảnh mạng |

### Props / Inputs

| Prop | Type | Required | Default | Description |
|---|---|---|---|---|
| level | LevelRef | yes | — | |
| remoteUrl | String? | no | null | từ Remote Config |
| blurred | bool | no | true | false ở Victory |

### Responsive Behaviour

| Breakpoint | Behaviour |
|---|---|
| phone portrait | `BoxFit.cover` toàn màn hình |

### Accessibility

| Requirement | Implementation |
|---|---|
| ARIA role | decorative (`ExcludeSemantics`) |
| Keyboard interaction | — |
| Label / aria-label | — |
| Contrast ratio | Lớp phủ 50% đen giữ tương phản cho board và chữ [Q6] |
| Screen reader | Bỏ qua |
| Focus management | — |

## Trạng thái hệ thống

| Tình huống | Hành vi UI |
|-----------|-----------|
| Offline lần đầu | M-0 hết 2 giây, sang M-1 với config mặc định, ảnh asset và font đóng gói [Q4] [Q7] |
| Config lỗi hoặc hỏng | Không hiện lỗi cho người chơi. Dùng mặc định và ghi log [req FR3.3] |
| Dữ liệu tiến trình hỏng | M-1 ở State B (level 1) [stories US1.1] |
| App vào background ở M-2 (level) | Lưu `total_play_time`. Ván vẫn giữ trong bộ nhớ. Nếu bị kill thì mở lại sẽ ở Home với level đã lưu |
| App vào background ở M-2e | Lưu `endless_saved_score` [stories US4.2] |

## Assumptions & Open Questions

- [assumption] `AudioController` cần thêm `stopSfx()`. Đây là chi tiết triển khai, sẽ chốt ở bước Functional Design.
