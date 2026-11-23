# Code Generation Plan: u3-tray-algorithm

Nguồn: functional-spec.md, rules.md, entities.md (functional-design), nfr-requirements/*, security-design.md, logical-components.md (nfr-design), cicd-pipeline.md (infrastructure-design), unit-of-work.md (U3), requirements.md (FR4, NFR1–NFR7), stories.md (US4.1–US4.6). Brownfield, sửa tại chỗ. Mã mới nằm ngoài widget; chuỗi UI không đổi.

## Quyết định thiết kế mã

- **Bộ giải trên bitmask.** Bảng được rút gọn thành 8 số nguyên (mỗi hàng 8 bit), chỉ gồm trạng thái ô đã lấp. Đặt khối rồi xóa các hàng và cột đầy. Hiệu ứng bom và băng không mô phỏng: bom chỉ làm trống thêm ô, băng không chặn việc xóa dòng trong `BoardLogic`, nên bỏ qua chỉ làm bộ giải bảo thủ hơn thực tế, không làm sai kết luận "đặt hết được".
- **Tích hợp qua `BoardEngine`.** `BlockSource` (typedef hiện có) giữ nguyên để test cũ dùng khay cố định. Khi không truyền `blockSource`, engine dùng `TrayGenerator` với `difficultyLevel` hiện tại. Khi `TrayResult.gameOver`, nguồn trả khay rỗng; `hasMoves` của engine đã trả false cho khay rỗng nên luồng Game Over hiện có của hai controller chạy tiếp, không cần nhánh mới.
- **Level.** `LevelGameController.start` gán `engine.difficultyLevel = level.levelIndex` trước `reset()`; `EndlessGameController.start` gán `DifficultyConstants.endlessLevel` (18).
- **`BlockGenerator` bị thay.** Hình và màu chuyển sang `BlockCatalog`; `block_generator.dart` bị xóa vì không còn nơi nào dùng (chỉ `BoardEngine` import).

## Các bước

- [ ] **Step 1. Cấu trúc và cấu hình.** Không thêm gói hay quyền (NFR7.2, NFR5.1). Các file mới nằm trong `lib/features/game/logic/` và `test/features/game/logic/`.
- [ ] **Step 2. Xác nhận bộ chạy test.** `flutter_test` đã có; lệnh theo unit ghi trong `unit-test-instructions.md`.
- [ ] **Step 3. Mô hình dữ liệu: implement.**
  - `lib/features/game/logic/difficulty_constants.dart`: `DifficultyConstants` (mọi hằng số trong entities.md, BR5.1).
  - `lib/features/game/logic/tray_models.dart`: `TrayRates`, `SolvabilityTier { strict, relaxed, fallback }`, `TrayResult { tray, tier, gameOver }` (BR1.1: khay trả về là danh sách không đổi `List.unmodifiable`).
  - `lib/features/game/logic/block_catalog.dart`: `BlockCatalog` với 8 hình nhỏ, 10 hình vừa, 7 hình lớn và 7 màu chuyển từ `block_generator.dart`, giữ nguyên giá trị (BR5.3, AC4.6.3); hàm `isLarge(shape)`.
- [ ] **Step 4. Mô hình dữ liệu: viết và chạy test.** `test/features/game/logic/block_catalog_test.dart` (số hình và màu không đổi, nhóm kích thước) (US4.6).
- [ ] **Step 5. Business logic: implement `DifficultyProfile`.** `lib/features/game/logic/difficulty_profile.dart`: `ratesFor(level, filledCells)` theo BR2.3, BR3.1, BR3.2; kẹp level 1..36; `medium'` kẹp về 0.
- [ ] **Step 6. Business logic: test `DifficultyProfile`.** `test/features/game/logic/difficulty_profile_test.dart` (US4.2.3, US4.3, US4.4).
- [ ] **Step 7. Business logic: implement `TraySolver`.** `lib/features/game/logic/tray_solver.dart`: mask hàng, đặt và xóa dòng, DFS có ngân sách `NodeBudget`, trả `SolveOutcome { solvable, unsolvable, unknown }`, chế độ strict (6 thứ tự) và relaxed (một thứ tự), thứ tự vị trí tất định, ưu tiên vị trí xóa dòng (BR1.2, BR1.3, BR5.2, BR5.4).
- [ ] **Step 8. Business logic: test `TraySolver`.** `test/features/game/logic/tray_solver_test.dart`: bảng trống, bảng gần đầy, đối chiếu với bộ vét cạn trong test, ngân sách cạn trả `unknown`, tất định.
- [ ] **Step 9. Business logic: implement `TrayGenerator`.** `lib/features/game/logic/tray_generator.dart`: `prepare(board, level)` theo luồng ở functional-spec (strict → relaxed → fallback 1×1 → Game Over); sinh khối với khối cứu, nhóm kích thước, tối đa 2 khối lớn, băng 5%, bom 5%; `Random` tiêm vào; bọc try/catch và `GjLog` khi bộ giải ném lỗi (BR1.1–BR1.5, BR2.x, BR3.x, BR5.x, NFR2.2).
- [ ] **Step 10. Business logic: test `TrayGenerator`.** `test/features/game/logic/tray_generator_test.dart`: tier strict trên bảng trống, hạ tier, fallback, Game Over khi bảng đầy, khay bất biến, khối cứu, tối đa 2 khối lớn, test thuộc tính trên nhiều seed (bảng ngẫu nhiên có từ 3 ô trống không Game Over), tất định theo seed, thời gian chuẩn bị (NFR1, đo thô).
- [ ] **Step 11. Tích hợp engine và controller: implement.**
  - `lib/features/game/engine/board_engine.dart`: thêm `int difficultyLevel`, tham số `TrayGenerator? trayGenerator`, nguồn mặc định gọi `prepare` và trả khay rỗng khi Game Over; bỏ import `block_generator.dart`.
  - `lib/features/journey/controllers/level_game_controller.dart`: gán `difficultyLevel` ở `start` (hàm `start` có `level`).
  - `lib/features/endless/controllers/endless_game_controller.dart`: gán `DifficultyConstants.endlessLevel` ở `start`.
  - Xóa `lib/features/game/logic/block_generator.dart`.
- [ ] **Step 12. Tích hợp: viết và chạy test.** Mở rộng `test/features/game/engine/board_engine_test.dart` (mặc định dùng TrayGenerator, khay rỗng khi Game Over, test cũ vẫn dùng `blockSource`), `test/features/journey/level_game_controller_test.dart` và `test/features/endless/endless_game_controller_test.dart` (engine nhận đúng `difficultyLevel`: level hiện tại và 18) (US4.5).
- [ ] **Step 13. Frontend behavior.** Không đổi giao diện, không có widget mới: màn Game Over hiện có không đổi. Test hiện có về Game Over vẫn dùng `blockSource` cố định nên giữ nguyên.
- [ ] **Step 14. Cấu hình môi trường và build.** Không có. Người dùng chạy `dart format .`, `flutter analyze`, `flutter test --coverage` và đo hiệu năng trên máy thật theo `cicd-pipeline.md`.
- [ ] **Step 15. Tài liệu và truy vết.** `code-summary.md`, `traceability.json`, `source-manifest.json` trong thư mục code-generation của unit; ánh xạ AC4.x → bước và file.

## Truy vết story → bước

| Story | Bước |
|---|---|
| US4.1 (luôn có nước đi, Game Over) | 7–12 |
| US4.2 (khối cứu) | 5, 6, 9, 10 |
| US4.3 (bảng đầy trên 60%) | 5, 6, 9, 10 |
| US4.4 (độ khó theo level) | 5, 6 |
| US4.5 (Endless dùng cùng thuật toán, level 18) | 11, 12 |
| US4.6 (hằng số một nơi, test theo seed, băng/bom/màu) | 3, 4, 9, 10 |

## Testing Contract

```json
{
  "version": 1,
  "methodology": "test-after",
  "source": "team",
  "ordering": "Implement each testable layer first, then write and run that layer's tests before moving on.",
  "scope": "classic",
  "test_strategy": "standard",
  "project_type": "brownfield",
  "applicable_notes": [
    {
      "layer": "org",
      "text": "We treat tests as a first-class deliverable in every Bolt. The specific\nmethodology (TDD, BDD, ATDD, or classic test-after) is affirmed at\npractices-discovery and recorded in `team.md` under this heading with explicit\n`Methodology` and `Ordering` fields; Code Generation resolves those fields\nindependently from coverage, tooling, and scope notes.\n\nWhen no posture has been affirmed, our default per scope is:\n- **Methodology**: test-after\n- **Ordering**: implement each applicable testable layer, then write and run\n  that layer's tests.\n- `mvp`, `enterprise`, `feature`, `infra`, `classic` add an 80% line-coverage\n  floor and CI execution before merge.\n- `bugfix`, `security-patch` add a targeted regression for the specific\n  bug/vulnerability and require the existing suite to remain green.\n- `express` uses the Minimal strategy: requirement-driven unit tests (one per\n  requirement, with a happy-path floor per component); existing tests remain\n  green.\n- `poc`, `refactor`, `workshop` add no extra new-test floor and require the\n  existing suite to remain green.\n\nThe active `Test Strategy` still applies in every scope and determines test\nvolume/types. Scope floors are additive; they never reduce or replace the\nselected strategy.\n\nBuild and Test verifies defined coverage floors and affirmed quality targets;\nthey may not be weakened to make a step pass.\n\nAffirm a stricter posture in `team.md` if the team commits to one."
    },
    {
      "layer": "team",
      "text": "- **Methodology**: test-after\n- **Ordering**: Implement each testable layer first, then write and run that layer's tests before moving on.\n- Coverage dòng tối thiểu 80% trên toàn bộ codebase.\n- Ưu tiên unit test cho logic thuần và controller/service; widget test cho màn mới.\n- `test/widget_test.dart` phải pass trước khi đo coverage.\n- Lệnh kiểm tra: `flutter analyze` và `flutter test --coverage`, do người dùng chạy rồi báo kết quả; AI chỉ sinh code và test."
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
      "Keep the existing test suite green.",
      "This scope adds no extra new-test floor beyond the selected test strategy."
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
  "input_sha256": "sha256:26f5cefbed69ac3d34834d809fdf30eff5d0b23e280080ee2179ffbd546bd2b5",
  "contract_sha256": "sha256:285b00906e08694f7744ed769c61c71eb3914a399042693d992451e6ed2c6fac"
}
```
