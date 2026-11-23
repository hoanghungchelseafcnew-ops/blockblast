# Kế hoạch Code Generation — U6 `u6-endless-mode`

## Sources

- [units] `inception/units-generation/unit-of-work.md` (U6: `EndlessGameController` bắt đầu với `endless_saved_score` trên bảng trống, lưu khi QUIT, về Home hoặc paused, thua thì đặt về 0 và cập nhật `endless_high_score`; biến thể endless của header, quit dialog và game over; Home State C "Journey Complete" với "Endless · Best N"; chỉ hiệu lực khi `journeyCompleted = true`) và `unit-of-work-story-map.md` (U6: US4.1 → US4.2 → US4.3 → US4.4)
- [contract] `inception/contract-design/contract-summary.md`:
  - C5: `endlessState`, `saveEndlessState`.
  - E3: key `endless_saved_score`, `endless_high_score`.
  - C1: `journeyCompleted`.
  - E2 `x-rules`: endless không gửi event `level_*`.
- [req] `inception/requirements-analysis/requirements.md`: FR9.1..FR9.8, FR4.4
- [stories] `inception/user-stories/stories.md`: AC4.1.1, AC4.1.2, AC4.2.1..AC4.2.3, AC4.3.1, AC4.3.2, AC4.4.1..AC4.4.3, AC6.3.2
- [mock] `inception/refined-mockups/mockups.md` (M-1 State C, M-2e, M-2a bản endless, M-3e) và `interaction-spec.md` (QuitDialog `mode: level | endless`; LevelProgressBar ẩn ở endless; app vào background ở M-2e thì lưu `endless_saved_score`)
- [code] Code hiện có: `BoardEngine`, `GameScreen` (kéo-thả đã nâng khối ở U3), `QuitDialog`, `GameOverOverlay`, `HomeScreen`, `ProgressRepository`, `JourneyController.journeyCompleted`, `GemTheme`, `LevelBackground`, `SessionTracker`
- [user] Người dùng chọn làm tiếp U6 mà không chạy lại các stage thiết kế; các quy tắc endless được viết thành mục riêng bên dưới để duyệt (tin nhắn `f93f215d`)
- [prac] `aidlc/spaces/default/memory/team.md`: test-after, coverage ≥ 80%, logic trong controller/service, UI chỉ tiếng Anh

U6 không có artifact functional design riêng, vì các stage thiết kế đã bị đánh dấu `[S]` do một lần nhảy stage trước đây. Mục "Quy tắc endless" dưới đây thay cho phần business rules.

## Quy tắc endless (thay cho functional design)

| # | Quy tắc | Nguồn |
|---|---------|-------|
| ER1 | Chỉ vào endless khi `journeyCompleted = true`. Home bấm PLAY thì mở màn endless thay vì level. | FR9.1, AC4.1.2 |
| ER2 | Ván endless bắt đầu với **điểm = `endless_saved_score`**, **bảng trống** và khay mới. Combo bắt đầu từ 0. | FR9.2, FR9.3, AC4.2.2 |
| ER3 | Tính điểm, xóa dòng và combo giống hệt chế độ level. Không có target, không có thanh tiến độ, không có Victory. | FR9.1, AC4.1.2 |
| ER4 | QUIT trong dialog ("Quit? Your score will be saved.") thì lưu `endless_saved_score = score` rồi về Home. CANCEL thì chơi tiếp. Điểm 0 cũng được lưu, không lỗi. | FR9.2, FR9.6, AC4.2.1, AC4.2.3, AC4.4.2 |
| ER5 | App vào nền (`paused`) khi đang chơi endless thì lưu `endless_saved_score = score`. Ván vẫn giữ trong bộ nhớ. | FR9.2, interaction-spec |
| ER6 | Hết nước đi thì **thua**: `endless_saved_score = 0`. PLAY AGAIN bắt đầu ván mới từ 0. | FR9.4, AC4.3.1 |
| ER7 | `endless_high_score = max(cũ, score)` được cập nhật khi thua, khi QUIT và khi app vào nền. Không bao giờ giảm. | FR9.5, AC4.3.2 |
| ER8 | Header: [←], "Endless", "SCORE n" và "BEST n" (BEST là `endless_high_score`, hoặc điểm hiện tại nếu cao hơn). | FR9.6, AC4.4.1 |
| ER9 | Game Over: FINAL SCORE, BEST, PLAY AGAIN, SHARE SCORE, BACK TO MENU. **Không** có Target hay dòng "You will return to…". | FR9.7, AC4.4.3 |
| ER10 | Không gửi `level_start`, `level_complete`, `level_fail`. `game_session` vẫn được gửi như cũ (`SessionTracker`). | FR4.4, FR9.8, AC6.3.2 |
| ER11 | Nền và màu dùng Ruby · Bling (level 36). | FR9.8 |
| ER12 | Home State C: 6 viên đá xếp ngang, "Journey Complete", phụ đề "Endless · Best N" (hiện "Endless · Best —" khi BEST = 0), nút PLAY. | M-1 State C, AC4.1.1 |
| ER13 | `endless_saved_score` / `endless_high_score` thiếu, âm hoặc sai kiểu thì về 0 và log (E3). | E3 |
| ER14 | Back trong lúc animation xóa dòng: giống chế độ level (mở dialog, QUIT dừng lượt). Đang lưu thì back bị bỏ qua. | FR11.2, BR5.4 |

