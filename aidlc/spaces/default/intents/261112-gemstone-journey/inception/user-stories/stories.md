# User Stories — Gemstone Journey

## Sources

- [req] `inception/requirements-analysis/requirements.md` (FR1–FR14, NFR1–NFR11)
- [wire] `ideation/rough-mockups/wireframes.md`
- [plan] `user-stories-questions.md`: chia theo epic (Q1), có story cho P2 (Q2), mức chi tiết cao (Q3), mọi FR đều là Must (Q4)
- Personas: `personas.md` (P1 Casual Player, P2 Developer/Owner)

Quy ước chung:
- Mọi story có ưu tiên **Must Have**, trừ khi ghi khác. [plan Q4]
- INVEST: mỗi story test độc lập được. Phụ thuộc được ghi rõ ở từng story.
- Kiểm thử: unit test cho logic và controller, widget test cho UI. Người dùng tự chạy (`flutter test`).

---

## Epic 1 — Journey & Progress

### US1.1 Bắt đầu hành trình ở level đầu tiên
As P1, I want a new game to start at Rose Quartz · Rough Stone, so that I begin the journey from the first gem.
- AC1.1.1: Given chưa có dữ liệu lưu, When tôi bấm PLAY, Then level hiện tại là Rose Quartz · Rough Stone (level_index 1) với target 500 (config mặc định).
- AC1.1.2: Given dữ liệu tiến trình bị hỏng hoặc không hợp lệ, When app khởi động, Then app dùng level 1 và không crash.
- Trace: FR2, FR8.3. Phụ thuộc: US6.1.

### US1.2 Thắng level con thì sang level con kế tiếp
As P1, I want reaching the target to move me to the next sub-level, so that I progress through the gem's crafting steps.
- AC1.2.1: Given đang ở level con 1–5 của một đá quý, When tôi thắng và bấm CONTINUE, Then tôi chơi level con kế tiếp của cùng đá quý với điểm bằng 0.
- AC1.2.2: Given 36 level theo thứ tự, When kiểm tra hàm "level kế tiếp" cho cả 36 level, Then mỗi level trả về đúng level kế tiếp, và level 36 trả về "journey complete".
- Trace: FR2.1, FR2.5.

### US1.3 Thắng Bling thì mở khóa đá quý và sang đá quý kế tiếp
As P1, I want completing Bling to unlock the gem and start the next gem, so that I feel a milestone.
- AC1.3.1: Given đang ở Bling của đá quý 1–5, When tôi thắng, Then đá quý đó được đánh dấu đã mở khóa và level kế tiếp là Rough Stone của đá quý tiếp theo.
- Trace: FR2.5.

### US1.4 Thua thì quay về Rough Stone của đá quý hiện tại
As P1, I want losing to send me back to the current gem's Rough Stone, so that each gem is a real challenge.
- AC1.4.1: Given đang ở Amethyst · Shaping, When không còn nước đi và score < target, Then level hiện tại được lưu là Amethyst · Rough Stone.
- AC1.4.2: Given thua ở Amethyst · Shaping, Then `completed_levels` không còn Amethyst · Rough Stone và Slabbing, nhưng vẫn còn đủ 6 level con của Rose Quartz.
- AC1.4.3: Given đang ở Rough Stone, When thua, Then vẫn ở Rough Stone, `high_scores` giữ nguyên và `highest_level_reached` không giảm.
- AC1.4.4: Given đang ở Amethyst · Rough Stone (level con đầu tiên của đá quý thứ 2), When thua, Then vẫn ở Amethyst · Rough Stone, và cả 6 level con của Rose Quartz vẫn nằm trong `completed_levels`.
- Trace: FR2.3, FR2.3a, FR2.3b, FR2.4.

### US1.5 Thua rồi về menu vẫn áp dụng quy tắc reset
As P1, I want the reset rule to apply whether I replay or go to menu, so that the rule is consistent.
- AC1.5.1: Given vừa thua ở Sapphire · Sanding, When tôi bấm BACK TO MENU rồi bấm PLAY, Then tôi chơi Sapphire · Rough Stone.
- Trace: FR2.3.

### US1.6 Tiến trình được lưu tự động
As P1, I want my progress saved automatically, so that I never lose it when I leave the app.
- AC1.6.1: Given vừa thắng một level, Then tiến trình (level kế tiếp, `completed_levels`) được ghi vào prefs **trước khi** màn Victory hiển thị. Kiểm tra bằng unit test thứ tự gọi. Người dùng thử tay thêm bước kill app ở Victory rồi mở lại.
- AC1.6.2: Given đang chơi, When app vào background, Then `total_play_time` đã được cập nhật trong prefs.
- Trace: FR8.1, FR8.2.

