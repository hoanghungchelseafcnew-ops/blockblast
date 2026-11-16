# Bolt Plan — Gemstone Journey

## Sources

- [units] `inception/units-generation/unit-of-work.md`, `unit-of-work-dependency.md`, `unit-of-work-story-map.md`
- [contract] `inception/contract-design/contract-summary.md`
- [prac] `inception/practices-discovery/team-practices.md`: luôn làm walking skeleton trước, không dùng git, test-after, người dùng tự build/test
- [Q1]–[Q4] `delivery-planning-questions.md`

Một **Bolt** là một lượt xây dựng (thiết kế + sinh code) trên một phần công việc, kết thúc bằng một bản build chạy được để người dùng kiểm tra. Kế hoạch có **6 Bolt, mỗi Bolt gồm một unit** [Q2]. Thứ tự **ưu tiên giá trị** [Q1]. Các Bolt chạy **tuần tự, đi trọn từng unit** [Q3], và **dừng chờ duyệt ở mỗi checkpoint** [Q4].

| # | Bolt | Unit | Skeleton | Phụ thuộc |
|---|------|------|----------|-----------|
| 1 | B1 Journey skeleton | U1 `u1-journey-skeleton` | ✅ walking skeleton | — |
| 2 | B2 Level rules | U2 `u2-level-rules` | | B1 |
| 3 | B3 Victory & audio | U3 `u3-victory-audio` | | B2 |
| 4 | B4 Visual theme | U4 `u4-visual-theme` | | B1 |
| 5 | B5 Analytics | U5 `u5-analytics` | | B1, B2 |
| 6 | B6 Endless mode | U6 `u6-endless-mode` | | B2 |

Thứ tự này khớp với DAG: mỗi Bolt đứng sau các Bolt mà nó phụ thuộc. Không có chỗ nào lệch thứ tự topo.

Mọi Bolt đều phải đạt Definition of Done chung DoD-1..DoD-5 (`unit-of-work.md`): unit test, coverage ≥ 80% cho file mới/sửa, UI tiếng Anh, vùng chạm ≥ 48dp, không nuốt lỗi, `flutter analyze` sạch. Người dùng chạy kiểm tra và dán kết quả lại vào chat.

---

## B1 — Journey skeleton (U1) · WALKING SKELETON

**Walking skeleton** là phiên bản tối giản chạy xuyên suốt toàn bộ luồng, làm đầu tiên để chứng minh các phần ghép được với nhau.

- **Tiền điều kiện (người dùng, chặn B1)**: checklist trong `unit-of-work.md` U1 (zip sao lưu, Firebase project, `google-services.json`, Remote Config `level_config`).
- **Thứ tự bên trong**: bốn bước như trong `unit-of-work.md`. Sau mỗi bước người dùng build thử.
  1. Đổi package và `Firebase.initializeApp`.
  2. Sao lưu lần 2, tách `BoardEngine`, gỡ Time Attack.
  3. Config, Catalog, Bootstrap.
  4. Repository, Journey, LevelGame và UI tối giản.
- **Kiến trúc được chứng minh**:
  - Đổi package và Firebase hoạt động trên Android.
  - Đường Remote Config → validate → fallback.
  - `AppBootstrap` → `LevelCatalog`.
  - Vòng `LevelGameController` playing → resolving → won (ADR-008).
  - `ProgressRepository` ghi tuần tự (ADR-009).
  - Refactor `_GameScreenState` (ADR-001) không làm hỏng gameplay.
- **Definition of Done**:
  - DoD chung.
  - `flutter build apk --debug` (hoặc appbundle) thành công với `com.h2.game.block_blast`.
  - Bốn ca end-to-end bên dưới đạt.
- **Demo mong đợi**: mở app → (splash) → Home "Rose Quartz · Rough Stone" → PLAY → chơi đến 500 điểm → "Level Complete!" → CONTINUE → header "Rose Quartz · Slabbing 0 / 800" → kill app → mở lại → Home hiển thị "Rose Quartz · Slabbing".
- **Kiểm chứng end-to-end thật** (người dùng chạy trên máy có Flutter):
  1. `flutter analyze` và `flutter test` xanh.
  2. Bật chế độ máy bay ở lần mở đầu tiên: target level 1 = 500 (mặc định trong app), log `config_source=default`.
  3. Online, đổi `target_score` của Rough Stone trên Remote Config (ví dụ 300), mở lại app sau khi fetch: target = 300, log `config_source=remote`.
  4. Thắng level 1 → level 2. Kill app rồi mở lại vẫn ở level 2.
- **Confidence hypothesis**: "Có thể tách logic khỏi `_GameScreenState` mà gameplay không đổi, và chuỗi Firebase → config → level → lưu tiến trình chạy được trên thiết bị thật."
- **iOS**: nếu chưa có Mac thì hoãn sang Build & Test. B1 vẫn tính hoàn thành theo Android.

