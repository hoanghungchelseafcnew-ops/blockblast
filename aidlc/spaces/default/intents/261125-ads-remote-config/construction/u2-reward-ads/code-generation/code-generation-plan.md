# Kế hoạch tạo mã: u2-reward-ads

Nguồn: `functional-spec.md`, `rules.md`, `frontend-components.md`, `security-design.md`, `performance-design.md`, `logical-components.md` của unit này, `contract-summary.md` (hợp đồng 2 và 4), `unit-of-work.md` và mã của `u1-ads-core`. Unit này thêm nút WATCH AD TO TRY AGAIN ở lớp phủ Game Over của Journey và đổi thời điểm ghi nhận thua.

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
      "text": "- **Methodology**: test-after\n- **Ordering**: Implement each testable layer first, then write and run that layer's tests before moving on.\n- Độ phủ dòng tối thiểu 80% trên toàn bộ codebase.\n- Ưu tiên unit test cho logic thuần và controller hoặc service, widget test cho màn mới.\n- `test/widget_test.dart` phải pass trước khi đo độ phủ.\n- Mã dùng SDK quảng cáo nằm sau interface có bản giả để test, theo mẫu `RemoteConfigClient` và `AnalyticsService`.\n- Lệnh kiểm tra: `flutter analyze` và `flutter test --coverage`, do người dùng chạy rồi báo kết quả. AI chỉ sinh code và test."
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
  "input_sha256": "sha256:f1f92e44b1cabd08409acdd43d3788e7e430ecf143500ca35f214c15c52f236a",
  "contract_sha256": "sha256:a81de4428560901c72e86bedab48c3d1809be07a1a8ee64055ac2dcf93228529"
}
```

## Quyết định thiết kế khi viết mã

- **Chỉ hoãn ghi nhận thua khi nút reward có thể hiện** (quảng cáo đang chạy và `reward_enabled` là true). Khi không có quảng cáo hoặc cờ tắt, game ghi nhận thua ngay như hiện nay. Kết quả với người chơi giống hệt, vì không có nút thì không có gì để chờ, và các test hiện có của `LevelGameController` và `ProgressRepository` không phải đổi (NFR7.2).
- Dấu lần thua chưa ghi nhận nằm trong một lớp nhỏ mới `PendingLossStore` qua `ProgressStore`, không thêm vào `ProgressRepository` (hơn 400 dòng, nhiều test), để giảm rủi ro hồi quy. Dấu lưu cả level và điểm.

## Các bước (test-after)

### Step 1: Kiểm tra trình chạy test
- [ ] Dùng lại lệnh đã duyệt `flutter analyze && flutter test --coverage`. Ghi lệnh riêng của unit vào `unit-test-instructions.md`.

### Step 2: Reward ở lớp mạng quảng cáo
- [ ] `lib/features/ads/services/ad_network_adapter.dart`: thêm `RewardShowResult` (`earned`, `closedEarly`, `failed`), `loadRewarded` và `showRewarded`.
- [ ] `lib/features/ads/services/ad_unit_ids.dart`: thêm `rewardedId` (ID reward thử của AdMob cho debug, để trống cho bản phát hành và cho Unity, AppLovin).
- [ ] `admob_adapter.dart` (RewardedAd), `unity_adapter.dart` (placement reward, `onComplete` là nhận thưởng, `onSkipped` là đóng sớm), `applovin_adapter.dart` (rewarded listener): bắt mọi lỗi.
- [ ] `lib/features/ads/services/ad_mediator.dart`: `RewardOutcome` (`earned`, `closedEarly`, `noAd`), `AdsService.preloadReward()` và `AdsService.reward()`; ô reward riêng, tải theo `ads_priority`, thời hạn 5 giây mỗi mạng, chưa sẵn sàng thì trả `noAd` ngay, bỏ đếm lần quay lại sau quảng cáo. `NoopAdsService` trả `noAd`.
- [ ] Test: cập nhật `test/features/ads/ads_fakes.dart` và thêm nhóm reward trong `test/features/ads/ad_mediator_test.dart` (sẵn sàng thì `earned`, đóng sớm, chưa sẵn sàng thì `noAd` không chờ, mạng đầu không có thì thử mạng kế, tải lại sau khi hiện, chưa đồng ý thì không tải).
- Truy vết: NFR2.9, NFR2.10, NFR2.11, BR6.3, BR6.4.

### Step 3: Dấu lần thua chưa ghi nhận
- [ ] `lib/features/ads/services/pending_loss_store.dart`: `PendingLossStore` với `mark(levelIndex, score)`, `clear()`, `read()`; lỗi ghi được log, không ném.
- [ ] Test: `test/features/ads/pending_loss_store_test.dart` (ghi, đọc lại sau khi tạo lại, xóa, giá trị hỏng, lỗi ghi).
- Truy vết: BR6.7, NFR2.12, NFR2.14.

### Step 4: Luồng thua và reward trong LevelGameController
- [ ] `lib/features/journey/controllers/level_game_controller.dart`: nhận `AdsService`, `rewardEnabled` và `PendingLossStore` (mặc định không có). Khi nút có thể hiện: hết nước đi thì chờ ghi dấu xong, tính kết quả hiển thị bằng `lostOutcomeFor` (không lưu), chuyển sang thua chưa ghi nhận. Thêm `canWatchAd`, `watchingAd`, `watchAd()`: nhận thưởng thì lưu điểm cao nếu cao hơn, xóa dấu, bắt đầu lại cùng level; đóng sớm thì giữ lớp phủ. `playAgain()` và rời màn ghi nhận thua đúng một lần rồi xóa dấu. Tải trước reward khi bắt đầu level. (BR6.1 đến BR6.8)
- [ ] Test: `test/features/journey/level_game_reward_test.dart` (nút hiện khi cờ bật, ẩn khi tắt hoặc không có quảng cáo, nhận thưởng không hạ tiến trình và về 0, đóng sớm giữ lớp phủ, thua lần nữa cho xem lại, PLAY AGAIN ghi nhận thua một lần, rời màn ghi nhận thua, lưu điểm cao). Test cũ giữ nguyên và vẫn chạy.
- Truy vết: AC3.1.3 đến AC3.1.6, NFR2.12, NFR2.13.

### Step 5: Ghi nhận lần thua còn treo khi mở lại
- [ ] `lib/features/journey/services/app_bootstrap.dart`: thêm `PendingLossStore` tùy chọn; sau khi dựng dịch vụ, nếu còn dấu thì ghi nhận thua cho level đó và xóa dấu, trong hạn chót còn lại. `AppServices` có thêm `pendingLoss`.
- [ ] `lib/app_composition.dart`: dựng `PendingLossStore` thật.
- [ ] Test: thêm vào `test/features/journey/app_bootstrap_test.dart` (có dấu thì hạ tiến trình và xóa dấu, không có dấu thì giữ nguyên, lỗi đọc không chặn khởi động).
- Truy vết: AC3.1.4, BR6.7.

### Step 6: Giao diện
- [ ] `lib/features/game/widgets/game_over_overlay.dart`: thêm `onWatchAd` và `watchAdBusy`; có nút thì hiện dòng "Watch an ad to stay on this level", nút chính WATCH AD TO TRY AGAIN (key `game-over-reward-button`) và PLAY AGAIN thành nút phụ. Bản Endless không đổi.
- [ ] `lib/features/game/screens/game_screen.dart`: nối `onWatchAd` với `controller.watchAd`; BACK TO MENU ghi nhận thua trước khi rời.
- [ ] `lib/features/home/screens/home_screen.dart`: truyền `ads`, `rewardEnabled` và `pendingLoss` vào `LevelGameController`.
- [ ] Test: thêm vào `test/ui/game_screen_test.dart` (nút hiện và ẩn đúng, bấm nút gọi reward rồi bắt đầu lại, chuỗi tiếng Anh) và một test trong `test/features/victory/` không cần.
- Truy vết: AC3.1.1, AC3.1.2, AC3.1.7, NFR4.

### Step 7: Tổng kết
- [ ] `code-summary.md`, `traceability.json`, `source-manifest.json`.

## Rủi ro

- Đổi luồng thua là phần rủi ro nhất. Giảm rủi ro bằng cách chỉ đổi khi nút reward có thể hiện, nên mọi test cũ vẫn chạy theo đường cũ.
- API reward của Unity và AppLovin viết theo tài liệu; nếu `flutter analyze` báo lỗi sẽ sửa tên tham số.

## Assumptions & Open Questions

None.
