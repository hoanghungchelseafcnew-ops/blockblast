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

## Việc bạn cần làm trước khi phát hành

- Điền `bannerId` thật cho AdMob và AppLovin trong `ad_unit_ids.dart`.
- Kiểm tra cài đặt làm mới banner trong bảng điều khiển AdMob và AppLovin.