Rủi ro đã chấp nhận: app bị kill mà không qua `paused` (ví dụ crash) thì mất phần điểm kể từ lần lưu gần nhất.

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

Ghi chú áp dụng hợp đồng: AI chạy `flutter analyze` và `flutter test` bằng Flutter Linux 3.41.5 trong WSL. Người dùng không build trên Windows cho tới khi U6 xong, sau đó chạy `flutter pub get` trên Windows. Không có CI, nên "Run in CI before merge" được đáp ứng bằng lệnh kiểm chứng `flutter analyze && flutter test --coverage` ở checkpoint của unit. Lớp "API / endpoint" không áp dụng.

## Quy ước

- Brownfield: sửa file tại chỗ.
- Logic endless nằm trong `EndlessGameController` (`ChangeNotifier`). Màn hình chỉ render (team.md).
- Không đổi quy tắc ván chơi của chế độ level. Không thêm dependency.
- Mọi `switch` trên enum trạng thái liệt kê đủ case, không dùng `default`.
- Chuỗi UI chỉ tiếng Anh. Nút có vùng chạm ≥ 48dp.

## Các bước

### Giai đoạn A — Chuẩn bị

- [x] **Step 1 — Cấu trúc.** Thư mục mới `lib/features/endless/` (models, controllers, screens). Không có dependency hay asset mới.
- [x] **Step 2 — Xác minh test runner.** Chạy `flutter test` trên code hiện tại để có mốc xanh. Lệnh được ghi trong `unit-test-instructions.md`.

### Giai đoạn B — Data model

- [x] **Step 3 — `EndlessState`, `EndlessStatus`, điểm bắt đầu của `BoardEngine` — implement.**
  - `lib/features/endless/models/endless_state.dart`: `EndlessState { savedScore, highScore }` bất biến, có `withHighScore(score)` không giảm (ER7).
  - Enum `EndlessStatus { playing, saving, lost, quit }`.
  - `BoardEngine.reset({int startScore = 0})`: bảng trống, khay mới, điểm bắt đầu là `startScore` (ER2). Mặc định 0, nên chế độ level không đổi.
  - Truy vết: ER2, ER7, C5, E3.
- [x] **Step 4 — Data model: test.**
  - `test/features/endless/endless_state_test.dart`: `withHighScore` tăng hoặc giữ; giá trị mặc định.
  - Bổ sung `board_engine_test.dart`: `reset(startScore: 1200)` thì bảng trống, điểm 1200, combo 0; `reset()` vẫn về 0.

### Giai đoạn C — Repository

- [x] **Step 5 — `ProgressRepository`: `endlessState`, `saveEndlessState` — implement.**
  - Key `endless_saved_score` và `endless_high_score` (int ≥ 0, mặc định 0, E3). Thiếu, âm hoặc sai kiểu thì về 0 và log (ER13).
  - `saveEndlessState(state)` ghi hai key qua cùng hàng đợi FIFO, có dirty và thử lại (C5). Chế độ chỉ đọc giữ giá trị trong bộ nhớ, không ghi.
  - Truy vết: C5, E3, ER4..ER7, ER13.
