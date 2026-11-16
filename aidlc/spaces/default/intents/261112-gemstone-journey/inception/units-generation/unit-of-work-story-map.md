# Unit ↔ Story Map — Gemstone Journey

## Sources

- [stories] `inception/user-stories/stories.md` (40 story)
- `unit-of-work.md`

## Story → Unit

| Story | Unit ID | Directory | Ghi chú |
|-------|---------|-----------|---------|
| US1.1 | U1 | u1-journey-skeleton | level 1 mặc định, dữ liệu hỏng thì dùng mặc định |
| US1.2 | U1 | u1-journey-skeleton | next level, test đủ 36 level |
| US1.3 | U2 | u2-level-rules | mở khóa gem |
| US1.4 | U2 | u2-level-rules | thua thì reset về Rough Stone |
| US1.5 | U2 | u2-level-rules | |
| US1.6 | U1 | u1-journey-skeleton | lưu trước Victory (ADR-008) |
| US1.7 | U2 | u2-level-rules | high score theo level |
| US2.1 | U1 | u1-journey-skeleton | gỡ Time Attack |
| US2.2 | U1 | u1-journey-skeleton | TurnResolver |
| US2.3 | U1 | u1-journey-skeleton | thắng ngay khi đạt target |
| US2.4 | U1 | u1-journey-skeleton | header có target và % |
| US2.5 | U2 | u2-level-rules | QuitDialog |
| US2.6 | U2 | u2-level-rules | Game Over mới |
| US2.7 | U2 | u2-level-rules | giữ SHARE |
| US3.1 | U3 | u3-victory-audio | |
| US3.2 | U3 | u3-victory-audio | |
| US3.3 | U3 | u3-victory-audio | |
| US3.4 | U3 | u3-victory-audio | |
| US4.1 | U6 | u6-endless-mode | |
| US4.2 | U6 | u6-endless-mode | |
| US4.3 | U6 | u6-endless-mode | |
| US4.4 | U6 | u6-endless-mode | |
| US5.1 | U1 | u1-journey-skeleton | Home tối giản. U4 hoàn thiện giao diện |
| US5.2 | U4 | u4-visual-theme | bỏ Daily Gift |
| US5.3 | U3 | u3-victory-audio | mute được lưu |
| US5.4 | U4 | u4-visual-theme | GemTheme |
| US6.1 | U1 | u1-journey-skeleton | Remote Config và fallback |
| US6.2 | U1 | u1-journey-skeleton | cache hỏng |
| US6.3 | U5 | u5-analytics | |
| US6.4 | U5 | u5-analytics | |
| US7.1 | U4 | u4-visual-theme | |
| US7.2 | U4 | u4-visual-theme | |
| US7.3 | U4 | u4-visual-theme | |
| US7.4 | U4 | u4-visual-theme | offline đầy đủ (config phần U1, ảnh và font phần U4) |
| US8.1 | U1 | u1-journey-skeleton | đổi package Android |
| US8.2 | U1 | u1-journey-skeleton | đổi bundle iOS |
| US8.3 | U3 | u3-victory-audio | asset âm thanh. Khai báo `assets/design` ở U4 |
| US8.4 | U1 | u1-journey-skeleton | Firebase không hardcode secret |
| US8.5 | U1 | u1-journey-skeleton | Thực hiện qua DoD-1/DoD-2/DoD-4/DoD-5 ở **mọi unit**. U1 sửa test hỏng và lập nền tảng test. Mốc coverage toàn codebase đo ở Build & Test, phần code cũ do U4 phụ trách |
| US8.6 | U4 | u4-visual-theme | Thực hiện qua DoD-3 (tiếng Anh, 48dp) ở **mọi unit**. U4 làm portrait, font và tương phản |

## Story xuyên unit

| Story | Unit liên quan |
|-------|----------------|
| US5.1 | U1 (chức năng), U4 (giao diện), U6 (State C) |
| US7.4 | U1 (config offline), U4 (ảnh và font offline) |
| US8.3 | U3 (âm thanh), U4 (khai báo `assets/design`) |
| US8.5 | Mọi unit (DoD coverage) |
| US8.6 | Mọi unit (tiếng Anh, 48dp), U4 (portrait, tương phản) |

## Thứ tự trong từng unit

- **U1:** US8.1 → US8.2 → US8.4 → US6.1 → US6.2 → US2.1 → US2.2 → US1.1 → US2.3 → US1.6 → US1.2 → US2.4 → US5.1 → US8.5
- **U2:** US1.4 → US1.5 → US1.3 → US1.7 → US2.5 → US2.6 → US2.7
- **U3:** US5.3 → US8.3 → US3.1 → US3.2 → US3.3 → US3.4
- **U4:** US5.4 → US7.1 → US7.2 → US7.3 → US7.4 → US5.2 → US8.6
- **U5:** US6.3 → US6.4
- **U6:** US4.1 → US4.2 → US4.3 → US4.4

## Kiểm tra coverage

- Có đủ 40/40 story, mỗi story có đúng một unit chính.
- Unit nào cũng có story: U1 14, U2 7, U3 6, U4 7, U5 2, U6 4.
