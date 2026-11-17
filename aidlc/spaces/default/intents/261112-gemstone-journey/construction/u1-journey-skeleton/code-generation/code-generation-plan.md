# Kế hoạch Code Generation — U1 `u1-journey-skeleton`

## Sources

- [fd] `construction/u1-journey-skeleton/functional-design/` (`functional-spec.md` WF1..WF7, `rules.md` BR1.1..BR7.2, `entities.md`)
- [nfr] `construction/u1-journey-skeleton/nfr-design/` (`performance-design.md`, `security-design.md`): hai sửa đổi Major bắt buộc (try/catch trong `ImageUrlPolicy.isAllowed`, không log URL đầy đủ hay `err.toString()`)
- [infra] `construction/u1-journey-skeleton/infrastructure-design/infrastructure-specification.md`
- [contract] `inception/contract-design/contract-summary.md` (C1..C6, E1, E3)
- [units] `inception/units-generation/unit-of-work.md` (U1: ranh giới, thứ tự 4 bước, DoD-1..DoD-5)
- [req] `inception/requirements-analysis/requirements.md` (FR1..FR3, FR8, FR11, FR14, NFR1..NFR11)
- [prac] `aidlc/spaces/default/memory/team.md` (test-after, coverage ≥ 80%, người dùng tự build và test)
- [user] Người dùng báo trong phiên này: đã dùng git nên **bỏ qua hai lần zip sao lưu** trong `unit-of-work.md`; Remote Config key `level_config` đã được cấu hình và publish trên Firebase.

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

Ghi chú áp dụng hợp đồng: AI không chạy được `flutter` (không có trên PATH). AI viết code và test theo từng lớp, **người dùng chạy** các lệnh và báo kết quả. "Write and run" trong các bước test nghĩa là AI viết test và người dùng chạy ở các điểm dừng kiểm tra (CP-1..CP-3). Không có CI (chạy tay), nên "Run in CI before merge" được đáp ứng bằng lệnh chạy tay ở CP-3.

## Quy ước

- Dự án: Flutter, package Dart `block_blast`. Mã ứng dụng nằm ở `lib/`, test ở `test/`, đều ở gốc workspace.
- Thư mục mới: `lib/core/firebase/`, `lib/core/config/`, `lib/features/journey/` (models, services, controllers), `lib/features/game/engine/`, `lib/features/splash/`.
- Chuỗi UI mới chỉ tiếng Anh (BR6.4). Nút mới ≥ 48dp. Mọi `catch` đều log (`debugPrint`) và có fallback (BR7.2).
- Log không chứa URL đầy đủ hay `err.toString()`: chỉ `levelId`, lý do và `err.runtimeType` (NFR design, security-design).
- Brownfield: sửa file tại chỗ, không tạo bản sao `_modified`.
- `ThemeManager` được giữ nguyên ở U1 (U4 gỡ). Daily Gift giữ đến U4.
- Dependency mới chỉ `firebase_core` và `firebase_remote_config` (BR6.2).

## Các bước

Mỗi bước gắn với rule (BR), workflow (WF) và story/yêu cầu nguồn. Thứ tự theo Testing Contract (test-after) và thứ tự 4 bước của `unit-of-work.md`.

### Giai đoạn A — Nền tảng và Firebase (unit-of-work bước 1)

- [x] **Step 1 — Cấu trúc dự án và cấu hình sản phẩm (skeleton).**
  - Đổi Android `namespace` và `applicationId` thành `com.h2.game.block_blast` trong `android/app/build.gradle.kts`. Chuyển `MainActivity.kt` sang `kotlin/com/h2/game/block_blast/` và sửa dòng `package`.
  - Thêm plugin `com.google.gms.google-services` ở `android/settings.gradle.kts` và `android/app/build.gradle.kts`.
  - Đổi iOS bundle thành `com.h2.game.blockBlast` (RunnerTests: `com.h2.game.blockBlast.RunnerTests`) trong `ios/Runner.xcodeproj/project.pbxproj`.
  - Thêm `firebase_core` và `firebase_remote_config` vào `pubspec.yaml`.
  - Trong `main.dart`: gọi `Firebase.initializeApp` (timeout 1,5s, lỗi thì log và chơi offline) bọc trong khối try/catch.
  - Truy vết: BR6.1, BR6.2, BR1.5, FR14, NFR3, NFR4. Kiểm tra bởi người dùng ở **CP-1**.
