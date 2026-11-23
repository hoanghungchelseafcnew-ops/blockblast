# Kế hoạch Code Generation — U5 `u5-analytics`

## Sources

- [units] `inception/units-generation/unit-of-work.md` (U5: `AnalyticsService` abstract + Firebase + fake, dependency `firebase_analytics`; `LevelGameController` gửi `level_start`, `level_complete`, `level_fail` và user property từ `JourneyOutcome`; `SessionTracker` với `Clock`, gửi `game_session` khi paused, `addPlayTime`; endless không gửi event level) và `unit-of-work-story-map.md` (U5: US6.3 → US6.4)
- [contract] `inception/contract-design/contract-summary.md`:
  - C4: `AnalyticsService`. U1 đã định nghĩa interface và `NoopAnalyticsService`, U5 triển khai.
  - E2: tên event và tham số cố định; user property `current_major_level`, `highest_level_reached`, `config_source`.
  - C5: `addPlayTime(int seconds)`. E3: key `total_play_time`.
- [req] `inception/requirements-analysis/requirements.md`: FR4.1..FR4.4, FR8.1 (`total_play_time`), FR8.2, NFR4, NFR6
- [stories] `inception/user-stories/stories.md`: AC6.3.1, AC6.3.2, AC6.4.1..AC6.4.3, AC1.6.2 (U1 để lại: "Left out of this build: AC1.6.2")
- [mock] `inception/refined-mockups/interaction-spec.md` (Trạng thái hệ thống: app vào background thì lưu `total_play_time`)
- [code] Code hiện có: `AnalyticsService` / `NoopAnalyticsService` (U1), `FirebaseGateway`, `AppBootstrap`, `AppServices`, `LevelGameController`, `ProgressRepository`, `ProgressLifecycleObserver`, `Clock`, `LevelConfig.source`
- [user] Người dùng chọn làm tiếp U5 và U6 mà không chạy lại các stage thiết kế (tin nhắn `f93f215d`)
- [prac] `aidlc/spaces/default/memory/team.md`: test-after, coverage ≥ 80%, Firebase bọc sau service

U5 không có artifact functional design, NFR hay infrastructure riêng, vì các stage thiết kế đã bị đánh dấu `[S]` do một lần nhảy stage trước đây. Kế hoạch dựa trực tiếp vào contract C4/E2, requirements và story ở trên.

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

Ghi chú áp dụng hợp đồng: trong lúc làm U5, AI chạy `flutter pub add`, `flutter analyze` và `flutter test` bằng Flutter Linux 3.41.5 trong WSL. Người dùng không build trên Windows cho tới khi U5 xong, sau đó chạy `flutter pub get` trên Windows. Không có CI, nên "Run in CI before merge" được đáp ứng bằng lệnh kiểm chứng `flutter analyze && flutter test --coverage` ở checkpoint của unit. Lớp "API / endpoint" ở đây là ranh giới với SDK Firebase Analytics: tên event và tham số theo E2, kiểm qua client giả.

## Quy ước

- Brownfield: sửa file tại chỗ.
- Firebase Analytics chỉ được gọi qua `AnalyticsClient`. Không lớp nào khác import `firebase_analytics` (team.md, Code Style).
- Tên event, tên tham số và tên user property **đúng nguyên văn E2**. Chỉ được thêm, không được đổi tên.
- Mọi hàm của `AnalyticsService` không bao giờ throw. Lỗi SDK được log bằng `GjLog` (tên event và `err.runtimeType`), không bị nuốt (C4).
- Không gửi dữ liệu cá nhân (E2 `x-rules`).
- Dependency mới duy nhất: `firebase_analytics`, phiên bản tương thích với `firebase_core` đang dùng (NFR4).
- Không đổi quy tắc ván chơi.

## Các bước

### Giai đoạn A — Chuẩn bị

- [x] **Step 1 — Dependency và cấu trúc.**
  - Chạy `flutter pub add firebase_analytics`. Pub tự chọn phiên bản tương thích với `firebase_core` hiện tại. Nếu không giải được thì dừng và báo người dùng, không tự nâng `firebase_core`.
  - File mới: `lib/core/analytics/firebase_analytics_service.dart`, `lib/core/analytics/session_tracker.dart`.
  - Truy vết: NFR4, AC8.4.2.
- [x] **Step 2 — Xác minh test runner.** Chạy `flutter test` trên code hiện tại để có mốc xanh. Lệnh được ghi trong `unit-test-instructions.md`.

### Giai đoạn B — Data model

