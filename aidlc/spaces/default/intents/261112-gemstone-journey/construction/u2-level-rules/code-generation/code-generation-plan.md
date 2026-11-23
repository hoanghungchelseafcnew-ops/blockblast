# Kế hoạch Code Generation — U2 `u2-level-rules`

## Sources

- [units] `inception/units-generation/unit-of-work.md` (U2: component, ranh giới, DoD-1..DoD-5) và `unit-of-work-story-map.md` (U2: US1.3, US1.4, US1.5, US1.7, US2.5, US2.6, US2.7)
- [contract] `inception/contract-design/contract-summary.md`: C1 (`onLevelLost`, `unlockedGemId`, `journeyCompleted`), C2 (`lost`, `bestScore`), C5 (`highScore`, `saveHighScore`), E3 (`high_scores`, các key cũ bị gỡ)
- [req] `inception/requirements-analysis/requirements.md`: FR2.3..FR2.5, FR8.1..FR8.3, FR11.1..FR11.3
- [stories] `inception/user-stories/stories.md`: AC1.3.1, AC1.4.1..AC1.4.4, AC1.5.1, AC1.7.1, AC1.7.2, AC2.5.1..AC2.5.3, AC2.6.1, AC2.6.2, AC2.7.1
- [u1] Code U1 hiện có: `JourneyController`, `ProgressRepository`, `PlayerProgress`, `JourneyOutcome`, `LevelGameController`, `GameScreen` và các test của chúng
- [prac] `aidlc/spaces/default/memory/team.md`: test-after, coverage ≥ 80%, logic nằm trong controller/service, UI chỉ tiếng Anh

U2 không có artifact functional design, NFR hay infrastructure riêng. Kế hoạch dựa trực tiếp vào contract, requirements và story ở trên.

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

Ghi chú áp dụng hợp đồng: từ phiên 2026-11-18, máy của AI đã có Flutter Linux 3.41.5 (cùng phiên bản với máy người dùng), nên AI tự chạy `flutter analyze` và các lệnh `flutter test` của từng lớp. Không có CI, nên "Run in CI before merge" được đáp ứng bằng lệnh kiểm chứng `flutter analyze && flutter test --coverage` ở checkpoint của unit. Lớp "API / endpoint" không áp dụng (app không có API riêng). Contract nội bộ C1/C2/C5 được xử lý ở lớp business logic và repository.

## Quy ước

- Brownfield: sửa file tại chỗ, không tạo bản sao `_modified`.
- Contract chỉ được **thêm** (contract-summary, "Contract ownership rules"). Các trường U1 giữ nguyên tên và nghĩa.
- Mọi `catch` đều log (`GjLog`) và có fallback (DoD-4). Log không chứa dữ liệu cá nhân.
- Mọi `switch` trên `LevelStatus` liệt kê đủ 5 case, không dùng `default` (C2 `switch_rule`).
- Chuỗi UI mới chỉ tiếng Anh. Nút mới có vùng chạm ≥ 48dp (DoD-3).
- Không thêm dependency mới.

## Các bước

### Giai đoạn A — Chuẩn bị

- [x] **Step 1 — Cấu trúc và cấu hình.** U2 không tạo thư mục hay dependency mới. Mọi thay đổi nằm trong `lib/features/journey/` và `lib/features/game/screens/`, cộng với widget mới ở `lib/features/game/widgets/`. Truy vết: unit-of-work U2.
- [x] **Step 2 — Xác minh test runner.** Chạy `flutter test test/features/journey/` trên code hiện tại để có mốc xanh trước khi sửa. Lệnh được ghi trong `unit-test-instructions.md`.

### Giai đoạn B — Data model

