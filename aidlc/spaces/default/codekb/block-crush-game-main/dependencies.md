# Dependencies

## Bên ngoài (pubspec.yaml)
| Gói | Phiên bản | Dùng cho |
|---|---|---|
| provider | ^6.1.2 | State |
| shared_preferences | ^2.2.3 | Lưu tiến trình |
| share_plus | ^10.1.3 | Chia sẻ ảnh |
| screenshot | ^3.0.0 | Chụp widget |
| path_provider | ^2.1.5 | Thư mục tạm |
| firebase_core / remote_config / analytics | ^3.15.0 / ^5.4.0 / ^11.6.0 | Cấu hình và số liệu |
| audioplayers | ^6.0.0 | Âm thanh |
| flutter_animate, google_fonts, cached_network_image | ^4.5.0, ^6.2.1, ^3.4.1 | UI |
| flutter_launcher_icons (dev) | ^0.13.1 | Icon |

## Nội bộ
- features/* phụ thuộc core/* và shared/*; core không phụ thuộc features.
- `game_screen` → `journey/controllers`, `victory/widgets`, `game/services`.
- `LevelGameController` → `BoardEngine` → `TrayGenerator`, `TurnResolver`, `BoardLogic`.

## Còn thiếu cho intent 261125-ads-remote-config
- Thư viện quảng cáo cho AdMob, Unity và AppLovin (chưa có).
- `AndroidManifest.xml` chưa có `uses-permission` hay meta-data application ID của mạng quảng cáo.
- `Info.plist` chưa có `GADApplicationIdentifier`, `NSUserTrackingUsageDescription` và `SKAdNetworkItems`.
