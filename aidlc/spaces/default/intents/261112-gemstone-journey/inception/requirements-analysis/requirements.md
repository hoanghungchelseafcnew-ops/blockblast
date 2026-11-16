# Requirements — Gemstone Journey

## Sources

- [req] File requirements (DocumentKB `01a1cee8-d5e3-778f-8ca4-4bc99c076955`). Mã FR1..FR8 và NFR1..NFR6 ở đây tương ứng với FR-01..FR-08 và NFR-01..NFR-06 trong file requirements (bỏ dấu gạch và số 0 ở đầu)
- [intent] `ideation/intent-capture/intent-statement.md`
- [scope] `ideation/scope-definition/scope-document.md` (S-01..S-12)
- [wire] `ideation/rough-mockups/wireframes.md`, `user-flow.md` (W-1..W-6, W-2a, W-5a)
- [dec] `ideation/approval-handoff/decision-log.md` (D-01..D-14)
- [feas] `ideation/feasibility/constraint-register.md`
- [prac] `inception/practices-discovery/team-practices.md`
- [codekb] `aidlc/spaces/default/codekb/block-crush-game-main/`
- [Q1]–[Q10] `requirements-analysis-questions.md`
- [gate] Phản hồi Request Changes của người dùng ở cổng phê duyệt (R-01, R-02, R-03)

## 1. Tổng quan

- **Loại:** enhancement
- **Phạm vi:** nhiều thành phần
- **Độ phức tạp:** standard
- **Depth:** Standard

Mục tiêu là nâng cấp Block Crush (Flutter, `block_blast`) thành hành trình 36 level theo chủ đề đá quý, chỉ giữ chế độ Classic, nhằm tăng session time và retention. [intent] [req]

**Cấu trúc level** [req]:
- 6 level lớn, theo thứ tự: Rose Quartz, Amethyst, Blue Topaz, Emerald, Sapphire, Ruby.
- Mỗi level lớn có 6 level con, theo thứ tự: Rough Stone, Slabbing, Shaping, Sanding, Polishing, Bling.
- Tổng cộng 36 level, đánh số 1..36 theo thứ tự trên.

## 2. Functional Requirements

### FR1 Classic Mode Only [req] [scope] [Q8]
- FR1.1: Gỡ hoàn toàn chế độ Time Attack, gồm `GameMode.timeAttack`, timer, nhánh UI và key `high_score_time`.
- FR1.2: Gameplay Classic giữ nguyên: bảng 8×8, khay 3 khối, đặt khối được 10 điểm/ô, xóa dòng được `dòng × 100 × comboStreak`, có combo, khối ice/bomb và tutorial lần đầu. [Q5] [codekb]
- FR1.3: Ván chơi chỉ kết thúc vì thua khi không còn chỗ đặt khối nào trong khay.
- **Pass:** không còn đường dẫn UI nào mở Time Attack. Grep (không phân biệt hoa thường) `timeattack`, `time attack`, `high_score_time`, `_timeLeft`, `_startTimer` trong `lib/` đều cho kết quả 0.

### FR2 Level Score System [req] [Q6]
- FR2.1: Mỗi level có `target_score`. Điểm được tích lũy trong ván và reset về 0 khi bắt đầu level mới.
- FR2.2: Khi `score ≥ target_score`, game **chuyển ngay** sang Victory, kể cả khi bảng vẫn còn nước đi. [Q6]
- FR2.3: Thua (không còn nước đi khi `score < target`) thì level hiện tại được đặt về **Rough Stone của level lớn đang chơi** và lưu ngay, áp dụng cho cả PLAY AGAIN lẫn BACK TO MENU. [req] [wire] [Q2]
- FR2.3a: Khi thua, mọi level con của level lớn đang chơi bị xóa khỏi `completed_levels`, kể cả các level con đã thắng trước đó. Người chơi phải thắng lại từ Rough Stone. Các level lớn đã hoàn thành trước đó (đá quý đã mở khóa) không bị ảnh hưởng. [gate]
- FR2.3b: `high_scores` của từng level được giữ nguyên khi thua. User property `highest_level_reached` không giảm. [assumption]
- FR2.4: Thua ngay tại Rough Stone vẫn ở lại Rough Stone. Overlay hiển thị "You will return to <Gem> · Rough Stone". [wire]
- FR2.5: Thắng level con 1–5 thì sang level con kế tiếp. Thắng Bling (level con 6) của level lớn 1–5 thì sang Rough Stone của level lớn kế tiếp, đồng thời đánh dấu đá quý đó là đã mở khóa. [req]
- **Pass:**
  - Unit test xác nhận chuyển level đúng cho cả 36 level.
  - Thua ở Amethyst · Shaping thì về Amethyst · Rough Stone. `completed_levels` không còn Amethyst · Rough Stone, Slabbing; vẫn còn đủ 6 level con của Rose Quartz.
  - Đạt target thì sang Victory ngay trong lượt đặt khối đó.

