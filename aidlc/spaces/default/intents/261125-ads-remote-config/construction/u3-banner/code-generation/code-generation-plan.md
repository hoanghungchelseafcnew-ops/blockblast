# Kế hoạch tạo mã: u3-banner

Nguồn: `functional-spec.md`, `rules.md`, `frontend-components.md`, `performance-design.md`, `security-design.md`, `logical-components.md` của unit này, `tech-stack-decisions.md` (Unity không dùng cho banner, mỗi mạng tự làm mới), `contract-summary.md` (hợp đồng 2: `banner` trả `BannerResult`), `unit-of-work.md`, `requirements.md` (FR2, NFR2) và mã của `u1-ads-core`, `u2-reward-ads`. Unit này thêm vùng banner dưới cùng màn chơi Journey và Endless.

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

- Banner đã tải là một đối tượng `LoadedBanner` (phần tử giao diện, chiều cao, giải phóng) do adapter trả về. Nhờ vậy `AdMediator` chọn mạng mà không phụ thuộc SDK, và bản giả trả đối tượng giả để test (NFR3.3).
- `AdsService` có thêm `bannerChanges` (một `Listenable`) báo mỗi khi một lần mở được ghi xong hoặc đồng ý vừa xử lý xong, và `bannerEligible` cho biết đã đủ điều kiện BR7.1 chưa (Q1 của nfr-design). `NoopAdsService` không bao giờ đủ điều kiện.
- Vùng banner là widget dùng chung `AdBannerSlot`, đặt cuối cột trong `SafeArea`, nên lớp phủ Game Over và Victory (nằm trên cùng `Stack`) vẫn che nó (BR7.6).

## Các bước (test-after)

### Step 1: Kiểm tra trình chạy test
- [ ] Dùng lại lệnh đã duyệt `flutter analyze && flutter test --coverage`. Ghi lệnh riêng của unit vào `unit-test-instructions.md`.

### Step 2: Banner ở lớp mạng quảng cáo
- [ ] `lib/features/ads/services/ad_network_adapter.dart`: thêm `LoadedBanner` (trừu tượng: `height`, `build()`, `dispose()`) và `loadBanner({width, personalized})` trả `LoadedBanner` hoặc null.
- [ ] `lib/features/ads/services/ad_unit_ids.dart`: thêm `bannerId` và `bannerConfigured`; ID banner thử của AdMob cho bản debug, để trống cho bản phát hành và cho AppLovin.
- [ ] `admob_adapter.dart`: `BannerAd` thích ứng neo dưới; `applovin_adapter.dart`: tải trước `MaxAdView` banner thích ứng và hủy khi giải phóng; `unity_adapter.dart`: luôn trả null (Q2 của nfr-requirements). Bắt mọi lỗi.
- [ ] `lib/features/ads/services/ad_mediator.dart`: `BannerResult` (`shown` kèm banner, `hidden`), `AdsService.bannerEligible`, `bannerChanges` và `banner(width)`; thử mạng theo `ads_priority`, 5 giây mỗi mạng; chưa xử lý đồng ý hoặc chưa đủ lần mở thì `hidden` ngay; banner tải xong sau thời hạn thì giải phóng. `NoopAdsService` trả `hidden`.
- [ ] Test: cập nhật `test/features/ads/ads_fakes.dart` và thêm nhóm banner trong `test/features/ads/ad_mediator_test.dart` (chưa đủ lần mở thì `hidden`, đủ thì `shown`, chưa đồng ý thì không gọi mạng, mạng đầu không có thì thử mạng kế, mạng treo thì quá hạn, mạng ném lỗi thì `hidden`, thông báo sau khi đếm lần mở).
- Truy vết: NFR2.16, NFR2.19, NFR2.20, NFR2.22, NFR3.3, BR7.1, BR7.3, BR7.9.

