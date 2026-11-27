# User Stories: Quảng cáo và Remote Config

Nguồn: `requirements.md`, `personas.md`, `intent-backlog.md` và `user-stories-questions.md`. Tất cả stories là Must Have (Q1, Q2 của scope-definition). Cách chia theo tính năng, mỗi tính năng một story (Q2, Q3). Mọi chuỗi giao diện chỉ dùng tiếng Anh.

## Nhóm 1: Nền tảng

### US1.1: Cấu hình quảng cáo từ Firebase

As Mai, I want the game to keep working with sensible defaults when the ad settings are missing or wrong, so that a bad setting or a lost connection never stops me from playing.

Ưu tiên: Must Have. Yêu cầu: FR1, NFR1.

- **AC1.1.1**: Given Firebase có đủ các tham số hợp lệ, When ứng dụng khởi động, Then ứng dụng dùng các giá trị đó (`banner_start_visit`, `reward_enabled`, `interstitial_every_n_starts`, `ads_priority`, `android_version`, `android_url`, `ios_version`, `ios_url`).
- **AC1.1.2**: Given không tải được cấu hình, When ứng dụng khởi động, Then ứng dụng dùng mặc định (3, true, 3, `admob,unity,applovin`, rỗng) và người chơi chơi được bình thường.
- **AC1.1.3**: Given một tham số số có giá trị không phải số nguyên dương, When ứng dụng đọc cấu hình, Then tham số đó dùng giá trị mặc định.
- **AC1.1.4**: Given quá trình khởi tạo quảng cáo bị treo, When ứng dụng khởi động, Then màn Splash vẫn chuyển sang Home trong hạn chót 3,5 giây.

INVEST: độc lập, có giá trị với người chơi (không bị chặn bởi lỗi cấu hình), kiểm thử được bằng giả lập cấu hình.

### US1.2: Thứ tự mạng quảng cáo

As Mai, I want ads to come from whichever network has one ready, so that I see an ad only when one is actually available.

Ưu tiên: Must Have. Yêu cầu: FR5.

- **AC1.2.1**: Given `ads_priority` là `unity,admob`, When ứng dụng cần một quảng cáo, Then mạng `unity` được thử trước, rồi `admob` nếu `unity` không có quảng cáo.
- **AC1.2.2**: Given `ads_priority` thiếu hoặc rỗng, When ứng dụng cần quảng cáo, Then thứ tự mặc định `admob,unity,applovin` được dùng.
- **AC1.2.3**: Given `ads_priority` có một tên mạng không nhận ra, When ứng dụng đọc cấu hình, Then tên đó bị bỏ qua và các mạng còn lại vẫn được thử theo thứ tự.
- **AC1.2.4**: Given mọi mạng đều không có quảng cáo, When ứng dụng cần quảng cáo, Then không có quảng cáo nào hiện và game chạy tiếp.

INVEST: độc lập với từng loại quảng cáo, kiểm thử bằng mạng giả.

### US1.3: Đồng ý của người dùng

As Mai, I want to choose whether ads may personalize to me, so that my privacy choices are respected.

Ưu tiên: Must Have. Yêu cầu: FR8.

- **AC1.3.1**: Given tôi ở khu vực cần sự đồng ý (EU/EEA) hoặc dùng iOS cần xin phép theo dõi, When quảng cáo đầu tiên sắp hiện, Then hộp thoại đồng ý hiện trước và chưa có quảng cáo nào hiện.
- **AC1.3.2**: Given tôi từ chối, When quảng cáo hiện, Then đó là quảng cáo không cá nhân hóa.
- **AC1.3.3**: Given tôi đồng ý, When quảng cáo hiện, Then quảng cáo có thể được cá nhân hóa.

INVEST: độc lập, kiểm thử qua giả lập trạng thái đồng ý. Chi tiết hộp thoại theo khu vực là câu hỏi mở. (`requirements.md`)

## Nhóm 2: Interstitial

### US2.1: Quảng cáo xen kẽ trước khi vào màn chơi

As Mai, I want the game to show an ad only now and then before a level, so that the ads are not constant.

Ưu tiên: Must Have. Yêu cầu: FR4, NFR2.

- **AC2.1.1**: Given `interstitial_every_n_starts` là 3, When tôi bấm PLAY ở Home hoặc PLAY AGAIN ở Game Over lần thứ 3, 6, 9, Then quảng cáo interstitial hiện ngay sau khi bấm và trước khi màn chơi mở.
- **AC2.1.2**: Given tôi đã bấm Start 2 lần, When tôi thoát ứng dụng và mở lại rồi bấm Start, Then lần bấm này được tính là lần thứ 3.
- **AC2.1.3**: Given tôi đang chơi chế độ Endless, When tôi bấm PLAY đến lần thứ N, Then interstitial cũng hiện.
- **AC2.1.4**: Given interstitial không tải được, When đến lần hiện, Then màn chơi mở ngay và tôi không thấy lỗi.
- **AC2.1.5**: Given hai interstitial liên tiếp, When đủ N lần bấm, Then không có khoảng chờ tối thiểu giữa chúng.

INVEST: độc lập khi đã có US1.1 và US1.2.

## Nhóm 3: Reward ads

### US3.1: Xem quảng cáo để chơi lại level sau khi thua

As Mai, I want to watch an ad to try the same level again after I lose, so that I do not get sent back to the first stone of the gem.

Ưu tiên: Must Have. Yêu cầu: FR3, NFR2, NFR4.

