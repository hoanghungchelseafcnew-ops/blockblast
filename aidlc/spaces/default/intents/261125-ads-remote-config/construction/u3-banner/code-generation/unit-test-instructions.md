# Hướng dẫn kiểm thử đơn vị: u3-banner

Chiến lược kiểm thử: Standard. Phương pháp: test-after. Lệnh kiểm tra chung của đợt này đã được duyệt là `flutter analyze && flutter test --coverage` và workflow tự chạy ở điểm kiểm tra.

## Thiết lập

- Khung test: `flutter_test` (đã có). Không thêm thư viện.
- Bản giả: `FakeAdsService` và `FakeAdNetwork` trong `test/features/ads/ads_fakes.dart` (thêm banner giả `FakeLoadedBanner`), `FakeProgressStore` trong `test/fakes/`.

## Lệnh chạy cho riêng unit này

```bash
flutter test test/features/ads/ad_mediator_test.dart test/features/ads/ad_banner_slot_test.dart test/ui/game_screen_test.dart test/ui/endless_game_screen_test.dart
```

## Mục tiêu độ phủ

Độ phủ dòng tối thiểu 80% toàn codebase. Không hạ ngưỡng nào.

## Số lượng test dự kiến

| Thành phần | Số test |
|-----------|---------|
| `AdMediator` banner | 7 |
| `AdBannerSlot` | 7 |
| Màn chơi Journey (bổ sung) | 3 |
| Màn Endless (bổ sung) | 1 |

## Hướng dẫn giả lập

- Banner: `FakeAdsService.bannerEligible` và `bannerResult`; `holdBanner` để giữ lần tải; `notifyBannerChange()` để giả lập lần mở vừa được ghi.
- Mạng: `FakeAdNetwork.bannerHeight` (null nghĩa là không có banner), `hangBanner`, `bannerError`.
- Banner giả `FakeLoadedBanner` đếm số lần `dispose`.

## Dữ liệu kiểm thử

Tạo trong từng test bằng `GameHarness` có sẵn và `useMobileScreen` (360 x 640).
