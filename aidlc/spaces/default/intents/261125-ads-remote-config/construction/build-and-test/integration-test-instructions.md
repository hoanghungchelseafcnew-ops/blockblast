# Hướng dẫn kiểm thử tích hợp: đợt quảng cáo và Remote Config

Chiến lược kiểm thử: Standard. Nguồn: `unit-test-instructions.md` và `code-summary.md` của bốn unit.

## Ranh giới giữa các unit đã có kiểm thử tự động

Các kiểm thử dưới đây chạy trong `flutter test`, dùng bản giả `FakeAdsService`, `FakeAdNetwork`, `FakeRemoteConfigClient`, `FakeProgressStore`, `FakeInstalledVersionReader` và `FakeStoreLauncher`.

| Ranh giới | Unit | Tệp test |
|-----------|------|----------|
| Remote Config → `AdsSettings` → bootstrap | u1 | `test/features/ads/ads_config_test.dart`, `test/features/journey/app_bootstrap_test.dart` |
| `AdMediator` ↔ ba adapter (thứ tự mạng, thời hạn, đồng ý) | u1, u2, u3 | `test/features/ads/ad_mediator_test.dart` |
| Home → interstitial → màn chơi | u1 | `test/ui/splash_home_test.dart`, `test/ui/game_screen_test.dart` |
| `LevelGameController` ↔ `AdsService.reward` ↔ `PendingLossStore` ↔ tiến trình | u2 | `test/features/journey/level_game_reward_test.dart`, `test/features/journey/app_bootstrap_test.dart` |
| Màn chơi ↔ `AdBannerSlot` ↔ `AdsService.banner` | u3 | `test/features/ads/ad_banner_slot_test.dart`, `test/ui/game_screen_test.dart`, `test/ui/endless_game_screen_test.dart` |
| Home ↔ `AppUpdateChecker` ↔ popup ↔ `StoreLauncher`; chia sẻ có link | u4 | `test/features/update/*.dart`, `test/features/game/services/score_share_service_test.dart` |

Lệnh chạy:

```bash
flutter test --coverage
```

Mục tiêu: mọi test pass, độ phủ dòng toàn codebase ít nhất 80%, `test/widget_test.dart` pass.

## Kiểm thử trên máy thật (thủ công)

SDK quảng cáo thật, hộp thoại đồng ý và việc mở cửa hàng không chạy được trong `flutter test`. Chạy bản debug trên một máy Android và một máy iOS:

1. Cài mới ứng dụng. Ở lần vào Home đầu tiên, hộp thoại đồng ý (và trên iOS, hộp thoại xin phép theo dõi) hiện.
2. Bấm PLAY 3 lần (`interstitial_every_n_starts` = 3): lần thứ 3 có interstitial thử của AdMob.
3. Mở ứng dụng lần thứ 3 (tính cả quay lại từ nền), vào màn chơi: banner thử hiện dưới khay khối, không che bàn cờ.
4. Thua một level ở Journey: lớp phủ Game Over có nút WATCH AD TO TRY AGAIN. Xem hết quảng cáo thử: chơi lại cùng level, điểm về 0.
5. Đặt `android_version`/`ios_version` cao hơn bản cài và `android_url`/`ios_url` là link `https` trên Remote Config, mở lại ứng dụng: popup "Update available" hiện, UPDATE mở cửa hàng.
6. Chia sẻ điểm: nội dung có link cửa hàng ở dòng cuối.
7. Bật chế độ máy bay rồi lặp lại bước 2 đến 4: game vẫn chạy, không có quảng cáo.
8. Mở một ứng dụng nghe nhạc (Spotify, YouTube Music) và phát nhạc, rồi vào chơi: nhạc vẫn phát; đặt khối, ăn dòng, thua không có âm và không rung; thắng level có âm qua màn chồng lên nhạc (CR-2, CR-3).
9. Banner ở màn chơi cao 50 dp (CR-1).

## Assumptions & Open Questions

None.
