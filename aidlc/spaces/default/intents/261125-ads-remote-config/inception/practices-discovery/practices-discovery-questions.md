# Câu hỏi thực hành của đội: Quảng cáo và Remote Config

Các câu hỏi dưới đây lấy nội dung đã chốt trong `team.md` làm mặc định. Bằng chứng từ mã nguồn và các nhận xét nằm ở `evidence.md` và thư mục `contributions/`.

## Q1. Cách làm việc và quản lý phiên bản

Hiện đội ghi nhận: một developer duy nhất, dùng git để giữ lịch sử, nhánh và merge theo mặc định của tổ chức (nhánh ngắn hạn, gộp vào `main`), AI sinh code và bạn tự commit. Kho git hiện có nhánh `main` và 4 commit.

Cách làm này còn đúng cho đợt quảng cáo này không?

- A. Đúng, giữ nguyên
- B. Cần đổi (nêu rõ ở Other)
- X. Other (please specify)

[Answer]:A

## Q2. Làm một bản mỏng chạy xuyên suốt trước

Nội dung hiện tại trong `team.md` mô tả bản mỏng của đợt trước (đổi tên game, bỏ splash native, đổi thuật toán khối, chia sẻ khi thắng). Nội dung đó không còn áp dụng cho đợt này.

Bạn có muốn làm một bản mỏng chạy xuyên suốt trước không? Bản mỏng chạy xuyên suốt (walking skeleton) là một phiên bản tối thiểu chạy hết đường đi, làm trước để chứng minh các phần nối được với nhau, trước khi làm các tính năng thật.

- A. Có, bản mỏng gồm đọc cấu hình từ Firebase cộng một loại quảng cáo chạy xuyên suốt (interstitial sau lần bấm Start)
- B. Có, nhưng bản mỏng khác (nêu rõ ở Other)
- C. Không, làm trực tiếp theo thứ tự trong backlog
- X. Other (please specify)

[Answer]:A

## Q3. Cách kiểm thử

Hiện đội ghi nhận: viết kiểm thử sau khi code từng lớp, độ phủ dòng tối thiểu 80% toàn codebase, ưu tiên unit test cho logic thuần, controller và service, widget test cho màn mới, `test/widget_test.dart` phải pass trước khi đo độ phủ, bạn chạy `flutter analyze` và `flutter test --coverage` rồi báo kết quả, AI chỉ sinh code và test.

Cách này còn đúng cho đợt này không? Mã dùng SDK quảng cáo sẽ nằm sau interface có bản giả để test, như cách `RemoteConfigClient` đang làm.

- A. Đúng, giữ nguyên
- B. Cần đổi (nêu rõ ở Other)
- X. Other (please specify)

[Answer]:A

## Q4. Triển khai

Hiện đội ghi nhận: build tay (`flutter build appbundle` và `flutter build ipa`), upload tay lên Google Play Console và App Store Connect, không có CI/CD hay staging tự động, bạn tự quyết định phát hành production.

Cách này còn đúng không?

- A. Đúng, giữ nguyên
- B. Cần đổi (nêu rõ ở Other)
- X. Other (please specify)

[Answer]:A

## Q5. Phong cách code

Hiện đội ghi nhận: `flutter_lints` và `dart format`, đặt tên theo chuẩn Dart, kiến trúc feature-first, code mới tách logic và state sang controller hoặc service (ChangeNotifier qua `provider`), screen chỉ render, Firebase và SharedPreferences nằm sau service hoặc repository, chuỗi hiển thị trên UI chỉ dùng tiếng Anh.

Cách này còn đúng không?

- A. Đúng, giữ nguyên
- B. Cần đổi (nêu rõ ở Other)
- X. Other (please specify)

[Answer]:A

## Q6. Quy tắc cứng mới cho khóa bí mật của mạng quảng cáo

Chuyên gia bảo mật nhận xét rằng Remote Config trả giá trị cho mọi ứng dụng cài đặt, nên khóa bí mật (nếu có) của mạng quảng cáo không nên nằm trong Remote Config hoặc mã nguồn. ID ứng dụng và ad unit ID thì công khai nên không bị ảnh hưởng.

Bạn có muốn thêm quy tắc cứng "luôn giữ khóa bí mật của mạng quảng cáo ngoài mã nguồn và Remote Config" không?

- A. Có, thêm quy tắc này
- B. Không thêm quy tắc mới
- X. Other (please specify)

[Answer]:X - Mạng quảng cáo k có khóa bí mật nên không cần lưu khóa bị mật

## Consolidated Summary Confirmation

Does this all look correct before I generate the artifact?

- Looks correct
- Request changes

[Answer]: Looks correct