### US1.7 Xem high score của từng level
As P1, I want to see my best score for the current level, so that I can try to beat it.
- AC1.7.1: Given đã từng chơi level này với điểm 1.300, When tôi vào lại level đó, Then BEST hiển thị 1.300 (vị trí trên header theo US2.4).
- AC1.7.2: Given vượt high score cũ, When thắng hoặc thua, Then `high_scores[level_index]` được cập nhật.
- Trace: FR8.1, FR11.1, FR6.1.

---

## Epic 2 — Gameplay (Classic only)

### US2.1 Chỉ còn chế độ Classic
As P1, I want a single clear game mode, so that I'm not confused by options.
- AC2.1.1: Given mở app, Then không có lựa chọn Time Attack ở bất kỳ màn nào.
- AC2.1.2: Grep không phân biệt hoa thường `timeattack`, `time attack`, `high_score_time`, `_timeLeft`, `_startTimer` trong `lib/` cho kết quả 0.
- Trace: FR1.1.

### US2.2 Gameplay Classic giữ nguyên
As P1, I want the familiar block-placing rules, so that the game feels the same.
- AC2.2.1: Given đặt một khối 4 ô, Then score tăng 40.
- AC2.2.2: Given xóa 2 dòng với comboStreak = 2, Then score được cộng 400.
- AC2.2.3: Khối ice/bomb, combo và tutorial lần đầu vẫn hoạt động như trước (các test hiện có hoặc test mới cho `BoardLogic` đều pass).
- Trace: FR1.2, FR1.3.

### US2.3 Đạt mốc điểm là thắng ngay
As P1, I want to win the moment I reach the target, so that I don't have to keep playing.
- AC2.3.1: Given score 480 và target 500, When đặt khối làm score ≥ 500, Then màn Victory hiện ra ngay trong lượt đó, kể cả khi bảng vẫn còn nước đi.
- AC2.3.2: Given score đạt **đúng bằng** target (score = 500), Then cũng thắng.
- Trace: FR2.2.

### US2.4 Header hiển thị tiến độ level
As P1, I want to see the level name, score vs target and a progress bar, so that I know how close I am.
- AC2.4.1: Given đang ở Amethyst · Shaping với score 2.850 và target 4.200, Then header hiển thị "Amethyst · Shaping", "2,850 / 4,200" và thanh tiến độ có nhãn "68%".
- Trace: FR11.1, NFR9.

### US2.5 Hỏi xác nhận khi thoát giữa ván
As P1, I want to confirm before quitting a level, so that I don't lose a round by accident.
- AC2.5.1: Given đang chơi, When bấm [←] hoặc nút Back/cử chỉ quay lại của hệ thống, Then dialog "Quit this level?" hiện ra với CANCEL (focus mặc định) và QUIT.
- AC2.5.2: When bấm CANCEL, Then tiếp tục ván với nguyên điểm.
- AC2.5.3: When bấm QUIT, Then về Home, level đã lưu giữ nguyên và không tính là thua.
- Trace: FR11.2.

### US2.6 Màn Game Over trong chế độ level
As P1, I want a clear game-over screen, so that I understand what happens next.
- AC2.6.1: Given thua, Then overlay hiển thị FINAL SCORE, Target, "You will return to <Gem> · Rough Stone", PLAY AGAIN, SHARE SCORE và BACK TO MENU.
- AC2.6.2: Then không có nút REVIVE.
- Trace: FR11.3, FR2.4.

### US2.7 Chia sẻ điểm
As P1, I want to share my score, so that I can show friends.
- AC2.7.1: Given ở màn Game Over, When bấm SHARE SCORE, Then share sheet của hệ thống mở ra kèm ảnh chụp màn hình và text có điểm.
- Trace: FR11.3.

---

## Epic 3 — Victory & Journey Complete

### US3.1 Màn Victory khi hoàn thành level con
As P1, I want a celebration when I complete a sub-level, so that progress feels rewarding.
- AC3.1.1: Given thắng một level con không phải Bling, Then hiển thị ảnh nền rõ nét, glow, confetti, "Level Complete!", "Congratulations! <Sub> Completed!", "<score> / <target>", BEST và nút CONTINUE.
- AC3.1.2: Given không mute, Then âm thanh victory được phát.
- AC3.1.3: Nút CONTINUE hiển thị và bấm được **ngay khi** vào màn Victory. Hiệu ứng vẫn chạy song song và không chặn thao tác. [Q5]
- Trace: FR6.1, FR6.4.