- [x] **Step 6 — Repository: test.** Bổ sung `progress_repository_test.dart`:
  - Thiếu key → 0 / 0.
  - Đọc đúng giá trị đã lưu; giá trị âm hoặc sai kiểu → 0 và có log.
  - Lưu rồi đọc lại sau khi khởi động lại.
  - Lưu 0 không lỗi (AC4.2.3).
  - Ghi lỗi → dirty → ghi lại; chế độ chỉ đọc không ghi.

### Giai đoạn D — Business logic

- [x] **Step 7 — `EndlessGameController` — implement.**
  - `lib/features/endless/controllers/endless_game_controller.dart`, dùng `BoardEngine` và `GameFeedback` như chế độ level:
    - `start()`: bắt đầu từ `endlessState.savedScore`, bảng trống (ER2).
    - `onDragStart`, `updatePreview`, `cancelDrag`, `placeAt` cùng quy tắc như chế độ level. Input bị bỏ qua khi không `playing` hoặc đang xóa dòng (ER3, ER14).
    - Hết nước đi → `saving`, rồi lưu `savedScore = 0` và `highScore = max`, rồi `lost`; gọi `feedback.gameOver()` (ER6, ER7).
    - `requestBack()` và `needsQuitConfirmation` như chế độ level. `confirmQuit()` → `saving`, lưu `savedScore = score` và high score, rồi `quit` (ER4, ER7). Trả về một `Future` hoàn tất sau khi lưu xong.
    - `saveOnPause()`: khi đang `playing` thì lưu `savedScore = score` và high score, giữ nguyên ván (ER5).
    - `playAgain()` khi `lost`: ván mới từ 0 (ER6).
    - `bestScore = max(highScore đã lưu, score)` (ER8).
    - Lưu lỗi thì log, không ném ra, trạng thái vẫn chuyển tiếp.
    - **Không** nhận `AnalyticsService` nên không thể gửi event level (ER10).
  - `GameFeedback` không đổi.
  - Truy vết: FR9.1..FR9.5, FR9.8, ER2..ER7, ER10, ER14, AC4.1.2, AC4.2.1..AC4.2.3, AC4.3.1, AC4.3.2, AC6.3.2.
- [x] **Step 8 — Business logic: test.** `test/features/endless/endless_game_controller_test.dart`:
  - Bắt đầu từ 1200 trên bảng trống (AC4.2.2).
  - Đặt khối cộng điểm như chế độ level.
  - QUIT ở 1200 → `endless_saved_score = 1200` (AC4.2.1).
  - QUIT ở 0 → lưu 0, không lỗi (AC4.2.3).
  - `saveOnPause` lưu điểm và vẫn `playing`.
  - Thua → `saved = 0`, high score tăng; lần sau bắt đầu từ 0 (AC4.3.1, AC4.3.2).
  - High score không giảm khi thua với điểm thấp hơn.
  - PLAY AGAIN từ 0.
  - Input bị bỏ qua khi `lost` hoặc `quit`.
  - Back khi đang lưu bị bỏ qua.
  - Lưu lỗi vẫn sang `lost` hoặc `quit`.

### Giai đoạn E — Frontend

