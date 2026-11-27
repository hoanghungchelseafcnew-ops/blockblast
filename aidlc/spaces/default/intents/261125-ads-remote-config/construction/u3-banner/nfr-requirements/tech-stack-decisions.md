# Quyết định công nghệ: u3-banner

Nguồn: `technology-stack.md` của codekb, `tech-stack-decisions.md` của `u1-ads-core`, `functional-spec.md` và `nfr-requirements-questions.md`.

Không thêm thư viện mới. Banner dùng lại `google_mobile_ads` và `applovin_max` đã thêm ở `u1-ads-core`, qua interface `AdNetworkAdapter` mở rộng thêm thao tác banner.

| Mục đích | Công nghệ | Lý do |
|----------|-----------|-------|
| Banner AdMob | `BannerAd` thích ứng neo dưới (anchored adaptive) của `google_mobile_ads` | Đã có trong dự án, rộng bằng màn hình |
| Banner AppLovin | `MaxAdView` banner thích ứng của `applovin_max` | Đã có trong dự án |
| Banner Unity | Không dùng | Q2: thư viện Unity chỉ có cỡ cố định; Unity được bỏ qua khi duyệt `ads_priority` cho banner, vẫn dùng cho reward và interstitial |
| Làm mới banner | Cài đặt trong bảng điều khiển của từng mạng | Q1 |

Hệ quả của Q2: với `ads_priority` là `unity,admob,applovin`, banner thử AdMob rồi AppLovin. Nếu `ads_priority` chỉ có `unity` thì không có banner.

## Assumptions & Open Questions

None.
