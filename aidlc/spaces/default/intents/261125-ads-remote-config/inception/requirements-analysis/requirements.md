# Yêu cầu: Quảng cáo và Remote Config

Nguồn đầu vào: `intent-statement.md` (ý định), `scope-document.md` (phạm vi), `business-overview.md`, `architecture.md` và `code-structure.md` (hiện trạng game), `team-practices.md` (thực hành của đội) và `requirements-analysis-questions.md` (các câu trả lời Q1 đến Q15). Các ID `FR` và `NFR` dưới đây là khóa truy vết cố định cho các bước sau.

## Phân tích ý định

Người chơi Android và iOS cần có quảng cáo để game tạo doanh thu, và nhà phát triển cần điều chỉnh quảng cáo qua Firebase mà không phát hành lại. Sáu hạng mục trong phạm vi cộng phần xử lý đồng ý người dùng đều bắt buộc. (`intent-statement.md`, `scope-document.md`)

Hiện trạng: game tên "Block Jewel" chưa có quảng cáo, Remote Config chỉ dùng khóa `level_config`, và khi hết nước đi game ghi nhận thua và hạ tiến trình ngay trước khi lớp phủ Game Over hiện. (`business-overview.md`, `architecture.md`)

## Yêu cầu chức năng

### FR1. Tham số cấu hình trên Remote Config

- **FR1.1**: Ứng dụng đọc các tham số sau từ Remote Config: `banner_start_visit` (mặc định 3), `reward_enabled` (mặc định true), `interstitial_every_n_starts` (mặc định 3), `ads_priority` (mặc định `admob,unity,applovin`), `android_version`, `android_url`, `ios_version`, `ios_url` (mặc định rỗng). Pass khi mỗi tham số đọc được với đúng kiểu và đúng mặc định. (Q2)
- **FR1.2**: Khi không tải được cấu hình, ứng dụng dùng giá trị mặc định của FR1.1 và vẫn chạy bình thường. Pass khi tắt mạng thì ứng dụng khởi động và chơi được. (Q2, Q14)
- **FR1.3**: Giá trị tham số sai kiểu hoặc không hợp lệ (ví dụ số N không phải số nguyên dương) được coi như thiếu và dùng mặc định. Pass bằng kiểm thử với giá trị sai. (Q2)

### FR2. Banner (hạng mục 1)

- **FR2.1**: Ứng dụng đếm số lần mở ứng dụng và lưu bền, giữ khi thoát ứng dụng. Pass khi đóng và mở lại ứng dụng thì bộ đếm tăng đúng một. (Q1, Q8, Q15)
- **FR2.2**: Banner hiện dưới cùng màn chơi, ở mọi màn chơi, từ lần mở ứng dụng thứ N (`banner_start_visit`) trở đi, và không hiện ở các lần mở trước đó. Pass với N bằng 3 thì lần mở 1 và 2 không có banner, lần mở 3 và sau đó có banner. (Q1, Q15, `scope-document.md`)
- **FR2.3**: Banner cũng hiện ở chế độ Endless. (Q6)
- **FR2.4**: Khi banner không tải được, vùng banner ẩn hẳn và không chừa khoảng trống. Pass khi giả lập lỗi tải thì bố cục màn chơi không đổi. (Q6 của rough-mockups, `wireframes.md`)

### FR3. Reward ads để tiếp tục (hạng mục 2)

- **FR3.1**: Lớp phủ Game Over của chế độ Journey có thêm nút xem reward ads khi `reward_enabled` là true và quảng cáo sẵn sàng. Khi một trong hai điều kiện không đúng thì nút ẩn. Pass với ba tổ hợp cờ và trạng thái quảng cáo. (Q5, Q2)
- **FR3.2**: Nút reward ads không có ở chế độ Endless. (Q6)
- **FR3.3**: Mỗi ván thua chỉ cho xem reward ads một lần. Pass khi sau lần xem đầu, nếu thua lại ở cùng ván thì nút không hiện lại. (Q3)
- **FR3.4**: Khi người chơi xem đủ quảng cáo, điểm về 0, các ô trên bàn cờ được xóa sạch, khay khối được thay bằng khay mới, và người chơi chơi tiếp ở chính level đó. Pass khi sau thưởng thì điểm bằng 0, bàn cờ trống, khay có 3 khối và trạng thái là đang chơi. (Q4, Q4 của approval-handoff)
- **FR3.5**: Khi người chơi nhận thưởng, level hiện tại không bị hạ về level đầu của viên đá. Pass khi tiến trình đã lưu sau đó vẫn là level đang chơi. (Q4)
- **FR3.6**: Khi người chơi đóng quảng cáo sớm, không có thưởng và game quay lại lớp phủ Game Over. Pass khi giả lập đóng sớm thì lớp phủ Game Over hiện và không có chuyển đổi trạng thái ván. (Q5)

