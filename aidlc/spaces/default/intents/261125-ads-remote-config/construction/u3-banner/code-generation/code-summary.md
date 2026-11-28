# Tóm tắt mã: u3-banner

Conductor tự viết mã theo `code-generation-plan.md` đã được bạn duyệt, vì trợ lý developer không có công cụ ghi file trong phiên này. Mã bám theo `functional-spec.md`, `rules.md`, `performance-design.md`, `security-design.md`, `contract-summary.md` (hợp đồng 2, `BannerResult`), `unit-of-work.md` và `requirements.md` (FR2, NFR2).

## Tệp mới

| Tệp | Nội dung |
|-----|----------|
| `lib/features/ads/widgets/ad_banner_slot.dart` | `AdBannerSlot`: cao 0 khi không có banner, thử tải một lần mỗi lần vào màn chơi, tải ngay khi điều kiện vừa thỏa, giải phóng khi đóng |
| `test/features/ads/ad_banner_slot_test.dart` | 8 test cho vùng banner |

## Tệp sửa

| Tệp | Thay đổi |
|-----|----------|
| `ad_network_adapter.dart` | `LoadedBanner` (chiều cao, phần tử giao diện, giải phóng) và `loadBanner` |
| `ad_unit_ids.dart` | `bannerId` và `bannerConfigured`; ID banner thích ứng thử của AdMob cho bản debug |
| `admob_adapter.dart` | Banner thích ứng neo dưới (`getLargeAnchoredAdaptiveBannerAdSize`) |
| `applovin_adapter.dart` | Tải trước `MaxAdView` banner thích ứng, hủy khi giải phóng |
| `unity_adapter.dart` | `loadBanner` luôn trả null (Q2 của nfr-requirements) |
| `ad_mediator.dart` | `BannerResult`, `bannerEligible`, `bannerChanges`, `banner(width)`; thông báo sau khi khởi động xong và sau mỗi lần mở được ghi; banner tải xong sau thời hạn bị giải phóng |
| `game_screen.dart`, `endless_game_screen.dart` | `AdBannerSlot` cuối cột trong `SafeArea` |
| Test hiện có | `ads_fakes.dart` (banner giả), `ad_mediator_test.dart` (+8), `app_bootstrap_test.dart` (bản thăm dò có thêm phần banner), `game_screen_test.dart` (+4), `endless_game_screen_test.dart` (+1) |

## Quyết định khi viết mã

- AdMob dùng `getLargeAnchoredAdaptiveBannerAdSize` vì hàm cũ đã bị đánh dấu deprecated trong `google_mobile_ads` 9.2.0. Chiều cao do Google tính, tối đa 15% chiều cao màn hình.
- AppLovin báo kết quả tải trước qua một listener dùng chung, nên mỗi lần chỉ có một lần tải banner AppLovin.
- Khi banner đã hiện mà sau đó SDK báo lỗi lúc tự làm mới, vùng banner không tự ẩn: SDK giữ quảng cáo cũ. Thiết kế (NFR2.20) dự định ẩn trong trường hợp này. Vì `LoadedBanner` chưa có kênh báo lỗi sau khi hiện, phần này chưa làm.

## Kiểm thử

Lệnh đã duyệt `flutter analyze && flutter test --coverage` đã chạy:
- `flutter analyze`: không có lỗi.
- `flutter test --coverage`: 632 test pass, 1 skip có sẵn từ trước.
- Độ phủ dòng: 87,4% (3011/3444). Sàn là 80%. Phần SDK banner trong hai adapter không chạy được trong môi trường test.
- Lần này chỉ chạy `dart format` trên các tệp của unit.

## Yêu cầu thay đổi (2026-11-27, quay lại từ Build and Test)

| Mã | Yêu cầu | Thay đổi |
|----|---------|----------|
| CR-1 | Banner nhỏ nhất để có chỗ chơi rộng hơn | AdMob dùng `AdSize.banner` (320 x 50); AppLovin tải trước `MaxAdView` không thích ứng, 320 x 50 (`admob_adapter.dart`, `applovin_adapter.dart`). Unity vẫn không dùng cho banner |
| CR-2 | Bỏ âm thanh khi chơi, chỉ giữ âm qua màn | `DeviceGameFeedback` (`game_feedback.dart`) không phát âm và không rung khi đặt khối, ăn dòng, combo, bom, thua. Chỉ phát `victory` và `unlock`. Endless im lặng hoàn toàn |
| CR-3 | Không làm dừng nhạc của ứng dụng khác | `AudioplayersSfxPlayer` (`audio_controller.dart`) đặt `AudioContext` dùng chung với `mixWithOthers` trước lần phát đầu tiên: Android không giành audio focus, iOS dùng tùy chọn `mixWithOthers`. Lỗi được ghi log |

Test: `game_feedback_test.dart` viết lại theo hành vi mới (6 test), thêm `test/core/audio/audioplayers_sfx_player_test.dart` (4 test). Kiểm lại: `flutter analyze` sạch, 672 test pass, 1 skip có sẵn, độ phủ 87,8%. Việc nhạc của ứng dụng khác vẫn phát chỉ kiểm được trên máy thật.

`game_feedback.dart` và `audio_controller.dart` thuộc workflow `gemstone-journey`; chỉ phần âm thanh và rung được sửa.

## Việc bạn cần làm trước khi phát hành

- Điền `bannerId` thật cho AdMob và AppLovin trong `ad_unit_ids.dart`.
- Kiểm tra cài đặt làm mới banner trong bảng điều khiển AdMob và AppLovin.