### US3.2 Unlock đá quý khi hoàn thành Bling
As P1, I want a special unlock animation when I finish a gem, so that the milestone stands out.
- AC3.2.1: Given thắng Bling của đá quý 1–5, Then hiển thị mọi thứ của US3.1, thêm animation 2D đá quý xoay/sparkle, text "🎉 <Gem> Unlocked!" và âm thanh unlock.
- AC3.2.2: Không dùng render 3D.
- AC3.2.3: CONTINUE hiển thị ngay, giống AC3.1.3. [Q5]
- Trace: FR6.2.

### US3.3 Journey Complete ở level 36
As P1, I want a final celebration after Ruby · Bling, so that finishing the journey feels complete.
- AC3.3.1: Given thắng Ruby · Bling, Then hiển thị "JOURNEY COMPLETE!", hiệu ứng như US3.2 và nút BACK TO MENU.
- AC3.3.2: Then **không** có nút CONTINUE.
- AC3.3.3: Then `journey_completed = true` được lưu.
- Trace: FR6.3, FR8.1.

### US3.4 Thời lượng hiệu ứng hợp lý
As P1, I want celebrations that are short and smooth, so that they don't slow me down.
- AC3.4.1: Hiệu ứng chính kéo dài 2–3 giây. Transition 300–500ms với `Curves.easeInOut`.
- AC3.4.2: Nội dung chữ đủ để hiểu kết quả kể cả khi tắt âm thanh.
- Trace: FR6.4, NFR5, NFR9.

---

## Epic 4 — Endless Mode

### US4.1 Vào endless sau khi hoàn thành hành trình
As P1, I want to keep playing after completing the journey, so that the game doesn't end.
- AC4.1.1: Given `journey_completed = true`, Then Home hiển thị "Journey Complete".
- AC4.1.2: When bấm PLAY, Then vào Classic không có target, không có thanh tiến độ và không có Victory.
- Trace: FR9.1.

### US4.2 Lưu điểm endless khi tạm dừng
As P1, I want my endless score saved when I leave, so that I can continue later.
- AC4.2.1: Given score endless 1.200, When QUIT, về Home hoặc app vào background, Then `endless_saved_score = 1200`.
- AC4.2.2: When bấm PLAY lần sau, Then ván mới bắt đầu với SCORE 1.200 trên bảng trống.
- AC4.2.3: Given score endless = 0, When QUIT, Then lưu 0 và không lỗi.
- Trace: FR9.2, FR9.3.

### US4.3 Thua trong endless thì reset điểm
As P1, I want losing to reset my endless score, so that there's still a challenge.
- AC4.3.1: Given thua trong endless, Then `endless_saved_score = 0` và lần PLAY tiếp theo bắt đầu từ 0.
- AC4.3.2: Then `endless_high_score` được cập nhật nếu điểm cao hơn.
- Trace: FR9.4, FR9.5.

### US4.4 UI riêng của endless
As P1, I want endless-specific header and game-over screens, so that nothing refers to targets that don't exist.
- AC4.4.1: Header hiển thị [←], "Endless", SCORE và BEST.
- AC4.4.2: Dialog thoát hiển thị "Quit? Your score will be saved."
- AC4.4.3: Game Over hiển thị FINAL SCORE, BEST, PLAY AGAIN, SHARE SCORE và BACK TO MENU, không có Target hay thông báo quay về Rough Stone.
- Trace: FR9.6, FR9.7.

---

## Epic 5 — Home & Settings

### US5.1 Home với một nút PLAY
As P1, I want one PLAY button that takes me straight to my current level, so that starting is effortless.
- AC5.1.1: Given level hiện tại là Emerald · Sanding, Then Home hiển thị "Emerald · Sanding" và nút PLAY.
- AC5.1.2: When bấm PLAY, Then vào thẳng Emerald · Sanding (không qua màn chọn level).
- Trace: FR10.1, FR7 (out of scope).

### US5.2 Bỏ Daily Gift
As P1, I want no misleading daily gift popup, so that the app feels honest.
- AC5.2.1: Given mở app vào một ngày mới, Then không có popup Daily Gift. Code `_checkDailyReward` và key `last_login_date` đã được gỡ.
- Trace: FR10.2.

