# Requirements: Block Jewel Update

Nguồn: mô tả gốc của người dùng, 10 câu trả lời trong `requirements-analysis-questions.md` (tất cả chọn A), và các tài liệu nền: business-overview, architecture, code-structure (code KB), team-practices.

## Intent analysis

Người dùng muốn bản phát hành tiếp theo của game có tên **Block Jewel**, trông gọn hơn khi mở app (một màn splash thay vì hai), dễ lan truyền hơn (chia sẻ ảnh chụp khi thắng) và chơi công bằng hơn (không bị thua vì ba khối đều không đặt vừa, độ khó tăng dần theo level). Loại thay đổi: enhancement nhiều thành phần trên codebase hiện có (brownfield, Flutter, kiến trúc feature-first như trong architecture và code-structure). Độ phức tạp: chuẩn.

## Functional requirements

### FR1. Splash
- **FR1.1** Ứng dụng chỉ hiển thị một màn splash có thể nhìn thấy: `SplashScreen` trong code. Màn splash native không còn logo riêng.
- **FR1.2** Android: nền cửa sổ khởi động và nền splash hệ thống (Android 12+) là `#0F0C29`, trùng nền `SplashScreen`; không còn ảnh splash native tùy chỉnh (`splash.png`, `android12splash.png`, `launch_background` bitmap). Trên Android 12+ hệ điều hành vẫn hiện splash hệ thống nền `#0F0C29`; đây là giới hạn của nền tảng.
- **FR1.3** iOS: `LaunchScreen` chỉ có nền `#0F0C29`, không có ảnh `LaunchImage`.
- **FR1.4** Không còn khối cấu hình `flutter_native_splash` và dev-dependency `flutter_native_splash` trong `pubspec.yaml`, để lần chạy generator sau không sinh lại splash cũ.

### FR2. Đổi tên thành Block Jewel
- **FR2.1** Tên hiển thị là "Block Jewel": nhãn Android (`android:label`), `CFBundleDisplayName` và `CFBundleName` iOS, `title` của `MaterialApp`, chữ trên splash ("BLOCK JEWEL"), README.
- **FR2.2** `applicationId`/`namespace` Android `com.h2.game.block_blast`, bundle id iOS và tên package Dart `block_blast` giữ nguyên.
- **FR2.3** Dòng phụ "◆ Gemstone Journey ◆" trên splash và HomeScreen giữ nguyên.
- **FR2.4** Mọi chuỗi chia sẻ dùng "Block Jewel" thay cho "Block Crush".

### FR3. Chia sẻ khi thắng
- **FR3.1** Màn Victory có nút SHARE ở cả ba biến thể: level con (1–5 trong mỗi gem), mở khóa gem (level lớn) và hoàn thành hành trình (level 36).
- **FR3.2** Bấm SHARE chụp toàn bộ màn hình hiện tại (gồm nền level, bảng và overlay Victory) và mở khung chia sẻ của hệ điều hành kèm ảnh.
- **FR3.3** Văn bản kèm theo (tiếng Anh): "I cleared <tên level> with <điểm> points in Block Jewel!", trong đó `<tên level>` là `Level.displayName`.
- **FR3.4** Lỗi chụp hoặc chia sẻ được ghi log (`GjLog`) và không làm hỏng màn Victory; nút CONTINUE và BACK TO MENU vẫn dùng được trong và sau khi chia sẻ.
- **FR3.5** Nút SHARE ở Game Over hiện có tiếp tục hoạt động, dùng chuỗi mới theo FR2.4.

