# Code Generation Plan: u2-victory-share

Nguồn: functional-spec.md, frontend-components.md (functional-design), performance-design.md, security-design.md, logical-components.md (nfr-design), unit-of-work.md (U2), requirements.md (FR3, FR2.4), stories.md (US2.3, US3.1–3.5). Brownfield, sửa tại chỗ. Infrastructure Design được bỏ qua cho unit này.

## Các bước

- [ ] **Step 1. Cấu trúc và cấu hình.** Không thêm gói hay quyền; dùng `screenshot`, `share_plus`, `path_provider` sẵn có (NFR7.1, NFR5.2).
- [ ] **Step 2. Xác nhận bộ chạy test.** `flutter_test` sẵn có; lệnh theo unit ghi trong `unit-test-instructions.md`.
- [ ] **Step 3. Business logic / service: implement.** `lib/features/game/services/score_share_service.dart`:
  - thêm hằng `ScoreShareService.gameName = 'Block Jewel'`, hàm tĩnh `scoreShareText(score)` → `I scored $score in Block Jewel!` và `victoryShareText(levelName, score)` → `I cleared $levelName with $score points in Block Jewel!` (BR1.3, BR1.6, NFR4.1);
  - thêm phương thức trừu tượng `shareVictory({screenshot, levelName, score})`;
  - `PlatformScoreShareService`: helper riêng `_captureAndShare(screenshot, fileName, text)` dùng cho cả `shareScore` (`score.png`) và `shareVictory` (`victory.png`); lỗi bắt và ghi `GjLog.error` (BR1.2, BR1.4, NFR6.1).
- [ ] **Step 4. Business logic: viết và chạy test.** `test/features/game/services/score_share_service_test.dart`: test hai chuỗi; `shareVictory` khi controller chưa gắn widget không chia sẻ; khi chụp được thì ghi `victory.png` và gọi share kèm văn bản đúng; khi kênh share lỗi thì ghi log, không ném lỗi. Cập nhật `FakeShareService` trong `test/ui/ui_test_helpers.dart` thêm `shareVictory` (ghi `victoryShared`, `lastLevelName`).
- [ ] **Step 5. Frontend behavior: implement.**
  - `lib/features/victory/widgets/victory_overlay.dart`: prop `Future<void> Function()? onShare`; state `_sharing`; nút `GemPrimaryButton` `key: Key('victory-share-button')`, nhãn `SHARE`, icon `Icons.share`, rộng 240, dưới CONTINUE/BACK TO MENU; ẩn khi `onShare == null`; vô hiệu khi `_sharing` hoặc `_leaving`; không đặt `_leaving` (BR1.1, BR1.5, NFR1.1).
  - `lib/features/game/screens/game_screen.dart`: truyền `onShare` gọi `shareService.shareVictory(screenshot: _screenshotController, levelName: controller.level.displayName, score: controller.score)` (BR1.2).
- [ ] **Step 6. Frontend behavior: viết và chạy test.**
  - `test/features/victory/victory_overlay_test.dart`: SHARE có ở 3 biến thể, cao ≥ 48dp; ẩn khi không có `onShare`; bấm khi đang chia sẻ chỉ gọi một lần; sau khi chia sẻ CONTINUE vẫn bấm được; `onShare` ném lỗi không làm hỏng màn (AC3.1.1, AC3.2.1, AC3.3.1, AC3.4.1, AC3.4.2).
  - `test/ui/game_screen_test.dart`: thắng level 1 rồi bấm SHARE gọi `shareVictory` với `Rose Quartz · Rough Stone` và điểm; không bấm thì không gọi (AC3.1.2, AC3.1.3, AC3.1.4, NFR6.2); Game Over SHARE vẫn gọi `shareScore` (AC3.5.1).
- [ ] **Step 7. Cấu hình môi trường và build.** Không có thay đổi; `flutter analyze`, `dart format`.
- [ ] **Step 8. Tài liệu và truy vết.** `code-summary.md`, `source-manifest.json`, `traceability.json`.

## Truy vết story
| Story | Step |
|---|---|
| US2.3 | 3, 4 |
| US3.1 | 3, 5, 6 |
| US3.2 | 5, 6 |
| US3.3 | 5, 6 |
| US3.4 | 3, 4, 5, 6 |
| US3.5 | 3, 4, 6 |

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
