# Kế hoạch Code Generation — U3 `u3-victory-audio`

## Sources

- [units] `inception/units-generation/unit-of-work.md` (U3: `VictoryUI` các biến thể sub, gemUnlock, journeyComplete; `AudioController` với `playVictory`, `playUnlock`, `stopSfx`, mute lưu qua `sound_muted`; Settings chỉ còn Sound; asset `victory` và `unlock.wav`) và `unit-of-work-story-map.md` (U3: US5.3 → US8.3 → US3.1 → US3.2 → US3.3 → US3.4)
- [contract] `inception/contract-design/contract-summary.md`: C1 (`JourneyOutcome.unlockedGemId`, `journeyCompleted`), C2 (`LevelGameController` state, `outcome`, `bestScore`), C5 (`soundMuted`, `setSoundMuted`), C6 (`GemTheme`, đã có từ U4), E3 (key `sound_muted`)
- [req] `inception/requirements-analysis/requirements.md`: FR6.1..FR6.4, FR13.1..FR13.3
- [stories] `inception/user-stories/stories.md`: AC3.1.1..AC3.1.3, AC3.2.1..AC3.2.3, AC3.3.1..AC3.3.3, AC3.4.1, AC3.4.2, AC5.3.2, AC5.3.3, AC8.3.2
- [mock] `inception/refined-mockups/mockups.md` (M-4, M-5, M-5a) và `interaction-spec.md` (VictoryScreen: trạng thái, ngắt hiệu ứng, âm thanh, reduced motion; bảng transition)
- [user] Yêu cầu của người dùng ngày 2026-11-18 (tin nhắn `ac4d5cbb`): sửa cách kéo khối theo hướng 2. Khối nâng lên phía trên ngón tay một khoảng cố định, và ô được tính theo vị trí đã nâng để preview khớp với khối người chơi thấy. Gắn vào U3 vì U3 vốn sửa `game_screen.dart` và hoàn tất trước U6.
- [code] Code hiện có: `AudioController` (static, nuốt lỗi), `GameFeedback`, `LevelGameController`, `GameScreen` (Victory tạm của U1), `DraggableBlock`, `BlockPalette`, `BoardGeometry`, `ParticleExplosion`, `GemPrimaryButton`, `LevelBackground`
- [prac] `aidlc/spaces/default/memory/team.md`: test-after, coverage ≥ 80%, logic nằm trong controller/service, UI chỉ tiếng Anh

U3 không có artifact functional design, NFR hay infrastructure riêng. Kế hoạch dựa trực tiếp vào contract, requirements, story, refined mockups và yêu cầu của người dùng ở trên.

## Testing Contract