- [x] **Step 2 — Xác minh test runner và ghi lệnh có phạm vi unit.**
  - Sửa `test/widget_test.dart` đang hỏng (`MyApp` → `BlockBlastApp`) để `flutter test` chạy được.
  - Ghi lệnh trong `unit-test-instructions.md`. Truy vết: team practice "sửa widget_test trước khi đo coverage", DoD-5.

### Giai đoạn B — Lõi trò chơi (unit-of-work bước 2)

- [x] **Step 3 — Business logic: tách `BoardEngine` và `TurnResolver` — implement.**
  - Tách logic đặt khối, tính điểm (ô × 10, dòng × 100 × combo), xóa dòng, kiểm tra hết nước đi khỏi `_GameScreenState`, dựa trên `BoardLogic` hiện có (`lib/features/game/logic/board_logic.dart`). Đặt trong `lib/features/game/engine/`.
  - Gỡ hoàn toàn Time Attack (`GameMode`, `_timeLeft`, `_startTimer`, `high_score_time`) khỏi `lib/`.
  - Truy vết: BR5.1, BR5.2, BR6.3, FR1, US2.2 (gameplay giữ nguyên).
- [x] **Step 4 — Business logic: test cho `BoardEngine`/`TurnResolver`.** Điểm, combo reset, xóa dòng, hết nước đi, trường hợp biên (bảng đầy, khối không đặt được). Kèm kiểm tra tĩnh BR6.3 (không còn từ khóa Time Attack trong `lib/`). Chạy ở **CP-2**.

### Giai đoạn C — Cấu hình và catalog (unit-of-work bước 3)

- [x] **Step 5 — Data model: entity và cấu hình — implement.**
  - Models: `GemConfig`, `SubLevelConfig`, `LevelConfig` (kèm `source`), `Level`.
  - `ImageUrlPolicy.isAllowed` với try/catch(Object) (Uri.decodeFull ném lỗi với `%zz`; trả `false` và log lý do).
  - `LevelConfigValidator` (BR1.2, BR1.3, BR1.6): trả toàn bộ hợp lệ hoặc bị loại; URL xấu chỉ bỏ cho riêng level đó.
  - `DefaultLevelConfig` là hằng Dart `const` trong `lib/core/firebase/default_level_config.dart`; level 1 target 500 (AC offline).
  - Truy vết: BR1.2, BR1.3, BR1.4, BR1.6, E1 (version ≥ 1, bỏ qua trường lạ), FR3.
- [x] **Step 6 — Data model: test cho models, validator, `ImageUrlPolicy`, `DefaultLevelConfig`.** JSON hợp lệ; thiếu gem; sub trùng `order`; `targetScore` ngoài 1..10,000,000; `version` < 1; URL: sai scheme, có userinfo, port lạ, host giả (`evilfirebasestorage.app`), chuỗi `%zz`; trường lạ được bỏ qua.
- [x] **Step 7 — Repository: `LevelConfigService` và `RemoteConfigClient` — implement.**
  - `RemoteConfigClient` (abstract) + triển khai Firebase + `FakeRemoteConfigClient`. `LevelConfigService.initialize()` áp dụng ngân sách fetch (BR1.1), nguồn `remote | cached | default`, log `config_source` (BR1.7).
  - Truy vết: BR1.1, BR1.4, BR1.5, BR1.7, BR1.8.