### FR3 Firebase Remote Config [req] [Q10]
- FR3.1: Lưu cấu hình 36 mốc điểm dạng JSON theo cấu trúc trong file requirements (`version`, `levels.<gem>.sub_levels.<sub>.target_score`, cùng `order` và `name`).
- FR3.2: Khi khởi động app, gọi fetch và activate. Nếu fetch lỗi hoặc timeout thì dùng giá trị đã activate lần trước, nếu chưa có thì dùng **config mặc định trong app**, giống hệt JSON trong requirements. `minimumFetchInterval` = 12 giờ. [Q10]
- FR3.3: JSON lỗi, thiếu level, hoặc có `target_score` ≤ 0 thì bỏ toàn bộ config đó, dùng mặc định trong app và ghi log lỗi. [prac]
- FR3.3a: Nếu config đã activate hoặc đã cache trước đó bị hỏng, nó được coi như mất: app dùng config mặc định trong app và không thử khôi phục bản cũ. Lần fetch hợp lệ tiếp theo sẽ ghi đè. [gate]
- FR3.4: Remote Config cũng chứa URL ảnh nền cho từng level con (xem FR5).
- **Pass:**
  - Test parse JSON hợp lệ và JSON lỗi.
  - Khi offline lần đầu, mốc của Rose Quartz · Rough Stone là 500.
  - Config đã cache bị hỏng (giả lập trong test) thì dùng mặc định, mốc level 1 là 500, và có log lỗi.

### FR4 Firebase Analytics [req]
- FR4.1: Gửi các event:
  - `level_start` với `{major, sub, level_index}`
  - `level_complete` với `{major, sub, level_index, score, target}`
  - `level_fail` với `{major, sub, level_index, score, target}`
  - `game_session` với `{duration_sec}`, gửi khi app vào background hoặc thoát
- FR4.2: Cập nhật user property `current_major_level` và `highest_level_reached` (1..36).
- FR4.3: Khi offline, event được SDK xếp hàng và gửi lại khi có mạng (hành vi mặc định của SDK, NFR6).
- FR4.4: Chế độ endless sau level 36 (FR9) không gửi event level. Chỉ gửi `game_session`. [assumption]
- **Pass:**
  - Unit test với analytics service được mock kiểm tra tên event và tham số, trong đó `level_index` nằm trong khoảng 1..36.
  - DebugView của Firebase hiển thị đủ 4 event khi chạy debug build (người dùng kiểm tra).

### FR5 Level Background Images [req] [scope] [Q2 scope]
- FR5.1: Mỗi level con có 1 ảnh nền, tổng 36 ảnh.
- FR5.2: Nguồn ưu tiên là URL Firebase Storage lấy từ Remote Config. Nếu không có URL, tải lỗi hoặc offline thì dùng ảnh trong assets `assets/design/Level<1..6>/<1..6>.jpg`, với Level1 = Rose Quartz … Level6 = Ruby và ảnh 1..6 = Rough Stone … Bling. [codekb]
- FR5.3: Trong lúc chơi, ảnh hiển thị blur phía sau board. Màn Victory hiển thị ảnh rõ nét.
- FR5.4: Ảnh tải từ mạng được cache trên đĩa. Ảnh của level kế tiếp được preload trong lúc chơi. [req NFR5]
- **Pass:**
  - Tắt mạng thì vẫn thấy ảnh asset đúng level.
  - Mở lại level đã tải thì không có request mạng mới.

### FR6 Victory Celebration [req] [wire] [Q7]
- FR6.1: Hoàn thành level con (W-4) hiển thị:
  - ảnh nền rõ nét, glow, confetti bay từ dưới lên
  - text "Level Complete!" và "Congratulations! <Sub> Completed!"
  - "<score> / <target>" và high score của level
  - nút **CONTINUE**
  - âm thanh victory