```json
{
  "version": 1,
  "methodology": "test-after",
  "source": "team",
  "ordering": "Implement each testable layer first, then write and run that layer's tests before moving on.",
  "scope": "feature",
  "test_strategy": "standard",
  "project_type": "brownfield",
  "applicable_notes": [
    {
      "layer": "org",
      "text": "We treat tests as a first-class deliverable in every Bolt. The specific\nmethodology (TDD, BDD, ATDD, or classic test-after) is affirmed at\npractices-discovery and recorded in `team.md` under this heading with explicit\n`Methodology` and `Ordering` fields; Code Generation resolves those fields\nindependently from coverage, tooling, and scope notes.\n\nWhen no posture has been affirmed, our default per scope is:\n- **Methodology**: test-after\n- **Ordering**: implement each applicable testable layer, then write and run\n  that layer's tests.\n- `mvp`, `enterprise`, `feature`, `infra`, `classic` add an 80% line-coverage\n  floor and CI execution before merge.\n- `bugfix`, `security-patch` add a targeted regression for the specific\n  bug/vulnerability and require the existing suite to remain green.\n- `express` uses the Minimal strategy: requirement-driven unit tests (one per\n  requirement, with a happy-path floor per component); existing tests remain\n  green.\n- `poc`, `refactor`, `workshop` add no extra new-test floor and require the\n  existing suite to remain green.\n\nThe active `Test Strategy` still applies in every scope and determines test\nvolume/types. Scope floors are additive; they never reduce or replace the\nselected strategy.\n\nBuild and Test verifies defined coverage floors and affirmed quality targets;\nthey may not be weakened to make a step pass.\n\nAffirm a stricter posture in `team.md` if the team commits to one."
    },
    {
      "layer": "team",
      "text": "- **Methodology**: test-after\n- **Ordering**: Implement each testable layer first, then write and run that layer's tests before moving on.\n- Coverage dòng tối thiểu **80% trên toàn bộ codebase**, không chỉ code mới.\n- Ưu tiên unit test cho logic thuần (level, điểm, tiến trình, parse config, fallback) và cho controller/service. Có widget test cho các màn mới.\n- Sửa `test/widget_test.dart` đang hỏng trước khi đo coverage.\n- Lệnh kiểm tra: `flutter analyze` và `flutter test --coverage`. Chúng tôi tự chạy trên máy khác: AI chỉ sinh code và test, người dùng chạy rồi báo kết quả."
    }
  ],
  "obligations": {
    "strategy": "standard",
    "strategy_volume": [
      "Five to eight tests per component.",
      "Unit tests plus integration tests for key boundaries.",
      "Add E2E, performance, or security tests when requirements demand them."
    ],
    "scope_floor": [
      "Meet an 80% line-coverage floor.",
      "Run the selected tests in CI before merge."
    ],
    "combination_rule": "Apply every selected-strategy obligation and every scope-floor obligation; neither replaces the other, and a targeted scope regression may add the narrowest necessary test type beyond the strategy default."
  },
  "plan_profile": {
    "methodology": "test-after",
    "runner_step": "Verify the existing test runner/configuration and record the exact unit-scoped command.",
    "runner_ready_before_first_test": true,
    "testable_layers": [
      "Data model / database behavior",
      "Repository / data access",
      "Business logic",
      "API / endpoint",
      "Frontend behavior"
    ],
    "steps": [
      "Project structure and production configuration skeleton.",
      "Verify the existing test runner/configuration and record the exact unit-scoped command.",
      "Data model / database behavior - implement.",
      "Data model / database behavior - write and run its tests after implementation.",
      "Repository / data access - implement.",
      "Repository / data access - write and run its tests after implementation.",
      "Business logic - implement.",
      "Business logic - write and run its tests after implementation.",
      "API / endpoint - implement.",
      "API / endpoint - write and run its tests after implementation.",
      "Frontend behavior - implement.",
      "Frontend behavior - write and run its tests after implementation.",
      "Environment/build configuration.",
      "Documentation and traceability."
    ]
  },
  "input_sha256": "sha256:7c22d5c726aa5305a3a73c47f3a56bb1a901b8f03029821c99785bf7cec61247",
  "contract_sha256": "sha256:d81565c11dbedf270cc7200b7c0ca8faef2aa320bae14964295a97fbafa1c9ad"
}
```

Ghi chú áp dụng hợp đồng: trong lúc làm U3, AI chạy `flutter pub get`, `flutter analyze` và `flutter test` bằng Flutter Linux 3.41.5 trong WSL. Vì vậy người dùng **không build trên Windows trong lúc U3 đang được sinh code**. Khi U3 xong, người dùng chạy `flutter pub get` trên Windows rồi mới build. Không có CI, nên "Run in CI before merge" được đáp ứng bằng lệnh kiểm chứng `flutter analyze && flutter test --coverage` ở checkpoint của unit. Lớp "API / endpoint" không áp dụng.

## Quy ước

- Brownfield: sửa file tại chỗ, không tạo bản sao `_modified`.
- Màu lấy từ `GemTheme` (U4 đã làm), không tạo `VictoryColors` (unit-of-work: "Nếu U4 làm trước U3, U3 dùng thẳng `GemTheme`").
- Mọi `catch` đều log (`GjLog`) và có fallback; lỗi phát âm thanh không bị nuốt im lặng (FR13.3, DoD-4).
- Chuỗi UI chỉ tiếng Anh. Nút có vùng chạm ≥ 48dp (DoD-3).
- Không thêm dependency mới.
- Quy tắc ván chơi (tính điểm, xóa dòng, thắng, thua) giữ nguyên (US2.2). Phần kéo-thả chỉ đổi cách hiển thị khối và cách đổi tọa độ thành ô.

## Các bước

### Giai đoạn A — Chuẩn bị

- [x] **Step 1 — Cấu trúc và asset âm thanh.**
  - Tạo âm thanh placeholder (AC8.3.2 cho phép placeholder):
    - `cp assets/sounds/combo.wav assets/sounds/victory.wav`
    - `cp assets/sounds/clear.wav assets/sounds/unlock.wav`
  - `assets/sounds/` đã được khai báo trong `pubspec.yaml`.
  - Thư mục mới: `lib/features/victory/` (models, widgets).
  - Truy vết: FR13.1, AC8.3.2.
