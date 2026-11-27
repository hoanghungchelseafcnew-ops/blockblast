# Quyết định công nghệ: u2-reward-ads

Nguồn: `tech-stack-decisions.md` của `u1-ads-core` và `nfr-requirements-questions.md`.

Không thêm thư viện mới. Reward dùng lại `google_mobile_ads`, `unity_ads_plugin` và `applovin_max` đã thêm ở `u1-ads-core`, qua interface `AdNetworkAdapter` mở rộng thêm thao tác reward. Dấu lần thua chưa ghi nhận lưu qua `ProgressStore` hiện có (SharedPreferences).

| Mục đích | Công nghệ | Lý do |
|----------|-----------|-------|
| Reward AdMob | `RewardedAd` của `google_mobile_ads` | Đã có trong dự án |
| Reward Unity | `UnityAds.showVideoAd` với placement reward | Đã có trong dự án |
| Reward AppLovin | `AppLovinMAX` rewarded ad | Đã có trong dự án |
| Lưu dấu lần thua chưa ghi nhận | `ProgressRepository` / `ProgressStore` | Đã có, có bản giả `FakeProgressStore` |

## Assumptions & Open Questions

None.
