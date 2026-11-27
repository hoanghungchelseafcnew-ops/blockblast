# Tóm tắt mã: u2-reward-ads

Conductor tự viết mã theo `code-generation-plan.md` đã được bạn duyệt, vì trợ lý developer không có công cụ ghi file trong phiên này. Mã bám theo `functional-spec.md`, `rules.md`, `performance-design.md`, `security-design.md`, `contract-summary.md` (hợp đồng 2 và 4), `unit-of-work.md` và `requirements.md` (FR3, NFR2, NFR4).

## Tệp mới

| Tệp | Nội dung |
|-----|----------|
| `lib/features/ads/services/pending_loss_store.dart` | `PendingLoss` và `PendingLossStore`: dấu lần thua chưa ghi nhận (khóa `pending_loss_level`, giá trị `level:điểm`), lỗi được log và không ném |
| `test/features/ads/pending_loss_store_test.dart` | 7 test: ghi và đọc lại, xóa, giá trị hỏng, lỗi ghi, lỗi mở kho, lỗi xóa |
| `test/features/journey/level_game_reward_test.dart` | 12 test cho luồng thua và reward của `LevelGameController` |

## Tệp sửa

| Tệp | Thay đổi |
|-----|----------|
| `ad_network_adapter.dart` | `RewardShowResult`, `loadRewarded`, `showRewarded` |
| `ad_unit_ids.dart` | `rewardedId` và `rewardedConfigured`; ID reward thử của AdMob cho bản debug |
| `admob_adapter.dart`, `unity_adapter.dart`, `applovin_adapter.dart` | Tải và hiện reward, phân biệt được thưởng và đóng sớm, bắt mọi lỗi SDK |
| `ad_mediator.dart` | `RewardOutcome`, `AdsService.preloadReward()` và `reward()`; ô reward riêng, thử mạng theo `ads_priority`, 5 giây mỗi mạng, chưa sẵn sàng thì trả `noAd` ngay; `NoopAdsService` trả `noAd` |
| `level_game_controller.dart` | Nhận `ads`, `rewardEnabled`, `pendingLoss`; hoãn ghi nhận thua khi nút reward có thể hiện; `canWatchAd`, `watchingAd`, `watchAd()`; PLAY AGAIN, rời màn và `dispose` ghi nhận thua đúng một lần; tải trước reward khi bắt đầu level |
| `app_bootstrap.dart` | `AppServices.pendingLoss`; ghi nhận lần thua còn treo trước khi vào Home, trong tối đa `progressTimeout` |
| `app_composition.dart` | Dựng `PendingLossStore` thật trên SharedPreferences |
| `game_over_overlay.dart` | `onWatchAd`, `watchAdBusy`; dòng "Watch an ad to stay on this level", nút chính WATCH AD TO TRY AGAIN (key `game-over-reward-button`), PLAY AGAIN thành nút phụ; bản Endless không đổi |
| `game_screen.dart` | Nối `onWatchAd` với `controller.watchAd` khi `canWatchAd` |
| `home_screen.dart` | Truyền `ads`, `rewardEnabled`, `pendingLoss` vào `LevelGameController` |
| Test hiện có | `ads_fakes.dart` (reward giả), `ad_mediator_test.dart` (+8), `app_bootstrap_test.dart` (+3), `ui_test_helpers.dart`, `game_screen_test.dart` (+4) |

## Quyết định khi viết mã

- Chỉ hoãn ghi nhận thua khi quảng cáo đang chạy và `reward_enabled` là true. Các trường hợp khác đi đường cũ, nên mọi test cũ của `LevelGameController` vẫn chạy không đổi (NFR7.2).
- `level_fail` vẫn gửi ngay lúc thua, như trước. Nhận thưởng rồi bắt đầu lại thì có thêm `level_start`.
- Quảng cáo hiện mà lỗi được tính là không có quảng cáo, nên người chơi vẫn được thưởng (ADR-007).
- Khi nhận thưởng, điểm của ván vừa thua được lưu làm điểm cao nếu cao hơn (BR6.6).
- Ở bootstrap, nếu hạn chót đã hết thì vẫn dành ít nhất 100 ms để ghi nhận lần thua còn treo, vì đọc kho cục bộ rất nhanh. Quá hạn thì dấu giữ lại cho lần mở sau.

## Khác với kế hoạch

- `dart format lib test` đã chạy trên toàn bộ thư mục, nên một số tệp ngoài kế hoạch chỉ bị đổi khoảng trắng và xuống dòng, không đổi logic. Ví dụ: `ads_config.dart`, `board_engine.dart`, `tray_generator.dart`, `game_snapshot.dart` và một số tệp test. Bạn xem `git diff` trước khi commit.

## Kiểm thử

Lệnh đã duyệt `flutter analyze && flutter test --coverage` đã chạy:
- `flutter analyze`: không có lỗi.
- `flutter test --coverage`: 611 test pass, 1 skip có sẵn từ trước.
- Độ phủ dòng: 89,1% (2946/3306). Sàn là 80%. Mức giảm so với u1 (92,1%) đến từ mã reward trong ba adapter SDK, phần không chạy được trong môi trường test.

## Việc bạn cần làm trước khi phát hành

Điền ID reward thật (`rewardedId`) cho AdMob, Unity và AppLovin trong `ad_unit_ids.dart`, cùng các ID còn thiếu từ u1.
