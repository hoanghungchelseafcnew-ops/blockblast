# Tóm tắt build và kiểm thử

Nguồn: `code-generation-plan.md` (Testing Contract), `unit-test-instructions.md` và `code-summary.md` của bốn unit, cùng `nfr-requirements/` và `nfr-design/` của từng unit.

## Trạng thái

- Mã Dart: phân tích sạch, 672 test pass, độ phủ 87,8% (sau yêu cầu thay đổi CR-1 đến CR-3).
- Build Android: **thất bại** do Kotlin Gradle Plugin 2.1.0 cũ hơn SDK AdMob (xem `test-results.md`).
- Build iOS và kiểm thử trên máy thật: chưa chạy.

## Loại kiểm thử đã có

- Unit test và widget test trong từng unit (`unit-test-instructions.md`).
- Kiểm thử tích hợp ở ranh giới giữa các unit, và danh sách kiểm thử thủ công trên máy thật (`integration-test-instructions.md`).
- Chiến lược Standard nên không có tệp hướng dẫn hiệu năng hay bảo mật riêng. Các yêu cầu hiệu năng và bảo mật của từng unit được kiểm bằng unit test (bảng dưới).

## Target Verification Matrix

| Target ID | Source | Expected | Actual | Evidence | Owning Stage | Verdict |
|-----------|--------|----------|--------|----------|--------------|---------|
| TC-ANALYZE | Testing Contract (team) | `flutter analyze` không lỗi | Không lỗi | Điểm kiểm tra u4, exit 0 | build-and-test | Met |
| TC-TESTS | Testing Contract (org, team) | Mọi test pass | 672 pass, 1 skip | Điểm kiểm tra u4 | build-and-test | Met |
| TC-WIDGET | Testing Contract (team) | `test/widget_test.dart` pass | Pass | Điểm kiểm tra u4 | build-and-test | Met |
| TC-COVERAGE | Testing Contract (org, team) | Độ phủ dòng ≥ 80% | 87,8% | `coverage/lcov.info` | build-and-test | Met |
| BUILD-ANDROID | `build-instructions.md` | `flutter build apk` thành công | Lần 1 thất bại ở `compileDebugKotlin`; đã sửa Kotlin, chờ build lại | Log build của bạn | build-and-test | Unverified |
| BUILD-IOS | `build-instructions.md` | `flutter build ipa` thành công | Chưa chạy | — | build-and-test | Unverified |
| NFR1 | u1 `performance-requirements.md` | Khởi động không vượt 3,5 giây khi quảng cáo treo | Đạt trong test | `app_bootstrap_test.dart` | build-and-test | Met |
| NFR2.1–NFR2.7 | u1 NFR | Lỗi quảng cáo không dừng game, đồng ý, ID thử | Đạt trong test | `ad_mediator_test.dart`, `consent_service_test.dart` | build-and-test | Met |
| NFR2.8–NFR2.14 | u2 NFR | Reward không chờ, thua ghi nhận đúng một lần | Đạt trong test | `level_game_reward_test.dart`, `pending_loss_store_test.dart` | build-and-test | Met |
| NFR2.15, NFR2.16, NFR2.18–NFR2.22 | u3 NFR | Banner không chặn, 5 giây, giải phóng, không che | Đạt trong test | `ad_banner_slot_test.dart`, `game_screen_test.dart` | build-and-test | Met |
| NFR2.17 | u3 `performance-requirements.md` | Cài đặt làm mới banner được xem lại trước khi phát hành | Chưa xem | Bảng điều khiển AdMob và AppLovin | build-and-test | Unverified |
| NFR1.2, NFR2.23, NFR6.2, NFR8.1–NFR8.3 | u4 NFR | Popup không chặn, đường dẫn chỉ `https`, không ghi log giá trị | Đạt trong test | `update_popup_test.dart`, `version_check_test.dart`, `app_update_checker_test.dart` | build-and-test | Met |
| NFR3.1–NFR3.4 | NFR của các unit | Mã SDK sau interface có bản giả | Đạt | `ads_fakes.dart`, `update_fakes.dart` | build-and-test | Met |
| NFR7.1, NFR7.2 | u1, u2 NFR | Test cũ vẫn xanh | Đạt | Toàn bộ suite | build-and-test | Met |
| CR-1 | Yêu cầu thay đổi | Banner cao 50 | 50 trong test; AdMob `AdSize.banner`, AppLovin 320 x 50 | `ad_banner_slot_test.dart`, `game_screen_test.dart` | build-and-test | Met |
| CR-2 | Yêu cầu thay đổi | Chỉ âm qua màn, không rung khi chơi | Đạt trong test | `game_feedback_test.dart` | build-and-test | Met |
| CR-3 | Yêu cầu thay đổi | Nhạc ứng dụng khác vẫn phát khi chơi | Ngữ cảnh `mixWithOthers` đúng trong test; chưa thử máy thật | `audioplayers_sfx_player_test.dart` | build-and-test | Unverified |
| DEVICE-ADS | `integration-test-instructions.md` | Quảng cáo, đồng ý, cửa hàng chạy trên máy thật | Chưa chạy | — | build-and-test | Unverified |

## Mức sẵn sàng

- Sẵn sàng build: chưa. Cần sửa Kotlin rồi build lại.
- Sẵn sàng kiểm thử: mã Dart đã kiểm xong; kiểm thử trên máy thật chờ bản build.
- Sẵn sàng phát hành: chưa. Còn ID quảng cáo thật, link cửa hàng thật và các mục kể trên.

## Việc còn lại

- Sửa cấu hình Kotlin và build lại Android.
- Build iOS trên macOS.
- Kiểm thử trên máy thật theo `integration-test-instructions.md`.
- Xem lại cài đặt làm mới banner trong bảng điều khiển của AdMob và AppLovin.
- Truy vết FR và NFR cấp cao: xem `cross-unit-traceability.md`.

## Assumptions & Open Questions

None.
