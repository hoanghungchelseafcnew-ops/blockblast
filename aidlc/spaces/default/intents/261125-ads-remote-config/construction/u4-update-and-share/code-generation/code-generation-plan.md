# Kế hoạch tạo mã: u4-update-and-share

Nguồn: `functional-spec.md`, `rules.md`, `frontend-components.md`, `performance-design.md`, `security-design.md`, `logical-components.md` của unit này, `tech-stack-decisions.md` (`url_launcher` ở chế độ mở ngoài), `contract-summary.md` (hợp đồng 3: `AdsSettings`), `unit-of-work.md`, `requirements.md` (FR6, FR7, NFR4) và mã của `u1-ads-core`. Unit này thêm popup báo có bản mới trên Home và link cửa hàng trong nội dung chia sẻ.

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

- Mã mới nằm trong `lib/features/update/` theo kiến trúc feature-first: `logic/` cho so phiên bản và kiểm tra đường dẫn (thuần), `services/` cho `AppUpdateChecker`, `InstalledVersionReader`, `StoreLauncher`, `widgets/` cho `UpdatePopup`.
- `AppBootstrap` nhận một hàm dựng `AppUpdateChecker` tùy chọn. `createAppBootstrap` truyền hàm thật; mặc định không có hàm thì không kiểm tra phiên bản, nên các test hiện có của Home không đổi.
- `AdsService` có thêm `appOpenCount` và `startupSettled` (luồng đồng ý đã xong). `NoopAdsService` trả 0 và true.
- Link chia sẻ: `ScoreShareService.withStoreLink(text, url)` dùng chung; `PlatformScoreShareService` nhận `storeUrl` tùy chọn, và `HomeScreen` truyền đường dẫn của nền tảng cho màn chơi và Endless.
- Nền tảng được xác định bằng `defaultTargetPlatform`, nên test đổi được bằng `debugDefaultTargetPlatformOverride`.

## Các bước (test-after)

### Step 1: Kiểm tra trình chạy test và cấu hình
- [ ] Dùng lại lệnh đã duyệt `flutter analyze && flutter test --coverage`. Ghi lệnh riêng của unit vào `unit-test-instructions.md`.
- [ ] `pubspec.yaml`: thêm `url_launcher: ^6.3.0`; chạy `flutter pub get`.
- [ ] `android/app/src/main/AndroidManifest.xml`: thêm intent `VIEW` với scheme `https` vào khối `<queries>`.

### Step 2: Logic so phiên bản và đường dẫn
- [ ] `lib/features/update/logic/version_check.dart`: `parseVersion` (bỏ phần sau `+`, chỉ số nguyên không âm cách nhau bằng dấu chấm), `compareVersions` (phần thiếu là 0), `isValidStoreUrl` (chỉ `https`, có tên máy chủ, không có khoảng trắng), `storeUrlFor(settings, ios:)`.
- [ ] Test: `test/features/update/version_check_test.dart` (1.0.0 < 1.0.1, 1.0 = 1.0.0, 1.0.10 > 1.0.9, bỏ số build, chuỗi sai dạng, `http`, `javascript:`, `market://`, rỗng, URL hợp lệ của hai cửa hàng, chọn theo nền tảng).
- Truy vết: BR8.1, BR8.2, BR8.3, NFR8.1.

### Step 3: Dịch vụ kiểm tra phiên bản
- [ ] `lib/features/update/services/installed_version_reader.dart`: interface và bản thật dùng `package_info_plus`.
- [ ] `lib/features/update/services/store_launcher.dart`: interface và bản thật dùng `url_launcher` chế độ `externalApplication`, bắt lỗi.
- [ ] `lib/features/update/services/app_update_checker.dart`: `AppUpdateChecker.check()` trả đường dẫn cửa hàng khi có bản mới, null khi không; `canShowFor(appOpen)` và `markShown(appOpen)` cho BR8.4; lỗi đọc phiên bản thì null và ghi log.
- [ ] `lib/features/ads/services/ad_mediator.dart`: `AdsService.appOpenCount` và `startupSettled`.
- [ ] `lib/features/journey/services/app_bootstrap.dart`: `AppServices.updates`; `AppBootstrap` nhận `updateCheckerFactory`. `lib/app_composition.dart`: truyền hàm thật.
- [ ] Test: `test/features/update/app_update_checker_test.dart` (có bản mới, bằng, thấp hơn, cấu hình rỗng, đường dẫn sai, lỗi đọc phiên bản, một lần mỗi lần mở, hiện lại khi số lần mở tăng, iOS dùng `ios_*`); thêm vào `ad_mediator_test.dart` (`appOpenCount`, `startupSettled`) và `app_bootstrap_test.dart` (có hàm dựng thì có `updates`).
- Truy vết: BR8.4, NFR1.2, NFR2.23, NFR3.4, NFR6.2, NFR8.2, NFR8.3, AC5.1.1, AC5.1.2, AC5.1.5.

### Step 4: Link trong nội dung chia sẻ
- [ ] `lib/features/game/services/score_share_service.dart`: `withStoreLink` và `storeUrl` cho `PlatformScoreShareService`.
- [ ] `lib/features/home/screens/home_screen.dart`: truyền `PlatformScoreShareService(storeUrl: ...)` cho `GameScreen` và `EndlessGameScreen`.
- [ ] Test: thêm vào `test/features/game/services/score_share_service_test.dart` (có link hợp lệ thì xuống dòng rồi link, link sai thì giữ nguyên, chia sẻ thật gửi văn bản có link).
- Truy vết: BR9.1, AC6.1.1, AC6.1.2, AC6.1.3.

### Step 5: Popup trên Home
- [ ] `lib/features/update/widgets/update_popup.dart`: `showUpdatePopup` với tiêu đề "Update available", câu "A new version of Block Jewel is ready. Update now for the latest fixes and features.", nút LATER (key `update-popup-later`) và UPDATE (key `update-popup-update`); back hoặc chạm ra ngoài đóng popup.
- [ ] `lib/features/home/screens/home_screen.dart`: kiểm tra sau khung hình đầu, khi `bannerChanges` báo và khi quay về từ màn chơi; chờ `startupSettled`; chỉ mở khi Home là màn trên cùng; UPDATE gọi `suppressNextResume` rồi mở cửa hàng.
- [ ] Test: `test/features/update/update_popup_test.dart` và thêm vào `test/ui/splash_home_test.dart` hoặc tệp test Home mới (popup hiện khi có bản mới, không hiện khi không có, không hiện lại khi quay về Home, UPDATE mở đúng đường dẫn và đóng popup, LATER đóng popup, chờ đồng ý xong, chuỗi tiếng Anh).
- Truy vết: BR8.5, BR8.6, AC5.1.1, AC5.1.2, AC5.1.3, AC5.1.4, NFR4.

### Step 6: Tổng kết
- [ ] `code-summary.md`, `traceability.json`, `source-manifest.json`.

## Rủi ro

- `flutter pub get` có thể báo xung đột phiên bản với `url_launcher` như lần `package_info_plus` ở u1; nếu có thì hạ phiên bản và ghi lại.
- `HomeScreen` cũng thuộc workflow `gemstone-journey` đang chạy; chỉ sửa đúng phần popup và truyền dịch vụ chia sẻ.

## Assumptions & Open Questions

None.