### FR4. Thuật toán sinh khối
Áp dụng cho Journey và Endless (Endless dùng một mức độ khó cố định, xem Assumptions).
- **FR4.1** Sau khi khay được sinh hoặc làm mới, nếu không khối nào trong khay đặt vừa lên bảng hiện tại, thay đúng một khối trong khay (chọn ngẫu nhiên trong khay) bằng một khối ngẫu nhiên chọn từ các khối đặt vừa được; hình nhỏ nhất là 1×1.
- **FR4.2** Chỉ khi cả khối 1×1 cũng không đặt vừa (bảng đầy) mới xét thua. Việc kiểm tra FR4.1 diễn ra trước khi xét thua.
- **FR4.3** Khối "cứu": khi sinh mỗi khối của khay, với xác suất `rescueRate` chọn một khối làm xóa ít nhất một dòng hoặc cột nếu có khối như vậy trong tập hình; nếu không có thì sinh khối theo luật thường.
- **FR4.4** `rescueRate` cơ bản là 30% ở level 1 và giảm tuyến tính đến 10% ở level 36 (Journey).
- **FR4.5** Khi bảng đã lấp trên 60% số ô (hơn 38 trong 64 ô), tăng tỉ lệ chọn hình nhỏ và giảm tỉ lệ hình lớn tương ứng so với mức của level hiện tại.
- **FR4.6** Tỉ lệ hình lớn tăng dần theo level (level 1 thấp nhất, level 36 cao nhất).
- **FR4.7** Các hằng số tỉ lệ (rescue, ngưỡng 60%, tỉ lệ nhỏ/vừa/lớn theo level) nằm ở một nơi trong code và có thể chỉnh mà không sửa logic.
- **FR4.8** Giữ nguyên tỉ lệ khối đặc biệt hiện có (băng 5%, bom 5%) và bảng màu khối.
- **FR4.9** Logic sinh khối nhận bảng hiện tại, level (hoặc mức độ khó) và nguồn ngẫu nhiên có thể tiêm vào, để test được theo seed. `BoardEngine` không tự biết mốc điểm.

## Non-functional requirements

- **NFR1 Hiệu năng.** Chọn khối cho một khay (kể cả duyệt tìm khối đặt vừa và khối "cứu") hoàn thành dưới 16 ms trên máy tầm trung, vì chạy trên luồng UI (bảng 8×8 duyệt toàn bộ vị trí cho tối đa khoảng 30 hình).
- **NFR2 Tính đúng đắn.** Ở mọi trạng thái bảng chưa đầy hoàn toàn, khay sinh ra có ít nhất một khối đặt vừa (kiểm bằng test thuộc tính trên nhiều seed).
- **NFR3 Khả năng kiểm thử.** Mã mới theo team practices: logic nằm ngoài screen, có unit test cho logic sinh khối và độ khó, widget test cho nút SHARE, và `ScoreShareService` được fake trong test; coverage dòng tối thiểu 80% toàn codebase, `test/widget_test.dart` pass.
- **NFR4 Ngôn ngữ UI.** Mọi chuỗi hiển thị bằng tiếng Anh.
- **NFR5 Chất lượng mã.** `flutter analyze` sạch, `dart format`, theo `flutter_lints`.
- **NFR6 Quyền riêng tư.** Ảnh chụp chỉ lưu trong thư mục tạm của app và chỉ được gửi qua khung chia sẻ của hệ điều hành khi người chơi bấm SHARE.
- **NFR7 Tương thích.** Không đổi dữ liệu tiến trình đã lưu và cấu hình Remote Config.

## Constraints

- Flutter/Dart hiện có; đã có `share_plus`, `screenshot`, `path_provider`, không cần thêm gói để chia sẻ.
- Kiến trúc feature-first, `provider`; Firebase và SharedPreferences nằm sau service.
- Một developer, build và phát hành thủ công; AI chỉ sinh code và test, người dùng chạy `flutter analyze` và `flutter test --coverage` rồi báo kết quả; việc gỡ splash native có thể cần chạy lệnh trên máy của người dùng.
- Có git; quy ước nhánh theo mặc định org.

## Assumptions

- Endless dùng mức độ khó cố định tương đương level giữa hành trình (level 18), vì Endless không có level. Lý do: chưa có yêu cầu riêng.
- "Level lớn" là biến thể `gemUnlock` (hoàn thành level con 6 của gem 1–5) và "level con" là biến thể `sub`, theo `VictoryVariant`.
- Công thức giảm `rescueRate` tuyến tính 30%→10% là giá trị khởi điểm, chốt chi tiết ở thiết kế.
- Giá trị tỉ lệ khối nhỏ khi bảng đầy trên 60% (ví dụ 60%) là khởi điểm, chốt ở thiết kế.
- Gỡ ảnh splash native được thực hiện bằng cách sửa tay các file Android/iOS và gỡ `flutter_native_splash`, vì chạy lại generator sẽ sinh lại ảnh.

## Out of scope

- Đổi `applicationId`, bundle id, tên package Dart.
- Thay icon app, đổi nội dung Remote Config, đổi mốc điểm level.
- Chia sẻ video hoặc chia sẻ từ màn Home.
- Hỗ trợ đa ngôn ngữ.
- Thiết lập CI/CD.

## Open questions

- Giá trị chính xác của đường cong tỉ lệ hình lớn/nhỏ theo level và ngưỡng 60% (chốt ở Functional Design).
- Có cần hiển thị chỉ báo cho người chơi khi một khối được thay (hiện tại không).