- [x] **Step 2 — Xác minh test runner.** Chạy `flutter pub get` rồi `flutter test` trên code hiện tại để có mốc xanh. Lệnh được ghi trong `unit-test-instructions.md`.

### Giai đoạn B — Data model

- [x] **Step 3 — `Sfx`, `VictoryVariant`, `DragLift` — implement.**
  - `lib/core/audio/sfx.dart`: enum `Sfx { place, clear, combo, gameOver, victory, unlock }`, mỗi giá trị có đường dẫn asset (FR13.1).
  - `lib/features/victory/models/victory_variant.dart`: enum `sub | gemUnlock | journeyComplete` và hàm thuần `VictoryVariant.of(JourneyOutcome)` (`journeyCompleted` → `journeyComplete`; có `unlockedGemId` → `gemUnlock`; còn lại → `sub`).
  - `lib/features/game/engine/board_geometry.dart` thêm phần nâng khối:
    - `liftCells = 1.5`: khoảng hở giữa đáy khối và ngón tay, tính bằng số ô.
    - `liftedCenter(pointer, cellSize, block)`: tâm khối đã nâng.
    - `feedbackAnchor(cellSize, block)`: điểm của ngón tay bên trong widget khối đang kéo.
    - `cellFor` nhận thêm `cellSize` và tính ô từ `liftedCenter`.
    - Cả hai hàm dùng cùng công thức, nên khối người chơi thấy và ô preview luôn khớp nhau.
  - Truy vết: FR6.1..FR6.3, FR13.1, [user].
- [x] **Step 4 — Data model: test.**
  - `test/features/victory/victory_variant_test.dart`: ba biến thể; `journeyCompleted` thắng `unlockedGemId`.
  - `test/core/audio/sfx_test.dart`: đủ 6 âm thanh và mỗi asset tồn tại trên đĩa.
  - Sửa `test/features/game/engine/board_geometry_test.dart`:
    - Với khối 1×1, 3×3 và 1×5, cùng một điểm chạm thì ô do `cellFor` trả về khớp với vị trí khối được vẽ (từ `feedbackAnchor`).
    - Khối nằm phía trên ngón tay đúng 1.5 ô.
    - Điểm chạm sát mép dưới bảng đặt được khối ở hàng cuối.

### Giai đoạn C — Repository

- [x] **Step 5 — `ProgressRepository` thêm `sound_muted` — implement.** Key `sound_muted` (bool, mặc định `false`, E3): đọc trong `load()`, giá trị không phải bool thì về mặc định và log. Thêm `soundMuted` và `setSoundMuted(bool)` qua cùng hàng đợi FIFO, có dirty và thử lại (C5). Truy vết: FR13.2, AC5.3.2, C5, E3.
- [x] **Step 6 — Repository: test.** Bổ sung `progress_repository_test.dart`: thiếu key → `false`; đọc `true`; không phải bool → `false` và có log; ghi rồi đọc lại qua một repository mới (AC5.3.2); ghi lỗi → dirty → ghi lại; chế độ chỉ đọc không ghi.

### Giai đoạn D — Business logic

- [x] **Step 7 — `AudioController`, `GameFeedback`, `LevelGameController` — implement.**
  - `lib/core/audio/audio_controller.dart` viết lại thành class instance (`ChangeNotifier`):
    - Nhận `ProgressRepository` và một `SfxPlayer` tiêm được (mặc định bọc `audioplayers`).
    - API: `isMuted`, `setMuted(bool)` (lưu qua `setSoundMuted`), `play(Sfx)`, `stopSfx()`.
    - Khi mute thì không gọi player (AC5.3.3).
    - Lỗi phát được log bằng `GjLog` với tên âm thanh và `err.runtimeType`, không ném ra (FR13.3).
    - Bỏ API static và player nhạc nền không dùng.
  - `AppServices` thêm `audio`. `AppBootstrap` dựng `AudioController` sau `ProgressRepository.load()`. `main.dart` bỏ `AudioController.init()`.
  - `GameFeedback` thêm `victory()`, `unlock()`, `stopSfx()`. `DeviceGameFeedback` nhận `AudioController` qua constructor.
  - `LevelGameController`:
    - Khi vào `won`: gọi `feedback.victory()`. Với `gemUnlock` hoặc `journeyComplete`, thêm `feedback.unlock()` sau 600ms (FR6.2, interaction-spec).
    - `continueAfterWin()`: khóa sau lần bấm đầu, hủy hẹn giờ unlock, gọi `stopSfx()` (AC3.1.3, interaction-spec "Ngắt hiệu ứng").
    - Thêm `victoryVariant`.
    - `continueAfterWin()` bị bỏ qua ở biến thể `journeyComplete` (AC3.3.2).
    - `dispose` hủy hẹn giờ.
  - Truy vết: FR6.1, FR6.2, FR13.1..FR13.3, AC3.1.2, AC3.1.3, AC3.2.1, AC3.3.2, AC5.3.2, AC5.3.3, C5.