- FR6.2: Hoàn thành Bling (W-5) có thêm animation unlock đá quý **2D** (xoay + sparkle), text "🎉 <Gem> Unlocked!" và âm thanh unlock. Không làm 3D. [dec D-08]
- FR6.3: Hoàn thành level 36, Ruby · Bling (W-5a), hiển thị hiệu ứng như W-5 cộng "JOURNEY COMPLETE!". **Không có CONTINUE**, chỉ có nút BACK TO MENU. [wire]
- FR6.4: Hiệu ứng chính kéo dài 2–3 giây. Transition 300–500ms với `Curves.easeInOut`. [req 5.2]
- **Pass:** widget test cho W-4, W-5 và W-5a kiểm tra đúng text và nút (có hoặc không có CONTINUE).

### FR7 Level Selection UI
Đã chuyển xuống mục 4 Ngoài phạm vi. Giữ ID này để truy vết.

### FR8 Progress Persistence [req] [scope]
- FR8.1: Lưu bằng SharedPreferences, qua một repository riêng [prac]:
  - `current_major_level`
  - `current_sub_level`
  - `completed_levels` (danh sách level_index)
  - `high_scores` (map level_index → int)
  - `total_play_time` (giây)
  - `journey_completed` (bool)
- FR8.2: Tự động lưu khi: hoàn thành level (trước khi hiện Victory), thua (đặt về Rough Stone), chuyển level, và app vào background hoặc thoát.
- FR8.3: Không có dữ liệu, hoặc dữ liệu hỏng/không hợp lệ, thì dùng mặc định Rose Quartz · Rough Stone. [wire]
- **Pass:**
  - Kill app ở màn Victory rồi mở lại, level hiện tại là level kế tiếp.
  - Dữ liệu rác thì app khởi động ở level 1, không crash.

### FR9 Endless Mode sau Journey Complete [Q1] [gate]
- FR9.1: Khi `journey_completed = true`, Home hiển thị "Journey Complete". Bấm PLAY vào **Classic không có mục tiêu điểm**: không có target, không có thanh tiến độ, không có Victory.
- FR9.2: **Lưu điểm khi tạm dừng.** Khi người chơi thoát giữa ván (QUIT trong dialog, về Home, hoặc app vào background), điểm hiện tại được lưu vào key `endless_saved_score`. Lần sau bấm PLAY, ván mới bắt đầu với điểm đó. [gate]
- FR9.3: [assumption] Chỉ lưu điểm. Bảng và khay khối bắt đầu mới (trống) khi vào lại.
- FR9.4: **Thua thì reset điểm về 0.** Game over trong endless đặt `endless_saved_score = 0`. PLAY AGAIN bắt đầu từ 0. [gate]
- FR9.5: High score của endless lưu ở key `endless_high_score` và được cập nhật khi game over hoặc khi thoát.
- FR9.6: Header khi chơi endless gồm [←], "Endless", SCORE và BEST (endless). Không có target hay %. Dialog thoát hiển thị "Quit? Your score will be saved." với CANCEL và QUIT.
- FR9.7: Game Over khi chơi endless gồm FINAL SCORE, BEST, PLAY AGAIN, SHARE SCORE và BACK TO MENU. Không có Target hay thông báo quay về Rough Stone.
- FR9.8: Chế độ endless chỉ gửi event `game_session`, không gửi event level. [assumption] Nền và màu dùng Ruby · Bling. [assumption]
- **Pass:**
  - Có điểm 1.200, QUIT, vào lại thì SCORE hiển thị 1.200 trên bảng trống.
  - Thua thì lần PLAY tiếp theo SCORE là 0.
  - Không xuất hiện Victory, target hay thanh tiến độ.

### FR10 Home Screen [wire] [dec D-11] [Q4]
- FR10.1: Có một nút **PLAY** vào thẳng level hiện tại, nhãn level hiện tại dạng "<Gem> · <Sub>", và nút Settings ⚙️.
- FR10.2: Bỏ Daily Gift, gồm popup, logic và key `last_login_date`. [dec D-11]
- FR10.3: Settings chỉ còn Sound Effects on/off. **Bỏ chọn theme** Neon/Wood/Jewel. [Q4]