- [x] **Step 3 — Data model: `HighScores` và mở rộng `PlayerProgress` — implement.**
  - Thêm `lib/features/journey/models/high_scores.dart`: map bất biến `levelIndex → score`; `tryParse` từ JSON `{"<levelIndex>": int}`. Bỏ qua key ngoài 1..36, giá trị không phải số nguyên hoặc âm, và trường lạ (E3 R-07). JSON hỏng → `null`, caller dùng rỗng và log. Có `toJsonString()` và `withScore(index, score)` chỉ tăng, không giảm.
  - `PlayerProgress`: không đổi schema. Thêm helper thuần `withoutGem(gemOrder)` để bỏ 6 sub của một gem khỏi `completedLevels` (FR2.3a).
  - Truy vết: FR8.1 (`high_scores`), FR8.3, E3, AC1.7.2.
- [x] **Step 4 — Data model: test.** `test/features/journey/high_scores_test.dart` và bổ sung test `withoutGem`: JSON hợp lệ; JSON hỏng; key ngoài khoảng; giá trị âm, thập phân hoặc chuỗi; trường lạ bị bỏ qua; `withScore` không giảm; `withoutGem` chỉ bỏ đúng 6 sub và giữ các gem khác.

### Giai đoạn C — Repository

- [x] **Step 5 — Repository: `ProgressRepository` thêm `high_scores` và gỡ key cũ — implement.**
  - Key `high_scores` (E3): đọc trong `load()`. Hỏng → rỗng cho riêng key này và log. `highScore(levelIndex)` trả giá trị thật. `saveHighScore(levelIndex, score)` cập nhật cache nếu cao hơn rồi xếp vào cùng hàng đợi FIFO. Dirty, thử lại và chế độ chỉ đọc giống `progress` (C5 `write_failure_recovery`).
  - `ProgressStore` thêm `remove(String key)`. `SharedPreferencesProgressStore` và `FakeProgressStore` triển khai hàm này.
  - Gỡ key cũ mỗi lần khởi động, idempotent, trong hàng đợi sau `load()`: `high_score` và `high_score_time`. Lỗi gỡ chỉ log, không đánh dấu dirty. `theme_index` và `last_login_date` **chưa gỡ** vì `ThemeManager` và Daily Gift vẫn dùng chúng cho tới U4 (xem Assumptions).
  - Truy vết: C5 (`highScore`, `saveHighScore`), E3 (`high_scores`, `legacy_keys_removed_on_every_start`), FR8.1, FR8.3, AC1.7.2.
- [x] **Step 6 — Repository: test.** Bổ sung `test/features/journey/progress_repository_test.dart`: `high_scores` thiếu hoặc hỏng → rỗng; đọc đúng giá trị; `saveHighScore` thấp hơn không ghi; FIFO giữa `progress` và `high_scores`; ghi `high_scores` lỗi → dirty → ghi lại ở lần ghi sau; `flushDirty` ghi `high_scores`; chế độ chỉ đọc bỏ qua `saveHighScore`; key cũ bị gỡ và lỗi gỡ không làm hỏng hàng đợi.

### Giai đoạn D — Business logic

- [x] **Step 7 — Business logic: `JourneyController` — implement.**
  - `onLevelWon(level, score)`:
    - Lưu high score qua `saveHighScore`.
    - Thắng Bling của gem 1–5: thêm gem vào `unlockedGems`, sang Rough Stone của gem kế tiếp, outcome có `unlockedGemId` (FR2.5, AC1.3.1).
    - Thắng level 36: `journeyCompleted = true`, `unlockedGems` có `ruby`, `nextLevel = null`, outcome có `unlockedGemId = 'ruby'` và `journeyCompleted = true` (C1).
    - `highestLevelReached` không bao giờ giảm.
  - Thêm `onLevelLost(level, score)`: `currentLevelIndex` = Rough Stone của gem đang chơi; bỏ 6 sub của gem đó khỏi `completedLevels`; giữ `unlockedGems`, `highestLevelReached` và high score cũ; lưu high score mới nếu cao hơn. Trả `JourneyOutcome` với `nextLevel` = Rough Stone đó. Hoàn tất sau khi ghi xong hoặc ghi lỗi, không bao giờ throw (C1 `errors`). Truy vết: FR2.3, FR2.3a, FR2.3b, FR2.4, AC1.4.1..AC1.4.4, AC1.5.1.
  - Getter `journeyCompleted` đọc từ tiến trình. Thêm `bestScoreFor(level)`.
  - Thêm `lostOutcomeFor(level)` tính từ cache (dùng khi hết thời gian chờ).