- [x] **Step 9 — Màn endless, Home State C, dialog và Game Over theo mode — implement.**
  - Tách phần bảng, khay và kéo-thả (đổi tọa độ thành ô, khối nâng phía trên ngón tay) khỏi `GameScreen` thành widget `lib/features/game/widgets/board_play_area.dart`. Widget này nhận callback (`onDragStart`, `onPreview`, `onCancel`, `onPlace`, `board`, `tray`). `GameScreen` và màn endless cùng dùng nó, để cách kéo không bị chép hai nơi.
  - `QuitDialog` thêm tham số `mode` (`level | endless`): endless hiện tiêu đề "Quit?" kèm dòng "Your score will be saved." (ER4, AC4.4.2).
  - `GameOverOverlay` thêm biến thể endless: FINAL SCORE, BEST, PLAY AGAIN, SHARE SCORE, BACK TO MENU, không có Target và dòng quay về (ER9, AC4.4.3).
  - `lib/features/endless/screens/endless_game_screen.dart`:
    - Header [←], "Endless", "SCORE n", "BEST n". Không có target hay thanh tiến độ (ER8, AC4.4.1).
    - Nền `LevelBackground` của level 36 (blur) và màu Ruby (ER11).
    - `PopScope` và [←] mở dialog endless (ER14).
    - Observer vòng đời gọi `saveOnPause` khi `paused` (ER5).
  - `HomeScreen`:
    - Khi `journeyCompleted` thì hiện State C: 6 viên đá, "Journey Complete", "Endless · Best N" hoặc "Endless · Best —" (ER12, AC4.1.1).
    - PLAY mở màn endless (ER1).
    - Quay về Home thì BEST được làm mới.
  - Truy vết: FR9.1, FR9.6, FR9.7, ER1, ER4, ER5, ER8, ER9, ER11, ER12, ER14, AC4.1.1, AC4.1.2, AC4.4.1..AC4.4.3.
- [x] **Step 10 — Frontend: widget test.**
  - `test/features/endless/endless_game_screen_test.dart`:
    - Header có "Endless", SCORE và BEST; không có `game-progress-bar` hay "/".
    - [←] mở dialog "Quit?" với dòng "Your score will be saved."; QUIT lưu điểm và rời màn.
    - Thua thì hiện Game Over endless (FINAL SCORE, BEST, không có Target, không có "You will return to").
    - PLAY AGAIN bắt đầu từ 0.
    - Kéo khối vào bảng ghi điểm, dùng `BoardPlayArea` (khối nằm phía trên ngón tay).
    - App vào nền thì lưu điểm.
    - Không có Victory dù điểm cao.
  - Bổ sung `test/ui/splash_home_test.dart`:
    - Home ở State C khi `journeyCompleted` ("Journey Complete", 6 viên đá, "Endless · Best —" và "Endless · Best 12400").
    - PLAY mở màn endless, bắt đầu với điểm đã lưu.
  - `test/ui/game_screen_test.dart` vẫn xanh sau khi tách `BoardPlayArea` (hồi quy cho kéo-thả ở chế độ level).

### Giai đoạn F — Cấu hình và tài liệu

- [x] **Step 11 — Environment/build configuration.** Không có cấu hình mới. Chạy `dart format` chỉ cho các file U6 tạo hoặc sửa và `flutter analyze` sạch.
- [x] **Step 12 — Tài liệu và truy vết.**
  - Chạy `flutter analyze && flutter test --coverage`.
  - Kiểm tra coverage ≥ 80% cho mọi file U6 tạo hoặc sửa (DoD-2) và ≥ 80% cho toàn codebase.
  - Viết `code-summary.md`, `source-manifest.json` và `traceability.json`.

## Ma trận truy vết

| Yêu cầu / AC | Bước |
|--------------|------|
| FR9.1, AC4.1.1, AC4.1.2, ER1, ER3, ER12 | 7, 8, 9, 10 |
| FR9.2, FR9.3, AC4.2.1..AC4.2.3, ER2, ER4, ER5 | 3..10 |
| FR9.4, FR9.5, AC4.3.1, AC4.3.2, ER6, ER7 | 3..8, 10 |
| FR9.6, FR9.7, AC4.4.1..AC4.4.3, ER8, ER9, ER14 | 9, 10 |
| FR9.8, FR4.4, AC6.3.2, ER10, ER11 | 7, 8, 9 |
| C5, E3, ER13 | 5, 6 |

## Assumptions & Open Questions

- [assumption] BEST trên header là `max(endless_high_score, score)`, giống cách BEST của chế độ level (U2).
- [assumption] `endless_high_score` được cập nhật cả khi QUIT và khi vào nền (FR9.5 ghi "khi game over hoặc khi thoát").
- [assumption] Ở Home State C, "Endless · Best" hiện số không có dấu phân cách hàng nghìn (ví dụ "12400"), giống cách các màn khác đang hiển thị điểm.
- [assumption] Tách `BoardPlayArea` là refactor nhỏ của code U1–U3 để dùng chung cách kéo-thả. Hành vi của chế độ level không đổi, và `game_screen_test.dart` là test hồi quy cho việc này.