- [x] **Step 8 — Repository: test cho `LevelConfigService`.** Remote hợp lệ; remote hỏng → default; fetch timeout → cached; cached hỏng → default; Firebase lỗi/treo → default; log không chứa URL đầy đủ.
- [x] **Step 9 — Business logic: `LevelCatalog` — implement.** 36 level bất biến, `levelIndex = (gemOrder − 1) × 6 + subOrder`, `assetPath`, `next(level)` (level 36 → null). Truy vết: BR2.1..BR2.4.
- [x] **Step 10 — Business logic: test cho `LevelCatalog`.** Đủ 36 level, thứ tự, `assetPath`, `next` ở biên 1/35/36, bất biến.

### Giai đoạn D — Tiến trình và vòng đời ván (unit-of-work bước 4)

- [x] **Step 11 — Repository: `ProgressRepository` — implement.** Cache, hàng đợi ghi FIFO duy nhất, key riêng (`progress`, `tutorial_completed`), `load()` thử lại một lần rồi chuyển chế độ chỉ đọc (log cảnh báo khi vào chế độ này và ở lần ghi bị bỏ qua đầu tiên), dirty + bộ đếm thử lại 3 lần, `flushDirty`. Truy vết: BR3.1..BR3.5, ADR-009, contract C5, E3.
- [x] **Step 12 — Repository: test cho `ProgressRepository`** (dùng `SharedPreferences.setMockInitialValues`). Key thiếu/hỏng → mặc định; `currentLevelIndex` ngoài 1..36; phần tử `completedLevels` ngoài khoảng bị bỏ; tutorial không phải bool; thứ tự FIFO; ghi lỗi → dirty → ghi lại; bộ đếm dừng ở 3; `flushDirty` bỏ qua bộ đếm; `load` lỗi → chế độ chỉ đọc.
- [x] **Step 13 — Business logic: `JourneyController.onLevelWon` — implement.** Thuần (không analytics). Cập nhật cache, await lưu, luôn trả `JourneyOutcome { nextLevel, highestLevelReached, unlockedGemId = null, journeyCompleted = false }`, không bao giờ throw. Truy vết: BR4.1..BR4.3, US1.6.
- [x] **Step 14 — Business logic: test cho `JourneyController`.** Thắng lần đầu (ví dụ BR4.1: level 5 → current 6, highest 6); thắng lại với highest=9 giữ highest; level 36 → `nextLevel = null`; thêm lại `completedLevels` không đổi; ghi lỗi vẫn trả outcome.
- [x] **Step 15 — Business logic: `AppBootstrap` — implement.** Điều phối WF1 với hạn chót 3,5s: Firebase init ≤ 1,5s, fetch ≤ min(2s, hạn chót − 0,5s − now), `ProgressRepository.load` ≤ 0,5s trong hạn chót tổng, dựng `LevelCatalog`, log `config_source`. Đồng hồ (`Clock`) được tiêm để test. Truy vết: BR1.1, BR1.5, BR1.8, WF1.
- [x] **Step 16 — Business logic: test cho `AppBootstrap`.** Mọi nguồn thành công; Firebase lỗi; Firebase treo; fetch treo; hạn chót cắt giữa chừng; Splash không vượt 3,5s (đồng hồ giả).
- [x] **Step 17 — Business logic: `LevelGameController` — implement.** Trạng thái `playing → resolving → won`, `playing → lost`, `lost → playing` (REVIVE), `quit`; thắng ưu tiên hơn hết nước đi, kiểm tra trước animation; `clearing` 180ms; `targetScore = max(1, …)`; `progressPercent` làm tròn xuống (max 99 trước khi thắng); timeout `resolving` 3s; bỏ qua input ngoài `playing`; tutorial qua repository. Dùng `TurnResolver`. Truy vết: BR5.1..BR5.10, WF2..WF6, ADR-008.
- [x] **Step 18 — Business logic: test cho `LevelGameController`.** Thắng ngay cả khi cùng lượt hết nước đi; input bị bỏ qua khi `resolving`/`won`/`lost`/`quit`; back khi `resolving` bị bỏ qua, khi `playing` → `quit` không đổi tiến trình; % ở các biên (0, 99, 100, target = 1); REVIVE một lần; PLAY AGAIN tạo `roundId` mới; timeout 3s dùng outcome từ cache; hai lần thắng không xử lý đôi.