- [x] **Step 8 — Business logic: test cho `JourneyController`.** Bổ sung `test/features/journey/journey_controller_test.dart`:
  - Thắng Bling Rose Quartz mở khóa gem và sang Amethyst · Rough Stone; thắng level 36 thì journey complete.
  - Thua ở Amethyst · Shaping về Amethyst · Rough Stone, mất Rough Stone/Slabbing của Amethyst, giữ 6 sub của Rose Quartz (AC1.4.1, AC1.4.2).
  - Thua ở Rough Stone thì ở lại (AC1.4.3, AC1.4.4).
  - `highestLevelReached` không giảm; high score cập nhật khi thắng và khi thua, không giảm khi điểm thấp hơn.
  - Ghi lỗi vẫn trả outcome và không throw.
  - Kiểm tra chuyển level cho cả 36 level, gồm 5 lần chuyển gem (FR2.5 Pass).
- [x] **Step 9 — Business logic: `LevelGameController` — implement.**
  - Hết nước đi khi `score < target`: `playing → resolving → lost`, gọi `onLevelLost` với cùng cơ chế chờ (timeout 3s, ADR-008). Khi hết thời gian, `outcome` lấy từ `lostOutcomeFor`. Một round chỉ xử lý thua một lần (C2 invariant).
  - Bỏ REVIVE (FR11.3, AC2.6.2): xóa `revive`, `canRevive`, `revived`. Gỡ hàm `clearCenter` khỏi `BoardEngine` nếu không còn nơi nào dùng.
  - `playAgain()` (khi `lost`): bắt đầu round mới ở `outcome.nextLevel` (Rough Stone). `backToMenu` cũng không đổi gì thêm vì tiến trình đã được lưu (AC1.5.1).
  - `bestScore` = `max(high score đã lưu lúc start, score hiện tại)` (C2, AC1.7.1).
  - Thêm `returnLevel` (Rough Stone của gem đang chơi) để overlay hiển thị (FR2.4).
  - QUIT: `requestBack()` khi `playing` không còn thoát ngay. Controller có `confirmQuit()` (sang `quit`, không gọi `onLevelLost`). UI hỏi bằng dialog. Trong lúc `resolving` thì back vẫn bị bỏ qua (FR11.2, AC2.5.1..AC2.5.3).
  - Truy vết: C2 (`lost`, `bestScore`), FR2.2, FR2.3, FR11.2, FR11.3, US2.5, US2.6.
- [x] **Step 10 — Business logic: test cho `LevelGameController`.** Sửa `test/features/journey/level_game_controller_test.dart`:
  - Thay các test REVIVE bằng test thua mới: thua thì gọi `onLevelLost` một lần và đặt `lost` với outcome là Rough Stone.
  - Thắng vẫn ưu tiên hơn hết nước đi trong cùng lượt.
  - Timeout 3s khi thua dùng outcome từ cache.
  - PLAY AGAIN bắt đầu ở Rough Stone với `roundId` mới.
  - `bestScore` lấy từ high score đã lưu và tăng theo điểm.
  - Back khi `playing` không thoát; `confirmQuit` thì thoát mà không đổi tiến trình; back khi `resolving` bị bỏ qua.
  - Input bị bỏ qua khi `lost`.

### Giai đoạn E — Frontend