### FR11 Game Screen & Game Over [wire] [Q3] [Q7]
- FR11.1: Header gồm [←], "<Gem> · <Sub>", "<score> / <target>", thanh tiến độ có nhãn % dạng chữ, và BEST của level. [wire] [Q7]
- FR11.2: Bấm [←] hoặc nút Back / cử chỉ quay lại của hệ thống mở dialog "Quit this level?" với hai nút CANCEL (focus mặc định) và QUIT. QUIT bỏ ván, **không tính là thua**, level đã lưu giữ nguyên. [wire]
- FR11.3: Game Over gồm FINAL SCORE, Target, "You will return to <Gem> · Rough Stone", PLAY AGAIN, SHARE SCORE và BACK TO MENU. **Bỏ REVIVE.** [Q3]

### FR12 Gem Color Theme [req 5.1] [Q4]
- FR12.1: Màu chính và màu phụ của UI (gradient nền, accent, thanh tiến độ, glow) lấy theo level lớn hiện tại:

| Level lớn | Màu chính | Màu phụ |
|-----------|-----------|---------|
| Rose Quartz | `#FFB6C1` | `#FF69B4` |
| Amethyst | `#9966CC` | `#8B008B` |
| Blue Topaz | `#4FC3F7` | `#0288D1` |
| Emerald | `#50C878` | `#228B22` |
| Sapphire | `#0F52BA` | `#000080` |
| Ruby | `#E0115F` | `#8B0000` |

- FR12.2: Gỡ `ThemeManager` theme selection và key `theme_index`.

### FR13 Audio [req NFR2] [Q9]
- FR13.1: Tái sử dụng `clear.wav`, `combo.wav`, `place.wav`, `gameover.wav`. Thêm `victory` (wav hoặc mp3) và `unlock.wav`. Được dùng placeholder. [scope]
- FR13.2: Trạng thái mute được lưu (key `sound_muted`) và áp dụng cho mọi âm thanh. [Q9]
- FR13.3: Lỗi phát âm thanh phải được log, không nuốt im lặng. [prac]
- **Pass:** unit test xác nhận khi `sound_muted = true` thì không có lệnh phát nào được gọi, cho cả 6 loại âm thanh. Trạng thái mute còn giữ sau khi khởi động lại (đọc lại từ prefs).

### FR14 Package Rename [req NFR3] [dec D-08]
- Android: `namespace` và `applicationId` = `com.h2.game.block_blast`, chuyển `MainActivity.kt` sang `kotlin/com/h2/game/block_blast/`, cập nhật các manifest.
- iOS: `PRODUCT_BUNDLE_IDENTIFIER` = `com.h2.game.blockBlast` (RunnerTests là `com.h2.game.blockBlast.RunnerTests`).
- **Pass:** người dùng build thành công `flutter build appbundle` và `flutter build ios`. [prac]

## 3. Non-Functional Requirements

| ID | Yêu cầu | Tiêu chí đo | Nguồn |
|----|---------|-------------|-------|
| NFR1 | Tái sử dụng code. Giữ cấu trúc `lib/features/`, `provider`. **Logic và state mới đặt trong controller/service**, screen chỉ render | Logic level, tiến trình và config có unit test mà không cần widget | [req] [prac] |
| NFR2 | Tái sử dụng asset. Ảnh ở `assets/design/` được khai báo trong `pubspec.yaml` | `flutter build` không báo thiếu asset | [req] [codekb] |
| NFR3 | Đổi package | Xem FR14 | [req] |
| NFR4 | Hạn chế dependency. Chỉ thêm `firebase_core`, `firebase_remote_config`, `firebase_analytics`, kèm `cached_network_image` cho ảnh. Không thêm package nào khác nếu không có lý do ghi lại | Diff `pubspec.yaml` chỉ chứa các package này | [req] |
| NFR5 | Hiệu năng: 60 FPS khi chơi trên thiết bị tầm trung. Hiệu ứng Victory không làm treo UI. Ảnh được nén | Profile mode không có frame > 16ms kéo dài khi kéo khối. Khuyến nghị: nén ảnh để tổng dung lượng `assets/design/*.jpg` ≤ 10MB, đo bằng `du -sh` (hiện khoảng 25MB) [assumption] | [req] [codekb] |
| NFR6 | Offline: chơi đầy đủ không cần mạng, dùng config mặc định và ảnh asset. Analytics tự gửi lại khi có mạng | Chế độ máy bay: chơi được từ level 1 đến khi thắng hoặc thua | [req] |
| NFR7 | UI chỉ dùng tiếng Anh | Không có chuỗi UI tiếng Việt hay ngôn ngữ khác | [prac] [dec D-13] |
| NFR8 | Chỉ hỗ trợ điện thoại, màn hình dọc | Khóa orientation portrait | [wire] |
| NFR9 | Accessibility cơ bản: vùng chạm ≥ 48dp, tương phản chữ ≥ 4.5:1, trạng thái không chỉ thể hiện bằng màu, thanh tiến độ có nhãn chữ | Widget test kiểm tra kích thước nút ≥ 48dp. Checklist tương phản chữ cho 6 bảng màu đá quý (FR12) | [wire] |
| NFR10 | Test-after, coverage dòng ≥ 80% trên toàn bộ codebase. Sửa `test/widget_test.dart` đang hỏng | `flutter test --coverage` (người dùng chạy) đạt ≥ 80% | [prac] |
| NFR11 | Không hardcode secret. `google-services.json` và `GoogleService-Info.plist` do người dùng tạo từ Firebase project của mình | Không có API key nào trong code Dart | [phase rules] [feas] |

