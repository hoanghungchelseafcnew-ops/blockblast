# Kế hoạch tạo mã: u1-ads-core

Nguồn: `functional-spec.md`, `rules.md`, `entities.md`, `security-design.md`, `logical-components.md`, `tech-stack-decisions.md`, `contract-summary.md` và `unit-of-work.md`. Bản mỏng chạy xuyên suốt: đọc cấu hình, đếm lần mở và lần bấm Start, xử lý đồng ý, chọn mạng theo `ads_priority` và hiện interstitial.

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

## Quy ước

- Mã ứng dụng nằm ở gốc dự án, theo cấu trúc feature-first: thư mục mới `lib/features/ads/{models,services}`, và các tệp hiện có được sửa tại chỗ.
- Logic nằm ở service, màn hình chỉ vẽ. Mọi SDK nằm sau interface có bản giả để test (NFR3.1).
- Mọi chuỗi hiển thị trên giao diện chỉ dùng tiếng Anh. U1 không thêm chuỗi giao diện nào, hộp thoại đồng ý do SDK vẽ.
- AI chỉ sinh code và test. Bạn chạy `flutter pub get`, `flutter analyze` và `flutter test --coverage` rồi báo kết quả.
- Không sửa các tệp ngoài danh sách dưới đây.

## Các bước (test-after: mỗi lớp viết xong rồi mới viết và chạy test của lớp đó)

### Step 1: Thư viện và cấu hình nền tảng
- [ ] Thêm vào `pubspec.yaml`: `google_mobile_ads: ^9.2.0`, `unity_ads_plugin: ^0.6.0`, `applovin_max: ^4.6.4`, `app_tracking_transparency: ^2.0.7`, `package_info_plus: ^10.2.2`. Bạn chạy `flutter pub get` và báo kết quả. Nếu báo lỗi Flutter 3.38.0, hạ về `google_mobile_ads: ^7.0.0` và `package_info_plus: ^9.0.1`. (NFR2.3, `tech-stack-decisions.md`)
- [ ] `android/app/src/main/AndroidManifest.xml`: thêm ID ứng dụng AdMob (ID thử của Google cho bản debug) và SDK key AppLovin. (BR5.2)
- [ ] `ios/Runner/Info.plist`: thêm `GADApplicationIdentifier`, `NSUserTrackingUsageDescription` (câu chữ tiếng Anh) và danh sách `SKAdNetworkItems` tối thiểu. (BR3.4)
- Truy vết: NFR2.3, BR5.2, BR3.4.

### Step 2: Mở rộng cổng Remote Config
- [ ] `lib/core/config/remote_config_client.dart`: thêm `readString(key)`, `readInt(key)`, `readBool(key)`, chỉ trả giá trị khi nguồn là remote, giữ nguyên `readLevelConfig`. (ADR-004, NFR7.1)
- [ ] `lib/core/firebase/firebase_remote_config_client.dart`: cài đặt ba hàm trên, giữ `fetchTimeout` 2 giây và `minimumFetchInterval` 12 giờ. (NFR6.1)
- [ ] `test/fakes/fake_remote_config_client.dart`: thêm khả năng đặt giá trị theo khóa.
- [ ] Test: `test/core/config/firebase_remote_config_client_test.dart` cập nhật cho ba hàm mới (nguồn remote, nguồn mặc định, giá trị rỗng). Các kiểm thử cũ vẫn xanh.
- Truy vết: AC1.1.1, AC1.1.2, BR1.1, BR1.2.

### Step 3: AdsSettings và AdsConfig
- [ ] `lib/features/ads/models/ads_settings.dart`: thực thể `AdsSettings` chỉ đọc với giá trị mặc định (`entities.md`).
- [ ] `lib/features/ads/services/ads_config.dart`: `AdsConfig` đọc qua `RemoteConfigClient`, kiểm tra số nguyên dương, chuẩn hóa `ads_priority` (mặc định, bỏ tên lạ), ghi cảnh báo qua `GjLog` khi giá trị sai, không ném lỗi. (BR1.1 đến BR1.3, BR2.2, BR2.3)
- [ ] Test: `test/features/ads/ads_config_test.dart` (giá trị hợp lệ, không tải được, số sai, `ads_priority` thiếu hoặc rỗng hoặc có tên lạ, cảnh báo không chứa giá trị thô).
- Truy vết: AC1.1.1 đến AC1.1.3, AC1.2.2, AC1.2.3.

### Step 4: AdCounters
- [ ] `lib/features/ads/services/ad_counters.dart`: `AdCounters` lưu `appOpenCount`, `startCount`, `interstitialCarriedDue` qua `ProgressStore`, chỉ tăng, không đồng bộ giá trị âm. (BR4.1, BR5.1)
- [ ] Test: `test/features/ads/ad_counters_test.dart` (tăng đúng một, giữ giá trị khi tạo lại từ kho lưu giả, lỗi ghi không ném).
- Truy vết: AC2.1.2, BR4.1, BR5.1.