- [x] **Step 11 — Frontend: `QuitDialog`, Game Over mới, BEST trên header — implement.**
  - `lib/features/game/widgets/quit_dialog.dart`: tiêu đề "Quit this level?", nút CANCEL (autofocus) và QUIT, mỗi nút ≥ 48dp. `PopScope` và nút [←] mở dialog khi `playing`. QUIT gọi `confirmQuit()` rồi rời màn.
  - `lib/features/game/widgets/game_over_overlay.dart`: hiển thị FINAL SCORE, "Target: N", "You will return to <Gem> · Rough Stone", PLAY AGAIN, SHARE SCORE và BACK TO MENU. Không có REVIVE (AC2.6.1, AC2.6.2, AC2.7.1).
  - `GameScreen`: dùng hai widget trên; header thêm "BEST N" khi `bestScore > 0` (FR11.1, AC1.7.1).
  - Truy vết: FR11.1..FR11.3, US2.5, US2.6, US2.7, DoD-3.
- [x] **Step 12 — Frontend: widget test.** Sửa `test/ui/game_screen_test.dart` và thêm test cho widget mới:
  - Back hoặc [←] khi `playing` mở dialog với CANCEL và QUIT; CANCEL giữ nguyên điểm; QUIT về màn trước mà không gọi `onLevelLost`.
  - Game Over có Target, dòng "You will return to …", không có REVIVE; PLAY AGAIN bắt đầu ở Rough Stone; SHARE gọi share service.
  - Header hiện BEST khi có high score.
  - Các nút mới ≥ 48dp.
  - Sửa `test/ui/legacy_widgets_test.dart` hoặc `ui_test_helpers.dart` nếu chúng tham chiếu REVIVE.

### Giai đoạn F — Cấu hình và tài liệu

- [x] **Step 13 — Environment/build configuration.** Không có thay đổi cấu hình build hay nền tảng. Chạy `dart format` cho các file đã sửa và `flutter analyze` sạch.
- [x] **Step 14 — Tài liệu và truy vết.** Chạy `flutter analyze && flutter test --coverage` và kiểm tra coverage ≥ 80% cho mọi file U2 tạo hoặc sửa (DoD-2) trong `coverage/lcov.info`. Viết `code-summary.md`, `source-manifest.json` và `traceability.json`.

## Ma trận truy vết

| Yêu cầu / AC | Bước |
|--------------|------|
| FR2.3, FR2.3a, FR2.4, AC1.4.1..AC1.4.4 | 3, 4, 7, 8 |
| FR2.3b, AC1.7.2 | 3, 4, 5, 6, 7, 8 |
| FR2.5, AC1.3.1 | 7, 8 |
| AC1.5.1 | 7, 8, 9, 10 |
| AC1.7.1, FR11.1 | 9, 10, 11, 12 |
| FR11.2, AC2.5.1..AC2.5.3 | 9, 10, 11, 12 |
| FR11.3, AC2.6.1, AC2.6.2 | 9, 10, 11, 12 |
| AC2.7.1 | 11, 12 |
| FR8.1, FR8.3, E3 | 3, 4, 5, 6 |
| C1, C2, C5 | 5, 7, 9 |

## Assumptions & Open Questions

- [assumption] E3 yêu cầu gỡ `theme_index` và `last_login_date` mỗi lần khởi động. U2 chỉ gỡ `high_score` và `high_score_time`, vì `ThemeManager` và Daily Gift vẫn đọc hai key kia cho tới khi U4 gỡ chúng (unit-of-work U4). Gỡ sớm sẽ làm mất theme đã chọn và hiện lại Daily Gift mỗi lần mở app.
- [assumption] Thắng level 36 trả `unlockedGemId = 'ruby'` cùng `journeyCompleted = true`, vì FR6.3 (W-5a) dùng lại hiệu ứng unlock của W-5. U3 quyết định cách hiển thị.
- [assumption] High score được cập nhật khi thắng và khi thua (AC1.7.2), không cập nhật khi QUIT.
- [assumption] Sau khi thua, PLAY AGAIN bắt đầu ở Rough Stone của gem đang chơi (FR2.3 áp dụng cho cả PLAY AGAIN lẫn BACK TO MENU).
