# CI/CD Pipeline — U1 `u1-journey-skeleton`

## Sources

- [prac] `inception/practices-discovery/team-practices.md`: không dùng git, không CI/CD, build và upload thủ công, người dùng chạy `flutter analyze` và `flutter test` trên máy khác
- [dp] `inception/delivery-planning/bolt-plan.md` B1 (các ca kiểm chứng end-to-end)
- Lệnh kiểm chứng đã duyệt: `flutter analyze && flutter test --coverage`
- [Q1] [Q2] `infrastructure-design-questions.md`

Không có pipeline tự động (practices). "Pipeline" của U1 là chuỗi bước thủ công dưới đây, do người dùng chạy trên máy có Flutter.

## Các bước (theo thứ tự)

1. **Sao lưu**: zip thư mục dự án (X1). Không có git nên đây là cách rollback duy nhất.
2. **Lấy dependency**: `flutter pub get`.
3. **Static check**: `flutter analyze`, không được có lỗi (DoD-5).
4. **Test**: `flutter test --coverage`. Tất cả test phải xanh. Xem `coverage/lcov.info` theo từng file U1 tạo hoặc sửa (≥ 80%).
5. **Build Android**: `flutter build apk --debug` (hoặc `appbundle --release` khi phát hành).
6. **Kiểm chứng end-to-end**: chạy 4 ca của B1 trên thiết bị hoặc emulator.
7. **Báo lại**: dán kết quả bước 3–6 vào chat để checkpoint của U1 được duyệt.
8. (Tùy chọn, nếu có Mac) `flutter build ios`.

## Stage → gate

| Bước | Gate | Nếu lỗi |
|------|------|---------|
| 3 analyze | 0 lỗi | AI sửa code, lặp lại từ bước 3 |
| 4 test + coverage | Xanh, file U1 ≥ 80% | AI bổ sung hoặc sửa test |
| 5 build | Thành công | AI sửa cấu hình Gradle hoặc dependency |
| 6 e2e | 4 ca đạt | AI sửa, người dùng chạy lại |

## Deployment và rollback

- **Deployment**: không phát hành ở U1. U1 chỉ build để kiểm chứng. Phát hành lên store thuộc giai đoạn Operation.
- **Rollback mã nguồn**: giải nén bản zip sao lưu.
- **Rollback cấu hình**: Remote Config có lịch sử phiên bản trên console và rollback được bằng một thao tác.
- **Feature flag**: không có ở U1.

## Secrets trong pipeline

Không có CI nên không có secret store. File cấu hình Firebase chỉ nằm trong thư mục dự án trên máy người dùng (NFR11.2).

## Assumptions & Open Questions

None.
