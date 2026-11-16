**Collaborator:** aidlc-devsecops-agent

> Conductor viết thay, đóng vai devsecops agent (agent con không có công cụ file; người dùng đã đồng ý). Chỉ dựa trên bản nháp của lead và codekb, không xem đóng góp của agent khác.

## Contribution

- **Lint/format:** `flutter_lints ^5.0.0` dùng rule mặc định. Không có SAST, DAST, secret scanning hay dependency scanning, và không có CI để chạy chúng.
- **Secrets:** sắp thêm `google-services.json` và `GoogleService-Info.plist`. Đây là cấu hình client của Firebase, không phải secret thật, nhưng thường không nên commit công khai. Bảo mật thật nằm ở Firebase Security Rules (Storage chỉ cho đọc) và App Check.
- **Supply chain:** dependency dùng ràng buộc `^`, có `pubspec.lock`. Nên commit `pubspec.lock` vì đây là app. Khi thêm Firebase nên dùng phiên bản cụ thể.
- **Quyền riêng tư:** Analytics thu thập dữ liệu người chơi. Cần khai báo Data safety (Play) và Privacy label (App Store) theo C-R3.
- **Tối thiểu khả thi cho một developer:**
  - Chạy `flutter analyze` trước khi phát hành.
  - Nếu sau này có CI: `dart pub outdated` hoặc Dependabot.
  - Storage rules chỉ cho đọc công khai các ảnh nền.

## Positions

- AGREE: không cần SAST/DAST nặng cho game client offline-first một developer.
- OBJECT: Firebase Storage không được để rule ghi công khai. Cần ghi thành ràng buộc cứng nếu người dùng đồng ý.
