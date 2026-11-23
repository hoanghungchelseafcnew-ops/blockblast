# CI/CD Pipeline: u3-tray-algorithm

Nguồn: nfr-design/logical-components.md, nfr-design/security-design.md, team.md (Deployment, Testing Posture).

U3 là thư viện Dart thuần nằm trong cùng ứng dụng Flutter, build bằng một lần build chung với U1 và U2. Unit này không cần hạ tầng riêng: không máy chủ, không cơ sở dữ liệu, không dịch vụ đám mây, không bí mật. Theo team practices không có CI/CD; mọi bước chạy tay trên máy của developer. Tệp này ghi lại quy trình đó cho U3.

## Quy trình kiểm tra và phát hành

| Bước | Lệnh hoặc việc | Ai chạy | Cổng (gate) |
|---|---|---|---|
| 1. Format | `dart format .` | Người dùng | Không có thay đổi chưa format |
| 2. Phân tích tĩnh | `flutter analyze` | Người dùng, báo kết quả cho AI | Sạch, không cảnh báo mới (NFR5.1) |
| 3. Test | `flutter test --coverage` | Người dùng, báo kết quả cho AI | Mọi test pass, `test/widget_test.dart` pass, coverage dòng toàn codebase từ 80% (NFR3.2) |
| 4. Đo hiệu năng | Test hiệu năng chuẩn bị khay trên bảng đầy 60–90%, chạy trên máy thật tầm trung | Người dùng | Dưới 16 ms trường hợp xấu nhất (NFR1.1); vượt thì giảm `solverNodeBudget` hoặc số ứng viên |
| 5. Build | `flutter build appbundle` (Android) và `flutter build ipa` (iOS) | Người dùng | Build thành công |
| 6. Phát hành | Upload tay lên Google Play Console và App Store Connect | Người dùng | Developer tự quyết định |

AI chỉ sinh code và test; người dùng chạy lệnh rồi báo kết quả.

## Chiến lược triển khai và hoàn tác

- **Triển khai:** một bản build chung cho cả ứng dụng, không canary, blue-green hay rolling riêng cho U3.
- **Hoàn tác:** quay về commit trước bằng git và build lại; hoặc phát hành bản vá. Vì U3 không đổi dữ liệu đã lưu hay Remote Config (NFR7.1), hoàn tác không cần migration và không để lại dữ liệu không tương thích.
- **Cờ tính năng:** không dùng. Hằng số cân bằng nằm trong `DifficultyConstants` và đổi bằng lần build mới.

## Bí mật và môi trường

- Không có bí mật, khóa hay biến môi trường cho U3 (NFR6.1).
- Chỉ có môi trường phát triển cục bộ và môi trường production của cửa hàng ứng dụng; không có staging tự động.

## Ngoài phạm vi

CI/CD tự động, môi trường staging, giám sát và cảnh báo từ xa. Không có yêu cầu nào trong NFR của U3 cần chúng.