### FR4. Interstitial (hạng mục 3)

- **FR4.1**: Ứng dụng đếm lần bấm Start, gồm nút PLAY ở Home và nút PLAY AGAIN ở lớp phủ Game Over, và lưu bền. Pass khi tăng bộ đếm đúng một ở mỗi lần bấm và giữ giá trị khi thoát ứng dụng. (Q7, Q8)
- **FR4.2**: Sau mỗi N lần bấm Start (N là `interstitial_every_n_starts`), quảng cáo interstitial hiện ngay sau khi bấm, trước khi vào màn chơi. Pass với N bằng 3 thì lần bấm thứ 3, 6, 9 có interstitial. (Q7, Q5 của approval-handoff)
- **FR4.3**: Không có khoảng cách thời gian tối thiểu giữa hai interstitial. (Q8)
- **FR4.4**: Interstitial áp dụng cả ở chế độ Endless. (Q6)
- **FR4.5**: Khi interstitial không tải được, game bỏ qua và vào màn chơi ngay, không báo lỗi cho người chơi. Pass khi giả lập lỗi tải thì màn chơi vẫn mở. (Q14, `intent-statement.md`)

### FR5. Thứ tự mạng quảng cáo (hạng mục 4)

- **FR5.1**: `ads_priority` là chuỗi tên mạng cách nhau bằng dấu phẩy, và áp dụng cho banner, reward và interstitial. (`scope-document.md`, Q9)
- **FR5.2**: Giá trị thiếu hoặc rỗng thì dùng mặc định `admob,unity,applovin`. Tên mạng không nhận ra thì bị bỏ qua. (Q9)
- **FR5.3**: Ứng dụng thử mạng đứng đầu trước, và nếu không có quảng cáo thì thử lần lượt các mạng còn lại theo thứ tự. Pass khi giả lập mạng đầu thất bại thì mạng kế được thử. (Q9, Q2 của feasibility)

### FR6. Kiểm tra phiên bản và popup cập nhật (hạng mục 5)

- **FR6.1**: Ứng dụng đọc tên phiên bản đang cài (ví dụ 1.0.0, bỏ phần số build) và so với `android_version` hoặc `ios_version` theo nền tảng đang chạy. Chỉ so tên phiên bản dạng số cách nhau bằng dấu chấm. (Q10)
- **FR6.2**: Khi phiên bản cài đặt thấp hơn phiên bản trên cấu hình, popup cập nhật hiện khi vào Home, tối đa một lần cho mỗi lần mở ứng dụng. Pass khi 1.0.0 so với 1.0.1 thì popup hiện một lần và không hiện lại khi quay về Home. (Q10)
- **FR6.3**: Popup có hai nút Update và Later. Update mở đường dẫn cửa hàng của nền tảng (`android_url` hoặc `ios_url`). Later đóng popup. (Q4 của rough-mockups, `wireframes.md`)
- **FR6.4**: Khi đường dẫn rỗng hoặc không hợp lệ, hoặc phiên bản cấu hình rỗng hoặc sai dạng, popup không hiện. Pass bằng kiểm thử với từng giá trị này. (Q11)

### FR7. Link cửa hàng trong nội dung chia sẻ (hạng mục 6)

- **FR7.1**: Nội dung chia sẻ điểm và chiến thắng có thêm link ở cuối, chọn theo hệ điều hành (`android_url` cho Android, `ios_url` cho iOS). Pass khi hai hàm tạo văn bản chia sẻ trả về văn bản có link ở cuối. (Q12, `api-documentation.md`)
- **FR7.2**: Khi đường dẫn rỗng hoặc không hợp lệ, nội dung chia sẻ giữ nguyên như hiện tại, không thêm link. (Q11)

### FR8. Đồng ý của người dùng

