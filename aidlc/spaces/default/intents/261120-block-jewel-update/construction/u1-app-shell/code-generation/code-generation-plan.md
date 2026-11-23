# Code Generation Plan: u1-app-shell

Nguồn: unit-of-work.md (U1), requirements.md (FR1, FR2, NFR3–NFR7), security-design.md (nfr-design của unit), components.md (AppShell), stories.md (US1.1–1.3, US2.1, US2.2). Unit đóng gói (packaging), brownfield, mã ứng dụng sửa tại chỗ. Stage functional-design và infrastructure-design đã được bỏ qua cho unit này.

## Các bước

- [ ] **Step 1. Cấu trúc và cấu hình sản xuất (production configuration).**
  - `pubspec.yaml`: gỡ dev-dependency `flutter_native_splash` và khối cấu hình `flutter_native_splash:` (US1.3, NFR5.2).
  - Android: `drawable/launch_background.xml` và `drawable-v21/launch_background.xml` chỉ còn một lớp màu `#0F0C29`, không bitmap; thêm `drawable/splash_empty.xml` (hình trong suốt); trong `values-v31/styles.xml` và `values-night-v31/styles.xml` giữ `windowSplashScreenBackground` `#0F0C29` và đặt `windowSplashScreenAnimatedIcon` thành `@drawable/splash_empty`; `values/styles.xml` và `values-night/styles.xml` giữ nền; xóa `splash.png` và `android12splash.png` trong các thư mục `drawable-*` (US1.1, NFR5.3).
  - iOS: `LaunchScreen.storyboard` bỏ `imageView` `LaunchImage`/`LaunchBackground`, nền `#0F0C29`; xóa `LaunchImage.imageset` và `LaunchBackground.imageset` (US1.2).
  - Tên: `AndroidManifest.xml` `android:label="Block Jewel"`; `Info.plist` `CFBundleDisplayName` "Block Jewel", `CFBundleName` "block_jewel" (US2.1). Giữ nguyên `applicationId`, `namespace`, bundle id, tên package Dart (NFR7.1).
- [ ] **Step 2. Xác nhận bộ chạy test hiện có.** Dùng `flutter_test` có sẵn; lệnh theo unit ghi trong `unit-test-instructions.md`.
- [ ] **Step 3. Giao diện (frontend behavior): implement.**
  - `lib/app.dart`: `title: 'Block Jewel'` (US2.1).
  - `lib/features/splash/screens/splash_screen.dart`: chữ 'BLOCK JEWEL'; giữ dòng phụ '◆ Gemstone Journey ◆' (US2.1, US2.2).
  - `lib/features/home/screens/home_screen.dart`: giữ nguyên dòng phụ (US2.2).
- [ ] **Step 4. Giao diện: viết và chạy test sau khi implement.** Cập nhật `test/ui/splash_home_test.dart` (chuỗi 'BLOCK JEWEL'); thêm test: `MaterialApp.title == 'Block Jewel'`, splash vẫn dùng nền `GemTheme.backgroundEnd`, Home vẫn hiện dòng phụ; kiểm tra `test/widget_test.dart` còn pass (US1.1–1.3, US2.1, US2.2, NFR3.1, NFR4.1).
- [ ] **Step 5. Cấu hình môi trường và build.** Đối chiếu bằng cách đọc rằng `build.gradle.kts`, `Info.plist` (bundle id), `pubspec.yaml` (name) không đổi và không thêm quyền hay gói (NFR7.1, NFR7.2); chạy `flutter analyze` và `dart format` (NFR5.1) do người dùng thực hiện.
- [ ] **Step 6. Tài liệu và truy vết.** `README.md` đổi tên sang Block Jewel; viết `code-summary.md`, `source-manifest.json`, `traceability.json`.

## Truy vết story
| Story | Step |
|---|---|
| US1.1 | 1, 4 |
| US1.2 | 1, 4 |
| US1.3 | 1, 4, 5 |
| US2.1 | 1, 3, 4, 6 |
| US2.2 | 3, 4 |

## Kiểm tra thủ công (người dùng, trên thiết bị)
Android dưới 12, Android 12+ và iOS: chỉ thấy nền `#0F0C29` rồi splash trong code, không có logo xuất hiện hai lần.

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
