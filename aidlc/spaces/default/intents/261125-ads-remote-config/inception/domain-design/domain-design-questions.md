# Câu hỏi thiết kế thành phần: Quảng cáo và Remote Config

Trong bước này mình xác định các khối xây dựng (thành phần) cần viết mã, chưa chọn công nghệ hay thư viện cụ thể. Đầu vào là `requirements.md`, `stories.md`, `architecture.md` và `component-inventory.md`. Các thành phần hiện có (`HomeScreen`, `GameScreen`, `GameOverOverlay`, `LevelGameController`, `JourneyController`, `ProgressRepository`, `ScoreShareService`, `AppBootstrap`, `FirebaseRemoteConfigClient`) được dùng lại.

## Q1. Cách chia phần quảng cáo thành các khối

Quảng cáo cần ba việc khác nhau: đọc cấu hình, chọn mạng theo thứ tự `ads_priority` và thử lần lượt, và nói chuyện với SDK của từng mạng.

- A. Tách thành ba khối: `AdsConfig` (đọc cấu hình và mặc định), `AdMediator` (thứ tự mạng và thử lần lượt), và một adapter cho mỗi mạng sau cùng một interface.
  - Ưu: mỗi khối kiểm thử riêng được, thêm mạng mới chỉ thêm adapter. Nhược: nhiều tệp hơn.
  - Khả năng đảo ngược: dễ, có thể gộp lại sau.
- B. Một khối `AdService` gộp cả ba việc.
  - Ưu: ít tệp, đơn giản lúc đầu. Nhược: khó kiểm thử từng phần và khó thêm mạng.
  - Khả năng đảo ngược: trung bình.
- C. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:A

## Q2. Nơi lưu các bộ đếm (số lần mở ứng dụng, số lần bấm Start)

Cả hai bộ đếm cần lưu bền khi thoát ứng dụng. Game hiện lưu tiến trình bằng `ProgressRepository` qua `SharedPreferences`.

- A. Một khối riêng `AdCounters`, lưu qua một interface kho lưu như `ProgressStore`.
  - Ưu: không đụng vào dữ liệu tiến trình đang có và kiểm thử riêng được. Nhược: thêm một khối.
  - Khả năng đảo ngược: dễ.
- B. Thêm các bộ đếm vào `ProgressRepository` hiện có.
  - Ưu: một nơi lưu duy nhất. Nhược: làm lớn thêm một lớp đã có hơn 400 dòng và nhiều kiểm thử, rủi ro hồi quy cao hơn.
  - Khả năng đảo ngược: khó hơn.
- C. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:A

## Q3. Khi nào game ghi nhận một ván thua (quyết định quan trọng nhất)

Hiện game lưu tổn thất (hạ tiến trình, xóa phiên chơi) ngay khi hết nước đi, trước khi lớp phủ Game Over hiện. Reward ads cần giữ level không bị hạ, nên cần đổi thời điểm hoặc hoàn tác.

- A. Hoãn ghi nhận thua đến khi người chơi rời lớp phủ Game Over bằng PLAY AGAIN hoặc BACK TO MENU. Nếu nhận thưởng thì không ghi nhận thua.
  - Ưu: không cần hoàn tác, luồng đơn giản. Nhược: nếu ứng dụng bị đóng đột ngột khi đang ở lớp phủ Game Over thì thua chưa được ghi nhận, người chơi giữ nguyên tiến trình có lợi cho họ.
  - Khả năng đảo ngược: trung bình, đổi hành vi hiện có của `LevelGameController`.
- B. Giữ ghi nhận thua ngay như hiện tại, và hoàn tác (khôi phục tiến trình trước khi thua) khi người chơi nhận thưởng.
  - Ưu: an toàn khi ứng dụng bị đóng đột ngột. Nhược: cần lưu lại tiến trình cũ để hoàn tác, thêm một đường lưu và dễ lỗi nếu hoàn tác thất bại giữa chừng.
  - Khả năng đảo ngược: trung bình.
- C. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:A

## Q4. Mở rộng cổng Remote Config

`RemoteConfigClient` hiện chỉ có `readLevelConfig()` đọc khóa `level_config`. Các tham số mới có kiểu khác nhau: số nguyên, bật/tắt và chuỗi.

- A. Mở rộng `RemoteConfigClient` hiện có với các hàm đọc chung theo kiểu (chuỗi, số nguyên, bật/tắt), và cập nhật bản giả `FakeRemoteConfigClient`.
  - Ưu: một cổng duy nhất, một cấu hình `minimumFetchInterval` chung. Nhược: đổi một interface đã có kiểm thử.
  - Khả năng đảo ngược: dễ.
- B. Tạo một interface riêng cho tham số quảng cáo, dùng cùng `FirebaseRemoteConfig`.
  - Ưu: không đụng interface hiện có. Nhược: hai nơi cùng cấu hình `FirebaseRemoteConfig`, dễ lệch cài đặt.
  - Khả năng đảo ngược: dễ.
- C. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:A

## Q5. Nơi đặt việc xử lý đồng ý của người dùng

- A. Một khối `ConsentService` riêng, và `AdMediator` chỉ yêu cầu quảng cáo sau khi đồng ý đã được xử lý.
  - Ưu: một chỗ duy nhất quyết định có hiện quảng cáo hay không. Nhược: thêm một khối.
  - Khả năng đảo ngược: dễ.
- B. Mỗi adapter mạng tự xử lý đồng ý riêng.
  - Ưu: gần SDK. Nhược: lặp lại ba lần và dễ không nhất quán.
  - Khả năng đảo ngược: khó hơn.
- C. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:A

## Q6. Nơi đặt việc kiểm tra phiên bản

- A. Một khối riêng `AppUpdateChecker`, cùng một interface để đọc phiên bản đang cài (có bản giả để test).
  - Ưu: không phụ thuộc quảng cáo, kiểm thử riêng được. Nhược: thêm một khối.
  - Khả năng đảo ngược: dễ.
- B. Gộp vào `AdsConfig`.
  - Ưu: ít khối hơn. Nhược: trộn hai mối quan tâm khác nhau (quảng cáo và cập nhật).
  - Khả năng đảo ngược: dễ.
- C. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:A

## Consolidated Summary Confirmation

- Khối quảng cáo: tách `AdsConfig`, `AdMediator` và một adapter cho mỗi mạng sau cùng một interface (Q1)
- Bộ đếm: khối riêng `AdCounters`, lưu qua interface kho lưu, không đụng `ProgressRepository` (Q2)
- Ghi nhận thua: hoãn đến khi người chơi rời lớp phủ Game Over bằng PLAY AGAIN hoặc BACK TO MENU, và nếu nhận thưởng thì không ghi nhận thua (Q3)
- Remote Config: mở rộng `RemoteConfigClient` hiện có với các hàm đọc chung theo kiểu, cập nhật bản giả (Q4)
- Đồng ý người dùng: khối riêng `ConsentService`, `AdMediator` chỉ yêu cầu quảng cáo sau khi đồng ý đã xử lý (Q5)
- Kiểm tra phiên bản: khối riêng `AppUpdateChecker` với interface đọc phiên bản đang cài (Q6)

Does this all look correct before I generate the artifact?

- Looks correct
- Request changes

[Answer]: Looks correct