### US5.3 Settings chỉ còn âm thanh, mute được lưu
As P1, I want my mute choice remembered, so that the game stays silent if I want.
- AC5.3.1: Settings chỉ có Sound Effects on/off, không có chọn theme.
- AC5.3.2: Given đã tắt âm thanh, When khởi động lại app, Then âm thanh vẫn tắt (`sound_muted`).
- AC5.3.3: Given `sound_muted = true`, Then không có lệnh phát nào được gọi cho cả 6 âm thanh (place, clear, combo, gameover, victory, unlock).
- Trace: FR10.3, FR13.2.

### US5.4 Màu giao diện theo đá quý
As P1, I want the UI colors to match the current gem, so that each gem feels distinct.
- AC5.4.1: Given đang ở Emerald, Then gradient nền, accent, thanh tiến độ và glow dùng `#50C878` / `#228B22`.
- AC5.4.2: Mỗi level lớn trong 6 level dùng đúng cặp màu của bảng FR12.1. `theme_index` và lựa chọn theme đã được gỡ.
- Trace: FR12.1, FR12.2.

---

## Epic 6 — Config & Analytics (P2)

### US6.1 Mốc điểm từ Remote Config, có fallback
As P2, I want level targets driven by Remote Config with a safe default, so that I can tune difficulty without a release.
- AC6.1.1: Given Remote Config có JSON hợp lệ, When app khởi động và fetch/activate thành công, Then target của các level bằng giá trị trên Remote Config.
- AC6.1.2: Given offline ở lần mở đầu tiên, Then dùng config mặc định trong app (level 1 target 500).
- AC6.1.3: Given JSON lỗi, thiếu level hoặc có `target_score` ≤ 0, Then bỏ toàn bộ JSON, dùng mặc định và ghi log lỗi.
- Trace: FR3.1, FR3.2, FR3.3.

### US6.2 Config đã cache bị hỏng thì reset về mặc định
As P2, I want a corrupted cached config to be discarded, so that players never get stuck with bad data.
- AC6.2.1: Given config đã activate hoặc đã cache bị hỏng (giả lập trong test), Then dùng mặc định (level 1 target 500), ghi log lỗi và không thử khôi phục bản cũ.
- Trace: FR3.3a.

### US6.3 Theo dõi event level
As P2, I want level events in Analytics, so that I can measure completion and difficulty.
- AC6.3.1: Given bắt đầu, thắng hoặc thua một level, Then gửi `level_start`, `level_complete` hoặc `level_fail` với `{major, sub, level_index ∈ 1..36}`. Hai event sau có thêm `score` và `target`. Kiểm tra bằng unit test với service được mock.
- AC6.3.2: Chế độ endless không gửi event level.
- Trace: FR4.1, FR4.4, FR9.8.

### US6.4 Theo dõi thời lượng phiên và user property
As P2, I want session duration and progress properties, so that I can track session time and retention.
- AC6.4.1: When app vào background hoặc thoát, Then gửi `game_session{duration_sec}`.
- AC6.4.2: Then cập nhật `current_major_level` và `highest_level_reached` (không giảm).
- AC6.4.3: Offline thì event được xếp hàng và gửi lại khi có mạng (hành vi SDK). Người dùng kiểm tra bằng DebugView.
- Trace: FR4.1, FR4.2, FR4.3.

---

## Epic 7 — Backgrounds & Offline

### US7.1 Ảnh nền riêng cho từng level
As P1, I want each sub-level to have its own background, so that I see the gem being crafted.
- AC7.1.1: Given đang ở Blue Topaz · Polishing, Then nền là ảnh tương ứng (`assets/design/Level3/5.jpg` hoặc URL từ Remote Config), hiển thị blur phía sau board.
- AC7.1.2: Màn Victory hiển thị cùng ảnh đó nhưng rõ nét.
- Trace: FR5.1, FR5.3.

### US7.2 Ảnh từ Firebase Storage, fallback về asset
As P2, I want backgrounds served from Storage with an asset fallback, so that I can update art without a release.
- AC7.2.1: Given Remote Config có URL công khai hợp lệ (Firebase Storage download URL) và có mạng, Then ảnh được tải bằng `cached_network_image` và cache trên đĩa. **Không dùng `firebase_storage` SDK** (NFR4).
- AC7.2.2: Given không có URL, URL lỗi hoặc offline, Then dùng ảnh asset của đúng level.
- AC7.2.3: Given ảnh đã được cache, When mở lại level đó, Then ảnh được lấy từ cache. Kiểm tra bằng unit test với cache manager được mock: không có lời gọi download.
- Trace: FR5.2, FR5.4.