## B2 — Level rules (U2)

- **Definition of Done**:
  - DoD chung.
  - Unit test cho đủ 36 lần chuyển level, cho thua ở Amethyst·Shaping và ở Amethyst·Rough Stone, và cho high score.
  - Widget test cho QuitDialog (Back của hệ thống) và Game Over (không có REVIVE).
- **Demo mong đợi**: thua ở Amethyst · Shaping → "You will return to Amethyst · Rough Stone" → PLAY AGAIN vào Rough Stone. Bấm Back giữa ván → "Quit this level?" → CANCEL chơi tiếp, QUIT về Home với level không đổi.
- **Confidence hypothesis**: "Quy tắc thua/mở khóa đúng với FR2 và không làm hỏng tiến trình đã lưu (dirty-key recovery hoạt động)."

## B3 — Victory & audio (U3)

- **Definition of Done**:
  - DoD chung.
  - Widget test cho 3 biến thể Victory (có hoặc không có CONTINUE, khóa sau lần bấm đầu tiên) và reduced motion.
  - Unit test mute cho 6 âm thanh và mute được giữ qua lần khởi động lại.
- **Demo mong đợi**: thắng một level con → confetti, glow, âm thanh. Bấm CONTINUE ngay thì hiệu ứng và âm thanh dừng. Thắng Bling → animation đá quý 2D và "🎉 <Gem> Unlocked!". Tắt âm thanh trong Settings rồi khởi động lại → vẫn tắt.
- **Confidence hypothesis**: "Màn ăn mừng tạo cảm giác tiến bộ mà không làm chậm người chơi hoặc rớt khung hình."

## B4 — Visual theme (U4)

- **Tiền điều kiện (người dùng)**: upload 36 ảnh lên Storage theo `bg/<gemId>/<subOrder>.jpg`, bật quyền đọc công khai cho `bg/` và không cho ghi. Thêm `background_url` vào JSON Remote Config (không bắt buộc, vì đã có ảnh trong assets).
- **Definition of Done**:
  - DoD chung.
  - Gỡ `ThemeManager` và `victory_colors.dart`. Phần code cũ không thuộc unit nào được test hoặc gỡ (theo R-05 của Units Generation).
  - Font đóng gói sẵn, khóa portrait.
  - Checklist tương phản A1–A14 đạt.
  - Khuyến nghị nén `assets/design` xuống ≤ 10MB.
- **Demo mong đợi**: Home có nền ảnh level hiện tại và màu đá quý. Trong ván, nền mờ có lớp phủ tối. Chế độ máy bay vẫn có ảnh từ assets và đúng font. Có mạng thì cross-fade sang ảnh Storage.
- **Confidence hypothesis**: "Mỗi đá quý có bản sắc riêng, và ảnh nền/ font hoạt động cả khi offline."

## B5 — Analytics (U5)

- **Tiền điều kiện**: chốt tên event `game_session` (R-06 của Contract Design).
- **Definition of Done**:
  - DoD chung.
  - Unit test với fake analytics cho đủ 4 event và các user property (`current_major_level`, `highest_level_reached`, `config_source`).
  - Người dùng thấy event trên DebugView.
- **Demo mong đợi**: chơi 1 level trên debug build và thấy `level_start` → `level_complete` trên DebugView. Đưa app vào nền thì thấy `game_session`.
- **Confidence hypothesis**: "Đo được session time, retention và tỉ lệ qua từng level, tức các chỉ số thành công của intent."

## B6 — Endless mode (U6)

- **Definition of Done**:
  - DoD chung.
  - Unit test cho: lưu điểm khi QUIT hoặc paused, khôi phục trên bảng trống, thua thì về 0, cập nhật BEST.
  - Widget test cho header, Quit dialog và Game Over của endless.
- **Demo mong đợi**: đặt `journey_completed` (bằng debug hoặc chơi hết) → Home "Journey Complete · Endless · Best —" → PLAY → đạt 1.200 → QUIT → PLAY lại thì SCORE 1.200 trên bảng trống → thua → PLAY thì SCORE 0.
- **Confidence hypothesis**: "Người chơi đã hoàn thành hành trình vẫn có lý do quay lại chơi."

## Construction settings

| Thiết lập | Giá trị | Nguồn |
|-----------|---------|-------|
| Construction Checkpoints | enabled | state |
| Construction Iteration | unit-major | [Q3], giữ nguyên |
| Construction Execution | serial | không có git, swarm không khả dụng |
| Unit ownership | solo (một phiên) | team ownership cần git |
| Completion approval | gated (dừng chờ duyệt ở mỗi checkpoint) | [Q4] |
| Verification command | hỏi riêng ở cuối stage này | — |

## Assumptions & Open Questions

- [assumption] Người dùng có máy cài Flutter để chạy lệnh kiểm chứng và gửi lại kết quả. Máy chạy AI không có `flutter` trên PATH.
