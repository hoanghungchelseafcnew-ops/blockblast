# Thành phần logic: u4-update-and-share

Nguồn: `components.md`, `security-design.md`, `performance-design.md`, `tech-stack-decisions.md` của unit này, `functional-spec.md` và `logical-components.md` của `u1-ads-core`.

| Thành phần | Thay đổi | Miền lỗi | Cách cô lập |
|-----------|----------|----------|-------------|
| `AppUpdateChecker` (mới) | So phiên bản, kiểm tra đường dẫn, nhớ lần mở đã hiện popup | Dữ liệu cấu hình | Thuần, không ném lỗi |
| `InstalledVersionReader` (mới) | Đọc tên phiên bản đang cài | Nền tảng | Interface, lỗi thành "không rõ phiên bản" |
| `StoreLauncher` (mới) | Mở đường dẫn bằng ứng dụng ngoài | Nền tảng | Interface, lỗi được ghi log |
| `UpdatePopup` (mới) | Hộp thoại LATER và UPDATE | Giao diện | Chỉ vẽ theo thuộc tính |
| `HomeScreen` | Gọi kiểm tra sau khung hình đầu và sau khi đồng ý xong | Giao diện | Không chặn PLAY |
| `ScoreShareService` | Nối link cửa hàng vào cuối nội dung | Dữ liệu cấu hình | Đường dẫn sai thì giữ nguyên nội dung |
| `AdsService` | Thêm `appOpenCount` để đọc | Quảng cáo | `NoopAdsService` trả 0 |

Hạ tầng: thêm khối `<queries>` cho `https` vào `AndroidManifest.xml` để `url_launcher` hoạt động trên Android 11 trở lên.

## Assumptions & Open Questions

None.