- [x] **Step 8 — Business logic: test.**
  - `test/core/audio/audio_controller_test.dart` (dùng `FakeSfxPlayer`):
    - Phát đúng asset.
    - Khi mute, cả 6 âm thanh không gọi player lần nào (AC5.3.3).
    - `setMuted` lưu và được đọc lại sau khi khởi động lại (AC5.3.2).
    - Player ném lỗi thì có log và không ném ra.
    - `stopSfx` gọi player.
  - Sửa `test/features/journey/level_game_controller_test.dart`:
    - Thắng level con thì `victory` một lần, không có `unlock`.
    - Thắng Bling thì `unlock` sau 600ms (dùng `fakeAsync`).
    - CONTINUE trước 600ms thì hủy `unlock` và gọi `stopSfx`.
    - CONTINUE hai lần chỉ chuyển level một lần.
    - Level 36: `continueAfterWin` không làm gì.
  - `test/features/game/services/game_feedback_test.dart`: `DeviceGameFeedback` chuyển đúng `Sfx` cho `AudioController`.

### Giai đoạn E — Frontend

- [x] **Step 9 — Màn Victory, Settings và kéo-thả — implement.**
  - `lib/features/victory/widgets/victory_overlay.dart` — `VictoryOverlay`, thay Victory tạm trong `game_screen.dart`:
    - Ảnh nền của level, rõ nét, vuông, rộng 85%, có glow màu `primary` (`LevelBackground` với overlay `none`).
    - `sub` (M-4): "Level Complete!", "Congratulations! <Sub> Completed!", `"<score> / <target> · BEST <best>"`, CONTINUE (`GemPrimaryButton`, autofocus).
    - `gemUnlock` (M-5): thêm `GemUnlockAnimation` (icon đá 2D: scale 0→1, xoay 360°, shimmer 1.5s) và "🎉 <Gem> Unlocked!".
    - `journeyComplete` (M-5a): 6 viên đá lần lượt sáng lên, "🎉 Ruby Unlocked!", "JOURNEY COMPLETE!", "You have collected all 6 gems", chỉ có BACK TO MENU, không có CONTINUE (AC3.3.1, AC3.3.2).
    - Vào màn bằng fade 400ms (500ms ở `journeyComplete`) với `Curves.easeInOut`. Hiệu ứng chính 2–3 giây (FR6.4, AC3.4.1).
    - CONTINUE hiện và bấm được ngay (AC3.1.3, AC3.2.3).
    - Tiêu đề có `Semantics(header: true)`. Chữ đủ để hiểu kết quả khi tắt âm thanh (AC3.4.2).
  - `lib/features/victory/widgets/confetti_layer.dart` — `ConfettiLayer`: hạt bay từ dưới lên bằng màu `primary`, `secondary` và trắng, chạy 2.5 giây rồi dừng. `MediaQuery.disableAnimations` bật thì bỏ confetti và xoay, chỉ giữ fade (interaction-spec, Reduced motion).
  - Settings ở Home: công tắc Sound Effects dùng `services.audio.isMuted` / `setMuted` (AC5.3.2).
  - Kéo-thả theo [user]:
    - `GameScreen` truyền kích thước ô của bảng (`BoardGeometry.cellSize`) xuống `BlockPalette` và `DraggableBlock`.
    - Khối đang kéo được vẽ bằng **đúng kích thước ô trên bảng**.
    - `dragAnchorStrategy` dùng `BoardGeometry.feedbackAnchor`, để khối nằm phía trên ngón tay 1.5 ô và căn giữa theo chiều ngang.
    - `_onDragUpdate` và `_onDragEnd` truyền `cellSize` vào `cellFor`.
    - Khối trong khay giữ kích thước nhỏ như cũ.
  - Truy vết: FR6.1..FR6.4, AC3.1.1, AC3.1.3, AC3.2.1..AC3.2.3, AC3.3.1, AC3.3.2, AC3.4.1, AC3.4.2, AC5.3.2, [user].