- **FR8.1**: Trước khi hiển thị quảng cáo đầu tiên, ứng dụng xử lý sự đồng ý của người dùng theo quy định áp dụng cho khu vực (EU/EEA) và nền tảng (iOS xin phép theo dõi). Pass khi người dùng chưa trả lời thì không có quảng cáo nào hiện. (`scope-document.md`, Q5 của scope-definition, `constraint-register.md`)
- **FR8.2**: Khi người dùng từ chối, quảng cáo vẫn hiện nhưng ở dạng không cá nhân hóa. (Q13)

## Yêu cầu phi chức năng

- **NFR1**: Khởi tạo quảng cáo chạy nền và không chặn màn Splash. Hạn chót khởi động 3,5 giây của `AppBootstrap` vẫn đúng khi khởi tạo quảng cáo chưa xong. Pass khi kiểm thử khởi động giả lập quảng cáo treo mà Splash vẫn chuyển sang Home trong 3,5 giây. (Q14, `architecture.md`)
- **NFR2**: Lỗi từ quảng cáo hoặc cấu hình không làm ứng dụng dừng hay chặn việc chơi. Pass khi mọi lỗi giả lập ở FR2, FR3, FR4, FR5 đều dẫn đến game chạy tiếp. (`intent-statement.md`, Q14)
- **NFR3**: Mã dùng SDK quảng cáo nằm sau interface có bản giả để kiểm thử, theo mẫu `RemoteConfigClient` và `AnalyticsService`. Độ phủ dòng tối thiểu 80% trên toàn codebase, và `test/widget_test.dart` phải pass trước khi đo. (`team-practices.md`, `code-structure.md`)
- **NFR4**: Mọi chuỗi hiển thị trên giao diện mới chỉ dùng tiếng Anh. (`team-practices.md`, `intent-statement.md`)
- **NFR5**: Giao diện giữ hướng dọc trên điện thoại. (`wireframes.md`, Q7 của rough-mockups)
- **NFR6**: Cấu hình mới có hiệu lực trong tối đa khoảng 12 giờ, theo khoảng tải tối thiểu hiện có của Remote Config. Pass khi `minimumFetchInterval` vẫn là 12 giờ, hoặc thay đổi này được bạn xác nhận riêng. (`api-documentation.md`)
- **NFR7**: Các kiểm thử hiện có (gồm `level_game_controller_test.dart` và `progress_repository_test.dart`) vẫn xanh sau thay đổi luồng thua ván. (`code-quality-assessment.md`)

## Ràng buộc

- Một developer, build và upload thủ công lên Google Play Console và App Store Connect, không có CI/CD. (`team-practices.md`)
- Ứng dụng chưa có trên cửa hàng nên link ban đầu là link giả, đổi qua Remote Config sau. (`constraint-register.md`)
- Đối tượng người chơi hướng tới trên 13 tuổi, phát hành toàn cầu gồm EU/EEA. (`feasibility-assessment.md`)
- Kiến trúc feature-first, logic nằm ở controller hoặc service, `provider` cho state. (`team-practices.md`, `architecture.md`)

## Giả định

- Thư viện quảng cáo của mỗi mạng báo cho ứng dụng biết người chơi đã xem đủ quảng cáo reward hay chưa. Giả định này cần kiểm chứng ở bước thiết kế. (FR3.4)
- Cần thêm một thư viện đọc phiên bản đang cài lúc chạy, vì hiện chưa có trong `pubspec.yaml`. (FR6.1, `technology-stack.md`)

## Ngoài phạm vi

- Gói trả tiền để tắt quảng cáo. (`scope-document.md`)
- Quảng cáo native hoặc app open, màn hình báo cáo doanh thu trong ứng dụng, đa ngôn ngữ cho chuỗi giao diện. (`scope-document.md`, `intent-statement.md`)
- Khoảng cách thời gian tối thiểu giữa hai interstitial. (Q8)

## Câu hỏi còn mở

- Thời điểm ghi nhận thua: hiện game lưu tổn thất ngay khi hết nước đi. Reward ads (FR3.5) cần hoãn hoặc hoàn tác bước lưu này, và cách làm sẽ được quyết định ở bước thiết kế. (`architecture.md`)
- Câu chữ cuối cùng của nút reward, popup cập nhật và nội dung chia sẻ. Phần câu chữ trong `wireframes.md` chỉ là minh họa.
- Chi tiết hộp thoại đồng ý theo từng khu vực và nền tảng.
- Các sự kiện phân tích (analytics) cho quảng cáo chưa được yêu cầu.
- Các chỉ số thành công chưa có mức mục tiêu cụ thể. (`intent-statement.md`)