### Giai đoạn E — Giao diện tối thiểu

- [x] **Step 19 — Frontend behavior: UI — implement.**
  - `SplashScreen` (chờ `AppBootstrap`, tối đa 3,5s, logo và chỉ báo) và `app.dart` nối Provider/constructor DI.
  - Home: bỏ hai thẻ chế độ, thêm nhãn `"<gemName> · <subName>"` và nút **PLAY** ≥ 48dp, giữ Settings và Daily Gift.
  - `game_screen.dart` dùng `LevelGameController`: header `[←]`, tên level, `"score / target"`, thanh tiến độ có nhãn `%`; bỏ TIME/BEST cũ; Victory tạm ("Level Complete!", `"score / target"`, CONTINUE); giữ Game Over cũ (SHARE, PLAY AGAIN, REVIVE, BACK TO MENU) khi `status = lost`. `AppLifecycleState.paused` gọi `flushDirty` (WF7).
  - Truy vết: WF1, WF2, WF4, WF5, WF7, BR6.3, BR6.4, FR11, NFR9.1 (PLAY ≥ 48dp, trắng trên `#6C63FF` = 4.32:1, chữ lớn).
- [x] **Step 20 — Frontend behavior: widget test.** Splash chuyển sang Home; Home hiển thị nhãn level và PLAY ≥ 48dp, không còn thẻ chế độ; header hiển thị `score / target` và `%`; Victory tạm có CONTINUE và chuyển sang level kế; Game Over hiện khi `lost`. Chạy ở **CP-3**.

### Giai đoạn F — Cấu hình môi trường/build và tài liệu

- [x] **Step 21 — Environment/build configuration.** Rà lại file cấu hình nền tảng (`google-services.json` và `GoogleService-Info.plist` đã được người dùng đặt đúng chỗ; không commit secret mới, không hardcode API key trong Dart). Ghi chú iOS: thêm `GoogleService-Info.plist` vào target Runner trong Xcode nếu chưa có (kiểm chứng iOS có thể hoãn sang Build & Test nếu chưa có Mac, theo DoD của U1).
- [x] **Step 22 — Tài liệu và truy vết.** Viết `unit-test-instructions.md` (đã có trước khi duyệt), `code-summary.md`, `traceability.json`, `source-manifest.json` (mọi file ứng dụng được tạo/sửa/xóa, gồm file do generator hoặc scaffolding ghi). Ghi chú vận hành review infra R-01/R-02 vào hướng dẫn người dùng (checklist publish RC, rollback RC, tăng version code khi cần quay lại sau khi lên store).

### Giai đoạn G — Sửa đổi theo Request Changes (2026-11-17, "hãy sửa theo ý bạn đi")

Lý do: lần chạy verify đầu tiên với Flutter 3.35.6 bị đỏ, và review lần 2 có các finding R-01..R-05.

- [x] **Step 23 — Sửa để verify xanh.**
  - Lỗi app: `ImageUrlPolicy` loại `%` sai định dạng ngay trên chuỗi gốc (BR1.3).
  - Lỗi test: kiểu override của fake Remote Config; test combo phải gọi `applyClear()`; test thua kiểm tra "không ghi `progress`" vì BR3.4 cho ghi `tutorial_completed`; `pumpGameScreen` pump thêm một frame; flush timer của `flutter_animate`.
  - Lint để `flutter analyze` sạch: đổi `withOpacity` sang `withValues(alpha:)`, bỏ các `default` không bao giờ chạy tới, đổi sang `activeThumbColor`, thêm ngoặc nhọn, bỏ import và helper không dùng. Các file cũ phải sửa được thêm vào manifest.
