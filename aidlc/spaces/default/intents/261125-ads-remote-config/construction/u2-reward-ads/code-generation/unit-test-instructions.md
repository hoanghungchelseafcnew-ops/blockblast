# Hướng dẫn kiểm thử đơn vị: u2-reward-ads

Chiến lược kiểm thử: Standard. Phương pháp: test-after. Lệnh kiểm tra chung của đợt này đã được duyệt là `flutter analyze && flutter test --coverage` và workflow tự chạy ở điểm kiểm tra.

## Thiết lập

- Khung test: `flutter_test` (đã có). Không thêm thư viện.
- Bản giả: `FakeAdsService` và `FakeAdNetwork` trong `test/features/ads/ads_fakes.dart`, `FakeProgressStore` trong `test/fakes/`.

## Lệnh chạy cho riêng unit này

```bash
flutter test test/features/ads/ad_mediator_test.dart test/features/ads/pending_loss_store_test.dart test/features/journey/level_game_reward_test.dart test/features/journey/level_game_controller_test.dart test/features/journey/app_bootstrap_test.dart test/ui/game_screen_test.dart
```

## Mục tiêu độ phủ

Độ phủ dòng tối thiểu 80% toàn codebase. Không hạ ngưỡng nào.

## Số lượng test dự kiến

| Thành phần | Số test |
|-----------|---------|
| `AdMediator` reward | 6 đến 7 |
| `PendingLossStore` | 5 |
| `LevelGameController` reward | 8 đến 9 |
| `AppBootstrap` (bổ sung) | 3 |
| Màn chơi (bổ sung) | 3 |

## Hướng dẫn giả lập

- Reward: `FakeAdsService.rewardOutcome` đặt `earned`, `closedEarly` hoặc `noAd`; `holdReward` để giữ quảng cáo đang hiện.
- Mạng: `FakeAdNetwork` có kết quả tải và hiện reward riêng.
- Dấu lần thua: `FakeProgressStore` với `failingKeys` để giả lập lỗi ghi.

## Dữ liệu kiểm thử

Tạo trong từng test bằng `GameHarness` có sẵn và `fillBoardLeavingIsolatedGaps()` để gây thua.
