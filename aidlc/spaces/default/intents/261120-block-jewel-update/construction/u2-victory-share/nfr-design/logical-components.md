# Logical Components: u2-victory-share

Nguồn: components.md, functional-spec.md.

| Thành phần | Vai trò | Miền lỗi |
|---|---|---|
| VictoryOverlay | Nút SHARE, trạng thái `_sharing` | UI; lỗi service không tới đây |
| GameScreen | Nối `ScreenshotController` và tên level | UI |
| PlatformScoreShareService | Chụp, ghi file tạm, mở khung chia sẻ | I/O nền tảng; lỗi được nuốt và ghi log |

Ảnh hưởng khi lỗi: chỉ mất thao tác chia sẻ; tiến trình và Victory không bị ảnh hưởng.
