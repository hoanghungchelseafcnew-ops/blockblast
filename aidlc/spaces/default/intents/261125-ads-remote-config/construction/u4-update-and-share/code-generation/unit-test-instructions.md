# Hướng dẫn kiểm thử đơn vị: u4-update-and-share

Chiến lược kiểm thử: Standard. Phương pháp: test-after. Lệnh kiểm tra chung của đợt này đã được duyệt là `flutter analyze && flutter test --coverage` và workflow tự chạy ở điểm kiểm tra.

## Thiết lập

- Khung test: `flutter_test` (đã có). Thêm `url_launcher` cho mã chạy thật; test không gọi nó.
- Bản giả mới: `FakeInstalledVersionReader` (trả phiên bản đặt sẵn, hoặc ném lỗi) và `FakeStoreLauncher` (ghi lại đường dẫn đã mở, có thể trả thất bại) trong `test/features/update/update_fakes.dart`.
- Bản giả có sẵn: `FakeAdsService` (thêm `appOpenCount`, `startupSettled`).
- Đổi nền tảng bằng `debugDefaultTargetPlatformOverride`, đặt lại trong `tearDown`.

## Lệnh chạy cho riêng unit này

```bash
flutter test test/features/update/ test/features/game/services/score_share_service_test.dart test/features/ads/ad_mediator_test.dart test/features/journey/app_bootstrap_test.dart test/ui/
```

## Mục tiêu độ phủ

Độ phủ dòng tối thiểu 80% toàn codebase. Không hạ ngưỡng nào.

## Số lượng test dự kiến

| Thành phần | Số test |
|-----------|---------|
| Logic so phiên bản và đường dẫn | 8 |
| `AppUpdateChecker` | 8 |
| Link chia sẻ | 3 |
| `UpdatePopup` và Home | 7 |
| `AdMediator` và `AppBootstrap` (bổ sung) | 3 |

## Dữ liệu kiểm thử

Phiên bản và đường dẫn đặt qua `AdsSettings` trong từng test, ví dụ `androidVersion: '1.0.1'`, `androidUrl: 'https://play.google.com/store/apps/details?id=com.h2.game.block_blast'`.