- [x] **Step 24 — Xử lý review.**
  - R-04 (BR5.7): `revive()` kiểm tra lại `hasMoves`.
  - R-01 (C4): thêm `AnalyticsService` và `NoopAnalyticsService`.
  - R-03: ghi lại các chỗ lệch chữ ký so với C2.
  - R-05: thêm test để các file U1 đạt ≥ 80%; `GemIds`, `SubIds`, `DefaultLevelConfig` đổi thành `abstract final class`; thêm `DefaultLevelConfig.parse` fail fast. Không dùng `coverage:ignore`.
- [x] **Step 25 — R-02: xóa `lib/features/game/controllers/game_controller.dart`.** File 0 byte, không được import ở đâu. Ghi việc xóa vào manifest.
- [x] **Step 26 — `lib/main.dart` testable (DoD-2).** Tách phần dựng service và cây Provider ra một hàm thuần trong `lib/app_composition.dart`, để `main()` chỉ còn `ensureInitialized`, `AudioController.init` và `runApp`. Viết test cho hàm đó: dựng được `BlockBlastApp` với `ThemeManager` và `AppBootstrap` thật, đi qua Splash tới Home khi không có Firebase. Mục tiêu: mọi file U1 trong `lib/` đạt ≥ 80%, gồm cả `main.dart` (nếu còn phần không đo được thì ghi rõ con số).
- [x] **Step 27 — Chạy lại `flutter analyze && flutter test --coverage`, cập nhật `code-summary.md`, `source-manifest.json`, `traceability.json`.**

## Điểm dừng kiểm tra của người dùng (không phải cổng duyệt)

| CP | Sau bước | Người dùng chạy | Kết quả cần báo |
|----|----------|-----------------|-----------------|
| CP-1 | Step 1, 2 | `flutter pub get && flutter build apk --debug` rồi `flutter test test/widget_test.dart` | Build Android thành công với package mới; test mẫu xanh |
| CP-2 | Step 3, 4 | `flutter analyze` và `flutter test test/features/game/engine/` | Gameplay giống hệt trước (chơi thử vài lượt); test xanh |
| CP-3 | Step 5–20 | `flutter analyze && flutter test --coverage` và kiểm chứng end-to-end (offline, online, thắng level 1, kill app mở lại) | Xanh; coverage từng file mới/sửa ≥ 80% (DoD-2); level 2 được khôi phục |

## Ma trận truy vết rule → bước

| Rule/WF | Bước |
|---------|------|
| BR1.1..BR1.8, WF1 | 5, 6, 7, 8, 15, 16 |
| BR2.1..BR2.4 | 9, 10 |
| BR3.1..BR3.5, WF7 | 11, 12, 19 |
| BR4.1..BR4.3 | 13, 14 |
| BR5.1, BR5.2 | 3, 4 |
| BR5.3..BR5.10, WF2..WF6 | 17, 18, 19, 20 |
| BR6.1, BR6.2 | 1, 21 |
| BR6.3 | 3, 4 |
| BR6.4, BR7.1, BR7.2 | 19, 20 và mọi bước |

## Assumptions & Open Questions

- [assumption] Người dùng đã dùng git nên hai lần zip sao lưu (unit-of-work bước 1 và 2) được bỏ qua. `team.md` vẫn ghi "không dùng git"; điều này không ảnh hưởng đến code, và việc cập nhật memory để người dùng quyết định riêng.
- [assumption] Remote Config key `level_config` đã được publish đúng định dạng E1 theo lời người dùng. Nếu sai, client rơi về `DefaultLevelConfig` (BR1.2).
- [assumption] `lib/features/game/logic/board_logic.dart` đã có phần logic bảng; `BoardEngine` tái dùng và mở rộng nó thay vì viết lại. Tên và chữ ký cuối cùng được ghi trong `code-summary.md`.
- [assumption] iOS chưa có điều kiện build ở U1; kiểm chứng iOS hoãn sang Build & Test nếu cần (DoD của U1 tính theo Android).