### Step 3: Vùng banner
- [ ] `lib/features/ads/widgets/ad_banner_slot.dart`: `AdBannerSlot` nhận `AdsService`; cao 0 khi không có banner; sau khung hình đầu và mỗi khi `bannerChanges` báo thì thử tải nếu chưa thử trong lần vào này; giữ banner suốt lần vào; giải phóng khi đóng, kể cả banner tải xong muộn.
- [ ] Test: `test/features/ads/ad_banner_slot_test.dart` (không đủ điều kiện thì cao 0, đủ thì hiện với đúng chiều cao, `hidden` thì cao 0 và không thử lại, chạm ngưỡng khi đang mở thì tải ngay, đóng thì giải phóng, tải xong sau khi đóng thì giải phóng, dựng lại không tải lại).
- Truy vết: BR7.2, BR7.4, BR7.5, BR7.7, NFR2.15, NFR2.17, NFR2.21, AC4.1.1, AC4.1.2, AC4.1.5.

### Step 4: Màn chơi
- [ ] `lib/features/game/screens/game_screen.dart` và `lib/features/endless/screens/endless_game_screen.dart`: thêm `AdBannerSlot(ads: widget.ads)` cuối cột trong `SafeArea`.
- [ ] Test: thêm vào `test/ui/game_screen_test.dart` và `test/ui/endless_game_screen_test.dart` (banner hiện dưới khay khối, không có banner thì bố cục như cũ, lớp phủ Game Over che banner, màn hình 360 x 640 không bị che).
- Truy vết: AC4.1.4, AC4.1.6, BR7.6, BR7.8, NFR2.18.

### Step 5: Yêu cầu thay đổi của bạn (2026-11-27, từ Build and Test)

Bạn yêu cầu: banner cỡ nhỏ nhất để có chỗ chơi rộng hơn; bỏ âm thanh khi chơi, chỉ giữ âm qua màn; âm thanh của game không làm dừng nhạc của ứng dụng khác. Lựa chọn: 2a B (giữ `victory` và `unlock`), 2b A (Endless im lặng), 2c B (bỏ rung), 2d B (banner chỉ AdMob và AppLovin).

- [ ] Banner cỡ chuẩn 320 x 50: `admob_adapter.dart` dùng `AdSize.banner` thay cho banner thích ứng lớn; `applovin_adapter.dart` tải trước `MaxAdView` không thích ứng (`isAdaptive: false`), rộng 320, cao 50. `unity_adapter.dart` vẫn trả null.
- [ ] `lib/features/game/services/game_feedback.dart`: `DeviceGameFeedback` không phát âm và không rung khi đặt khối, ăn dòng, combo, bom và thua (Journey và Endless). Chỉ phát `victory` và `unlock`, và `stopSfx` vẫn dừng âm đang phát. Endless không có qua màn nên im lặng hoàn toàn.
- [ ] `lib/core/audio/audio_controller.dart`: `AudioplayersSfxPlayer` đặt `AudioContext` dùng chung trước lần phát đầu tiên, với `AudioContextConfigFocus.mixWithOthers`. Android không giành audio focus; iOS dùng tùy chọn `mixWithOthers`. Nhạc của ứng dụng khác vẫn phát, tiếng game chồng lên. Lỗi đặt `AudioContext` được ghi log, game vẫn phát âm.
- [ ] Test: cập nhật `test/features/game/services/game_feedback_test.dart` (đặt khối, ăn dòng, combo, bom, thua không phát gì; `victory` và `unlock` vẫn phát); thêm test cho `AudioplayersSfxPlayer` với bản giả nền tảng nếu khả thi, nếu không thì ghi là kiểm thủ công trên máy thật; giữ test banner với chiều cao 50.
- Truy vết: yêu cầu thay đổi CR-1 (banner 320 x 50), CR-2 (chỉ âm qua màn), CR-3 (không dừng nhạc ứng dụng khác).

### Step 6: Tổng kết
- [ ] `code-summary.md`, `traceability.json`, `source-manifest.json`.

## Rủi ro

- API banner của AppLovin (tải trước `MaxAdView`) viết theo mã nguồn thư viện 4.6.4; nếu `flutter analyze` báo lỗi sẽ sửa tên tham số.
- Banner thật không chạy trong môi trường test, nên phần SDK trong hai adapter có độ phủ thấp như u1 và u2.
- `game_feedback.dart` và `audio_controller.dart` thuộc workflow `gemstone-journey`; chỉ sửa đúng phần âm thanh và rung theo yêu cầu thay đổi.
- Việc nhạc của ứng dụng khác có tiếp tục phát hay không chỉ kiểm được trên máy thật.

## Assumptions & Open Questions

None.
