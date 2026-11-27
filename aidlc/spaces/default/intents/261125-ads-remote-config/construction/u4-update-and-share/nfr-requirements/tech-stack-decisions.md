# Quyết định công nghệ: u4-update-and-share

Nguồn: `technology-stack.md` của codekb, `tech-stack-decisions.md` của `u1-ads-core`, `functional-spec.md` và `nfr-requirements-questions.md`.

| Mục đích | Công nghệ | Lý do |
|----------|-----------|-------|
| Đọc tên phiên bản đang cài | `package_info_plus` ^9.0.1 | Đã thêm ở `u1-ads-core` (ADR-006) |
| Mở trang cửa hàng | `url_launcher` ^6.3.0 (mới), chế độ `externalApplication` | Q1: thư viện chính thức của nhóm Flutter; các gói nền tảng của nó đã có sẵn trong `pubspec.lock` dưới dạng phụ thuộc gián tiếp |
| Nội dung chia sẻ | `share_plus` ^10.1.3 | Đã có |
| Cấu hình | `AdsSettings` từ `u1-ads-core` | Hợp đồng 3 |

Cần khai báo thêm cho `url_launcher`:
- Android 11 trở lên: khối `<queries>` cho intent `VIEW` với scheme `https` trong `AndroidManifest.xml`.
- iOS: không cần khai báo thêm cho `https`.

## Assumptions & Open Questions

None.