- [x] **Step 10 — Frontend: widget test.**
  - `test/features/victory/victory_overlay_test.dart`:
    - W-4: đủ chữ, BEST, CONTINUE ≥ 48dp và có focus.
    - W-5: có "Amethyst Unlocked!" và animation đá.
    - W-5a: có "JOURNEY COMPLETE!" và BACK TO MENU, **không** có CONTINUE (AC3.3.2).
    - Bấm CONTINUE hai lần chỉ gọi callback một lần.
    - Bật reduced motion thì không có `ConfettiLayer`.
    - `ConfettiLayer` dừng sau 2.5 giây.
  - Sửa `test/ui/game_screen_test.dart`:
    - Thắng thì hiện `VictoryOverlay` đúng biến thể.
    - CONTINUE sang level kế tiếp.
    - Level 36 có BACK TO MENU để về màn trước.
    - Kéo khối: khối đang kéo nằm phía trên ngón tay, có kích thước ô của bảng, và preview hiện ở đúng ô dưới khối, không phải ô dưới ngón tay.
  - Sửa `test/ui/splash_home_test.dart`: tắt Sound Effects thì `sound_muted` được ghi là `true`, mở lại Settings thì công tắc vẫn tắt.
  - Cập nhật `ui_test_helpers.dart` và các test dựng `AppServices`.

### Giai đoạn F — Cấu hình và tài liệu

- [x] **Step 11 — Environment/build configuration.** Kiểm tra `assets/sounds/victory.wav` và `unlock.wav` có trong bundle. Chạy `dart format` **chỉ cho các file U3 tạo hoặc sửa** và `flutter analyze` sạch.
- [x] **Step 12 — Tài liệu và truy vết.**
  - Chạy `flutter analyze && flutter test --coverage`.
  - Kiểm tra coverage ≥ 80% cho mọi file U3 tạo hoặc sửa (DoD-2), gồm `audio_controller.dart` (U4 để ở 66.7%).
  - Viết `code-summary.md`, `source-manifest.json` và `traceability.json`.
  - Nhắc người dùng chạy `flutter pub get` trên Windows trước khi build.

## Ma trận truy vết

| Yêu cầu / AC | Bước |
|--------------|------|
| FR6.1, AC3.1.1, AC3.1.3 | 3, 4, 7, 8, 9, 10 |
| FR6.2, AC3.2.1..AC3.2.3 | 3, 4, 7, 8, 9, 10 |
| FR6.3, AC3.3.1, AC3.3.2 | 3, 4, 7, 8, 9, 10 |
| AC3.3.3 | đã làm ở U2 (`JourneyController`), kiểm lại ở 8 |
| FR6.4, AC3.4.1, AC3.4.2 | 9, 10 |
| FR13.1, AC8.3.2 | 1, 3, 4, 11 |
| FR13.2, AC5.3.2 | 5, 6, 7, 8, 9, 10 |
| FR13.3, AC5.3.3, AC3.1.2 | 7, 8 |
| [user] kéo khối phía trên ngón tay | 3, 4, 9, 10 |

## Assumptions & Open Questions

- [assumption] `victory.wav` và `unlock.wav` là bản sao của `combo.wav` và `clear.wav`. Người dùng thay bằng âm thanh thật sau, giữ nguyên tên file.
- [assumption] Khoảng nâng khối là 1.5 ô và được đặt bằng một hằng số (`BoardGeometry.liftCells`), để chỉnh sau khi thử trên máy thật.
- [assumption] Khối đang kéo được vẽ bằng kích thước ô trên bảng, để preview và khối trùng nhau tuyệt đối. Khối trong khay giữ kích thước nhỏ như cũ.
- [assumption] Ở level 36, BACK TO MENU quay về Home. Chế độ endless (State C của Home) thuộc U6.
- [assumption] Interaction-spec ghi "unlock phát sau khi victory kết thúc (hoặc sau 600ms)". U3 dùng mốc cố định 600ms vì không đọc được độ dài file âm thanh một cách tin cậy.
- [assumption] Tiêu đề dialog QUIT đã được đổi sang Montserrat theo yêu cầu của người dùng (sửa sau U4). U3 không đổi lại.