### US7.3 Preload ảnh level kế tiếp
As P1, I want the next background ready, so that the transition is instant.
- AC7.3.1: Given đang chơi level N, Then ảnh của level N+1 được precache trước khi vào Victory.
- Trace: FR5.4, NFR5.

### US7.4 Chơi hoàn toàn offline
As P1, I want to play without internet, so that I can play anywhere.
- AC7.4.1: Given chế độ máy bay từ lần mở đầu tiên, Then chơi được level 1 đến khi thắng hoặc thua, với ảnh asset và config mặc định.
- Trace: NFR6, FR3.2, FR5.2.

---

## Epic 8 — Platform & Quality (P2)

### US8.1 Đổi package Android
As P2, I want the Android app id `com.h2.game.block_blast`, so that I can publish under my identity.
- AC8.1.1: `namespace` và `applicationId` là `com.h2.game.block_blast`. `MainActivity.kt` nằm ở `kotlin/com/h2/game/block_blast/`. Các manifest đã được cập nhật.
- AC8.1.2: Người dùng chạy `flutter build appbundle` thành công.
- Trace: FR14, NFR3.

### US8.2 Đổi bundle ID iOS
As P2, I want the iOS bundle id `com.h2.game.blockBlast`, so that iOS builds are valid.
- AC8.2.1: `PRODUCT_BUNDLE_IDENTIFIER` là `com.h2.game.blockBlast`, RunnerTests là `com.h2.game.blockBlast.RunnerTests`.
- AC8.2.2: Người dùng chạy `flutter build ios` thành công.
- Trace: FR14, NFR3.

### US8.3 Khai báo asset và âm thanh mới
As P2, I want all assets declared and new sounds added, so that builds include everything.
- AC8.3.1: `pubspec.yaml` khai báo `assets/design/`. Build không báo thiếu asset.
- AC8.3.2: Có `victory` và `unlock.wav` (cho phép dùng placeholder). Lỗi phát âm thanh được log, không bị nuốt.
- Trace: NFR2, FR13.1, FR13.3.

### US8.4 Firebase setup không hardcode secret
As P2, I want Firebase wired via platform config files I generate, so that no keys are hardcoded.
- AC8.4.1: Code Dart không chứa API key. App đọc cấu hình Firebase từ `google-services.json` và `GoogleService-Info.plist` do người dùng tạo.
- AC8.4.2: Chỉ thêm các dependency `firebase_core`, `firebase_remote_config`, `firebase_analytics` và `cached_network_image`.
- Trace: NFR11, NFR4.

### US8.5 Kiến trúc tách logic, test đạt ngưỡng (Definition of Done xuyên suốt)
As P2, I want game logic in controllers/services with ≥80% coverage, so that the app is maintainable.
- Ghi chú: đây là tiêu chí áp dụng cho mọi story, không phải một hạng mục làm riêng. [dev contribution]
- AC8.5.1: Logic level, tiến trình, config và endless nằm trong controller/service, unit-test được mà không cần widget.
- AC8.5.2: `test/widget_test.dart` đã được sửa. `flutter test --coverage` (người dùng chạy) đạt ≥ 80% line coverage trên toàn bộ codebase.
- Trace: NFR1, NFR10.

### US8.6 Hiệu năng, hướng màn hình, accessibility, ngôn ngữ
As P1, I want a smooth, readable, portrait English UI, so that the game is comfortable to play.
- AC8.6.1: Khóa màn hình dọc. Toàn bộ chuỗi UI là tiếng Anh.
- AC8.6.2: Widget test xác nhận các nút ≥ 48dp. Checklist tương phản WCAG AA (chữ 4.5:1, thành phần UI như thanh tiến độ 3:1) đạt cho 6 bảng màu đá quý.
- AC8.6.3: Profile mode khi kéo khối không có frame > 16ms kéo dài trên thiết bị tầm trung (người dùng đo). Khuyến nghị nén `assets/design` ≤ 10MB.
- Trace: NFR5, NFR7, NFR8, NFR9.

---

## Ghi chú kiểm thử tay (người dùng chạy)

AC1.6.1 (bước kill app), AC6.4.3 (DebugView), AC8.1.2 và AC8.2.2 (build), AC8.6.3 (profile FPS).

## Tổng hợp

- **8 epic, 40 story**, tất cả có ưu tiên Must Have.
- Thứ tự phụ thuộc chính: US6.1 → US1.x → US2.x/US3.x → US4.x. Các story US8.1–US8.4 nên làm trước làm nền tảng.
- FR7 (chọn level) nằm ngoài phạm vi và không có story.