- [x] **Step 3 — Tên event và tham số theo E2 — implement.**
  - Trong `analytics_service.dart`, thêm `abstract final class AnalyticsNames`:
    - event: `level_start`, `level_complete`, `level_fail`, `game_session`
    - tham số: `major`, `sub`, `level_index`, `score`, `target`, `duration_sec`
    - user property: `current_major_level`, `highest_level_reached`, `config_source`
  - Hàm thuần `levelParams(level)` trả `{major: gemId, sub: subId, level_index}`. `level_index` ngoài 1..36 thì log và không gửi event (AC6.3.1 yêu cầu 1..36).
  - Truy vết: FR4.1, FR4.2, E2.
- [x] **Step 4 — Data model: test.** `test/core/analytics/analytics_names_test.dart`:
  - Tên đúng nguyên văn E2.
  - `levelParams` cho level 1 và 36 (`major`, `sub`, `level_index`).
  - Level dựng tay với chỉ số 0 hoặc 37 bị từ chối.

### Giai đoạn C — Repository / ranh giới SDK

- [x] **Step 5 — `AnalyticsClient`, `FirebaseAnalyticsService`, `total_play_time` — implement.**
  - `AnalyticsClient`: interface với `logEvent(name, params)` và `setUserProperty(name, value)`. Bản thật bọc `FirebaseAnalytics.instance`.
  - `FirebaseAnalyticsService implements AnalyticsService` (C4):
    - Map từng hàm sang event hoặc user property theo E2.
    - `highest_level_reached` gửi dạng chuỗi số (E2: user property là string).
    - Bọc mọi lời gọi trong try/catch kèm log.
    - SDK tự xếp hàng khi offline (FR4.3), không cần làm thêm.
  - `ProgressRepository`:
    - Key `total_play_time` (int giây, mặc định 0, E3).
    - Giá trị âm hoặc sai kiểu thì về 0 và log.
    - Thêm `totalPlayTime` và `addPlayTime(seconds)` qua cùng hàng đợi FIFO, có dirty và thử lại (C5). Giây ≤ 0 thì bỏ qua.
  - Truy vết: C4, C5, E2, E3, FR4.1..FR4.3, FR8.1, AC6.4.3.
- [x] **Step 6 — Repository / ranh giới: test.**
  - `test/core/analytics/firebase_analytics_service_test.dart` (dùng `FakeAnalyticsClient`):
    - Mỗi hàm gửi đúng tên và tham số (AC6.3.1).
    - `level_complete` và `level_fail` có `score` và `target`.
    - `highest_level_reached` dạng chuỗi.
    - `config_source` là `remote`, `cached` hoặc `default`.
    - Client ném lỗi thì có log và hàm không ném ra.
  - Bổ sung `progress_repository_test.dart` cho `total_play_time`:
    - Thiếu key → 0; giá trị âm hoặc sai kiểu → 0 và có log.
    - `addPlayTime` cộng dồn và được đọc lại sau khi khởi động lại.
    - Giây ≤ 0 bị bỏ qua.
    - Ghi lỗi → dirty → ghi lại.

### Giai đoạn D — Business logic

- [x] **Step 7 — `SessionTracker`, nối analytics vào ván chơi và bootstrap — implement.**
  - `SessionTracker` (tiêm `Clock`, `AnalyticsService`, `ProgressRepository`):
    - `start()` khi app chạy hoặc trở lại `resumed`.
    - Khi `paused` (app vào nền hoặc thoát): tính số giây từ lần `start` gần nhất, gửi `game_session{duration_sec}`, gọi `addPlayTime` (AC6.4.1, AC1.6.2).
    - Gọi `paused` hai lần liên tiếp chỉ đếm một lần.
    - Phiên 0 giây thì không gửi.
  - `LevelGameController` nhận `AnalyticsService` (mặc định `NoopAnalyticsService`):
    - `start()` gửi `level_start`.
    - Thắng: gửi `level_complete`, rồi `setProgressProperties` với gem của level kế tiếp (gem hiện tại nếu là level 36) và `highestLevelReached` của outcome.
    - Thua: gửi `level_fail`, rồi `setProgressProperties`.
    - Mỗi round gửi mỗi event đúng một lần. Gọi analytics không chặn việc chuyển trạng thái (dùng `unawaited`).
    - Endless (U6) sẽ dùng controller riêng, không gửi event level (AC6.3.2, FR4.4).
  - `AppServices` thêm `analytics` và `session`. `AppBootstrap`:
    - Firebase `ok` → `FirebaseAnalyticsService`; không thì `NoopAnalyticsService`.
    - Gọi `setConfigSource(config.source.label)` một lần sau bootstrap (E2).
  - Truy vết: FR4.1, FR4.2, FR4.4, FR8.2, AC6.3.1, AC6.3.2, AC6.4.1, AC6.4.2, AC1.6.2, C4.