- **AC3.1.1**: Given tôi thua ở chế độ Journey, `reward_enabled` là true và có quảng cáo sẵn sàng, When lớp phủ Game Over hiện, Then có nút xem quảng cáo cạnh các nút hiện có.
- **AC3.1.2**: Given `reward_enabled` là false hoặc chưa có quảng cáo sẵn sàng, When lớp phủ Game Over hiện, Then nút xem quảng cáo không hiện.
- **AC3.1.3**: Given tôi xem hết quảng cáo, When quảng cáo kết thúc, Then điểm về 0, bàn cờ được xóa sạch, khay khối là khay mới, và tôi chơi tiếp ở chính level đó.
- **AC3.1.4**: Given tôi đã nhận thưởng, When tôi thoát và mở lại, Then tiến trình vẫn ở level đang chơi và không bị hạ về level đầu của viên đá.
- **AC3.1.5**: Given tôi đóng quảng cáo sớm, When quảng cáo đóng, Then tôi không nhận thưởng và quay lại lớp phủ Game Over.
- **AC3.1.6**: Given tôi đã dùng reward ads ở một ván thua, When tôi thua lại ở cùng ván, Then nút xem quảng cáo không hiện nữa.
- **AC3.1.7**: Given tôi chơi chế độ Endless, When lớp phủ Game Over hiện, Then không có nút xem quảng cáo.

INVEST: phụ thuộc US1.1 và US1.2, kiểm thử bằng quảng cáo giả. Cách game hoãn ghi nhận thua là câu hỏi thiết kế. (`requirements.md`)

## Nhóm 4: Banner

### US4.1: Banner dưới màn chơi từ lần mở thứ N

As Mai, I want a banner to appear only after I have opened the game a few times, so that new players get a clean start.

Ưu tiên: Must Have. Yêu cầu: FR2, NFR2.

- **AC4.1.1**: Given `banner_start_visit` là 3, When tôi mở ứng dụng lần thứ 1 hoặc 2 và vào màn chơi, Then không có banner.
- **AC4.1.2**: Given `banner_start_visit` là 3, When tôi mở ứng dụng lần thứ 3 và mọi lần sau rồi vào màn chơi, Then banner hiện dưới cùng màn chơi ở mọi level.
- **AC4.1.3**: Given tôi đóng và mở lại ứng dụng, When đếm số lần mở, Then bộ đếm tăng đúng một và giữ giá trị khi thoát ứng dụng.
- **AC4.1.4**: Given tôi chơi chế độ Endless từ lần mở thứ N, When màn chơi hiện, Then banner cũng hiện.
- **AC4.1.5**: Given banner không tải được, When màn chơi hiện, Then vùng banner ẩn hẳn và bố cục màn chơi không đổi.
- **AC4.1.6**: Given banner đang hiện, When tôi chơi trên điện thoại có màn hình ngắn, Then banner không che bàn cờ hay khay khối.

INVEST: độc lập khi đã có US1.1 và US1.2.

## Nhóm 5: Popup cập nhật

### US5.1: Báo có bản mới

As Mai, I want a short notice when a newer version is out, so that I can update when I choose to.

Ưu tiên: Must Have. Yêu cầu: FR6, NFR4.

- **AC5.1.1**: Given bản cài đặt là 1.0.0 và phiên bản trên cấu hình của nền tảng tôi dùng là 1.0.1, When tôi vào màn Home, Then popup hiện với hai nút Update và Later.
- **AC5.1.2**: Given popup đã hiện trong lần mở ứng dụng này, When tôi quay lại Home, Then popup không hiện lại cho đến lần mở ứng dụng sau.
- **AC5.1.3**: Given popup hiện, When tôi bấm Update, Then trang cửa hàng theo đường dẫn của nền tảng tôi dùng được mở.
- **AC5.1.4**: Given popup hiện, When tôi bấm Later, Then popup đóng.
- **AC5.1.5**: Given bản cài đặt bằng hoặc cao hơn phiên bản trên cấu hình, hoặc phiên bản hoặc đường dẫn trên cấu hình rỗng hoặc không hợp lệ, When tôi vào Home, Then popup không hiện.

INVEST: độc lập với quảng cáo, chỉ cần US1.1.

## Nhóm 6: Link chia sẻ

### US6.1: Link cửa hàng trong nội dung chia sẻ

As Mai, I want my shared score to include a store link, so that my friends can find the game.

Ưu tiên: Must Have. Yêu cầu: FR7.

- **AC6.1.1**: Given tôi dùng Android và `android_url` hợp lệ, When tôi chia sẻ điểm hoặc chiến thắng, Then nội dung chia sẻ có link `android_url` ở cuối văn bản hiện có.
- **AC6.1.2**: Given tôi dùng iOS và `ios_url` hợp lệ, When tôi chia sẻ, Then nội dung có link `ios_url` ở cuối.
- **AC6.1.3**: Given đường dẫn của nền tảng tôi dùng rỗng hoặc không hợp lệ, When tôi chia sẻ, Then nội dung chia sẻ giữ nguyên như hiện tại, không có link.

INVEST: độc lập, chỉ cần US1.1.

## Phụ thuộc

US1.1 là nền cho mọi story khác. US2.1, US3.1, US4.1 phụ thuộc thêm US1.2 và US1.3. US5.1 và US6.1 chỉ cần US1.1. (`intent-backlog.md`, Q4 của requirements-analysis)

## Assumptions & Open Questions

None.