### Step 5: ConsentService
- [ ] `lib/features/ads/services/consent_service.dart`: interface cổng đồng ý, `ConsentService` với máy trạng thái trong `functional-spec.md`, và cài đặt thật dùng UMP của `google_mobile_ads` cùng `app_tracking_transparency`. Chạy nền, không chặn Splash. (BR3.1 đến BR3.4, BR1.4)
- [ ] Test: `test/features/ads/consent_service_test.dart` với cổng giả (không cần, đã đồng ý, từ chối, lỗi SDK).
- Truy vết: AC1.3.1 đến AC1.3.3.

### Step 6: Mạng quảng cáo và AdMediator
- [ ] `lib/features/ads/services/ad_network_adapter.dart`: interface và kết quả (`ready`, `no_fill`, `shown`, `error`).
- [ ] `lib/features/ads/services/ad_unit_ids.dart`: hằng số riêng cho từng nền tảng và mạng, ID thử trong debug, ID phát hành để trống và có ghi chú TODO kèm lý do (không lưu khóa bí mật, mạng nào chưa có ID thì coi như không có quảng cáo). (BR5.2, NFR2.3, NFR2.4)
- [ ] `lib/features/ads/services/admob_adapter.dart`, `unity_adapter.dart`, `applovin_adapter.dart`: bọc SDK, bắt mọi lỗi. (NFR2.1)
- [ ] `lib/features/ads/services/ad_mediator.dart`: `AdMediator` với thứ tự mạng, thời hạn 5 giây cho mỗi mạng, hỏi `ConsentService` trước, tải trước `InterstitialSlot`, `interstitialIfDue` (đủ N lần hoặc đang bù, bỏ qua và đánh dấu bù nếu chưa sẵn sàng, không chờ). (BR2.1, BR2.4, BR2.5, BR4.2 đến BR4.6, NFR2.2, NFR2.5)
- [ ] Test: `test/features/ads/ad_mediator_test.dart` với adapter giả và đồng hồ giả (thứ tự mạng, mạng đầu thất bại thì thử mạng kế, hết 5 giây, mọi mạng không có, đủ N lần, bù lượt, chưa sẵn sàng, chưa đồng ý, Endless, không có khoảng cách tối thiểu). Test adapter SDK thật chỉ kiểm lớp bọc bằng ngoại lệ giả.
- Truy vết: AC1.2.1, AC1.2.4, AC2.1.1, AC2.1.3 đến AC2.1.5.

### Step 7: Nối vào khởi động và vòng đời ứng dụng
- [ ] `lib/features/journey/services/app_bootstrap.dart`: thêm `AdsConfig`, `AdCounters`, `ConsentService` và `AdMediator` vào `AppServices`; nạp cấu hình quảng cáo, ghi nhận lần mở khởi động nguội, khởi chạy đồng ý và tải trước ở nền, không nằm trong hạn chót 3,5 giây. (BR1.4, BR5.1, NFR1.1)
- [ ] `lib/app_composition.dart`: dựng các dịch vụ thật.
- [ ] `lib/features/ads/services/ad_lifecycle_observer.dart`: ghi nhận lần quay lại từ nền và loại trừ lần quay lại do quảng cáo hoặc hộp thoại hệ thống hoặc bảng chia sẻ. (BR5.1, BR5.3)
- [ ] Test: cập nhật `test/features/journey/app_bootstrap_test.dart` (quảng cáo treo mà Splash vẫn qua trong hạn chót) và thêm `test/features/ads/ad_lifecycle_observer_test.dart`.
- Truy vết: AC1.1.4, BR1.4, BR5.1, BR5.3.

### Step 8: Nối vào màn hình
- [ ] `lib/features/home/screens/home_screen.dart`: sau khi bấm PLAY, gọi `AdMediator.interstitialIfDue` rồi mở màn chơi; hỏi đồng ý sau lần vào Home đầu tiên. (BR3.4, BR4.1 đến BR4.3)
- [ ] `lib/features/game/screens/game_screen.dart` và `lib/features/endless/screens/endless_game_screen.dart`: PLAY AGAIN gọi `interstitialIfDue` trước khi bắt đầu lại. (BR4.1, BR4.3)
- [ ] Test: cập nhật `test/ui/splash_home_test.dart`, `test/ui/game_screen_test.dart`, `test/ui/endless_game_screen_test.dart` với `AdMediator` giả.
- Truy vết: AC2.1.1, AC2.1.3.

### Step 9: Tổng kết
- [ ] `code-summary.md`, `traceability.json` và `source-manifest.json` liệt kê mọi tệp đã tạo hoặc sửa. Ghi chú các ID quảng cáo phát hành cần bạn điền.

## Rủi ro

- Ba SDK cùng lúc có thể xung đột phiên bản thư viện gốc, nên sau Step 1 bạn cần chạy thử `flutter build apk` và `flutter build ios` rồi báo kết quả.
- Mở rộng `RemoteConfigClient` chạm nhiều tệp kiểm thử hiện có (NFR7.1).
- Hai tệp thuộc workflow cũ `gemstone-journey` bị sửa: `app_composition.dart`, `remote_config_client.dart`, `firebase_remote_config_client.dart`, `AndroidManifest.xml`. Chỉ sửa đúng phần liệt kê ở trên.

## Assumptions & Open Questions

None.