- [x] **Step 8 — Business logic: test.**
  - `test/core/analytics/session_tracker_test.dart` (dùng `FakeClock`, `FakeAnalytics`):
    - 90 giây rồi `paused` → `game_session{duration_sec: 90}` và `total_play_time` tăng 90.
    - `paused` hai lần chỉ đếm một lần.
    - `resumed` bắt đầu phiên mới.
    - Phiên 0 giây không gửi.
    - `addPlayTime` lỗi vẫn gửi event.
  - Bổ sung `level_game_controller_test.dart`:
    - `start` gửi `level_start` một lần với đúng level.
    - Thắng gửi `level_complete` với score và target, kèm `setProgressProperties(<gem kế>, highest)`.
    - Thắng Bling thì `current_major_level` là gem kế tiếp.
    - Thua gửi `level_fail`.
    - `highest_level_reached` không giảm sau khi thua (AC6.4.2).
    - PLAY AGAIN và CONTINUE gửi `level_start` mới.
    - QUIT không gửi `level_fail`.
  - Bổ sung `app_bootstrap_test.dart`:
    - Firebase ok → analytics Firebase và `setConfigSource` được gọi.
    - Firebase lỗi → Noop.

### Giai đoạn E — Frontend

- [x] **Step 9 — Nối vòng đời app — implement.**
  - `HomeScreen` gắn một observer vòng đời cho `services.session`: `resumed` → `start`, `paused` → `pause`. Observer được gắn cạnh `ProgressLifecycleObserver` hiện có.
  - `HomeScreen._startGame` truyền `services.analytics` vào `LevelGameController`.
  - Không có thay đổi giao diện.
  - Truy vết: AC6.4.1, AC1.6.2.
- [x] **Step 10 — Frontend: widget test.** Bổ sung `test/ui/splash_home_test.dart`:
  - App vào nền ở Home thì có `game_session` và `total_play_time` được ghi.
  - Bấm PLAY thì có `level_start` cho level hiện tại.
  - Cập nhật `ui_test_helpers.dart` (`buildServices` có analytics giả và `SessionTracker` với `FakeClock`).

### Giai đoạn F — Cấu hình và tài liệu

- [x] **Step 11 — Environment/build configuration.**
  - Rà `pubspec.yaml` và `pubspec.lock`, chỉ có thêm `firebase_analytics` và các gói phụ thuộc của nó.
  - Ghi chú cho người dùng: bật Google Analytics trong Firebase project. Để xem DebugView trên Android: `adb shell setprop debug.firebase.analytics.app com.h2.game.block_blast` (AC6.4.3, người dùng kiểm tra).
  - Chạy `dart format` chỉ cho các file U5 tạo hoặc sửa và `flutter analyze` sạch.
- [x] **Step 12 — Tài liệu và truy vết.**
  - Chạy `flutter analyze && flutter test --coverage`.
  - Kiểm tra coverage ≥ 80% cho mọi file U5 tạo hoặc sửa (DoD-2).
  - Viết `code-summary.md`, `source-manifest.json` và `traceability.json`.

## Ma trận truy vết

| Yêu cầu / AC | Bước |
|--------------|------|
| FR4.1, AC6.3.1, E2 | 3, 4, 5, 6, 7, 8 |
| FR4.2, AC6.4.2 | 5, 6, 7, 8 |
| FR4.3, AC6.4.3 | 5, 11 (người dùng kiểm tra bằng DebugView) |
| FR4.4, AC6.3.2 | 7 (endless dùng controller riêng ở U6) |
| AC6.4.1, AC1.6.2, FR8.1 (`total_play_time`), FR8.2 | 5, 6, 7, 8, 9, 10 |
| C4 | 5, 6, 7 |
| C5, E3 (`addPlayTime`, `total_play_time`) | 5, 6 |
| NFR4, AC8.4.2 | 1, 11 |
| E2 `config_source` | 5, 6, 7, 8 |

## Assumptions & Open Questions

- [assumption] `current_major_level` là `gemId` của level người chơi sẽ chơi tiếp: gem của `nextLevel`, hoặc gem hiện tại ở level 36 và khi thua.
- [assumption] Một "phiên" tính từ lúc app mở hoặc trở lại `resumed` tới lúc `paused`. Thời gian ở Splash cũng được tính.
- [assumption] Contract E2 có ghi `game_session` có thể trùng với session tự động của Firebase. Tên được giữ theo FR4 như đã chốt; quyết định cuối thuộc về người dùng trước khi phát hành.
- [assumption] Nếu Firebase không khởi tạo được (offline lần đầu), phiên đó dùng `NoopAnalyticsService` và không gửi event nào. SDK chỉ xếp hàng event khi Firebase đã khởi tạo.
- [assumption] Chưa có test tích hợp với Firebase thật. Người dùng kiểm tra bằng DebugView (AC6.4.3).