## 4. Ngoài phạm vi

- **FR7 Level Selection UI** (FR-07 trong file gốc): không làm màn chọn level lớn và level con. Nút PLAY vào thẳng level hiện tại (FR10). [dec D-11] [wire]


FR7 chọn level, Daily Gift, quảng cáo/IAP, đá quý 3D, đồng bộ tiến trình lên cloud, đa ngôn ngữ, phát hành tại EU, REVIVE, chọn theme. [scope] [dec] [Q3] [Q4]

## 5. Acceptance Criteria (theo file requirements, đã điều chỉnh)

- **AC-01:** chơi được qua 36 level theo thứ tự. Mốc điểm đúng theo Remote Config hoặc mặc định. Thua thì quay về đúng Rough Stone. Sau level 36 vào chế độ endless.
- **AC-02:** Victory hiển thị ảnh nền rõ nét, có confetti và animation, có âm thanh (trừ khi đang mute). Level 36 không có CONTINUE.
- **AC-03:** Remote Config fetch thành công. Analytics ghi đúng 4 event. Fallback hoạt động khi offline.
- **AC-04:** app build thành công với package mới trên Android và iOS.

## 6. Ràng buộc

Một developer, không dùng git, chỉ dùng gói miễn phí của Firebase, đối tượng 13+, không phát hành EU. AI chỉ sinh code, người dùng tự build và test trên máy khác. [feas] [prac]

## 7. Ma trận truy vết

| ID mới | ID gốc (file requirements) | Ideation |
|--------|----------------------------|----------|
| FR1 | FR-01 | S-01 |
| FR2 | FR-02, mục 2.2 | S-02, D-12 |
| FR3 | FR-03 | S-03, S-10 |
| FR4 | FR-04 | S-04 |
| FR5 | FR-05 | S-05, D-08 |
| FR6 | FR-06 | S-06, D-08, D-12 |
| FR7 | FR-07 (out of scope) | S-07, D-11 |
| FR8 | FR-08 | S-08 |
| FR9 | — (mới) | D-12, Q1, gate |
| FR10 | — (mới) | D-11, W-1 |
| FR11 | — (mới) | D-12, W-2/W-2a/W-3 |
| FR12 | mục 5.1 | Q4 |
| FR13 | NFR-02 (âm thanh) | S-11 |
| FR14 | NFR-03 | S-09, D-06, D-08 |
| NFR1–NFR6 | NFR-01–NFR-06 | S-12, S-10 |
| NFR7–NFR11 | — (mới) | D-13, W-*, practices, constraints |

## Assumptions & Open Questions

- [assumption] FR2.3b: khi thua, `high_scores` được giữ nguyên và `highest_level_reached` không giảm.
- [assumption] FR9.3: chế độ endless chỉ lưu điểm, bảng bắt đầu mới khi vào lại.
- [assumption] FR9.8: chế độ endless chỉ gửi `game_session`, dùng nền và màu Ruby · Bling.
- [assumption] NFR5: ngưỡng ≤ 10MB cho ảnh là khuyến nghị, không phải điều kiện bắt buộc.
