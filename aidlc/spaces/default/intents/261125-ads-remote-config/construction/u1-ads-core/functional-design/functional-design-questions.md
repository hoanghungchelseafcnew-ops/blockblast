# Câu hỏi thiết kế chức năng: u1-ads-core

Đây là bản mỏng chạy xuyên suốt của đợt này: cấu hình, bộ đếm, thứ tự mạng, đồng ý và interstitial. Phần lớn đã chốt ở các bước trước (`requirements.md`, `contract-summary.md`, `stories.md`). Các câu hỏi dưới đây chỉ hỏi những chi tiết còn lại, chủ yếu về cách quảng cáo chạy và hiện đúng lúc.

## Q1. Thế nào là một "lần mở ứng dụng" để tăng bộ đếm

Bộ đếm lần mở ứng dụng quyết định banner hiện từ lần thứ N. Điện thoại có thể mở ứng dụng từ trạng thái đã tắt hẳn (khởi động nguội), hoặc đưa ứng dụng đang chạy nền trở lại trước màn hình.

Hành động nào tăng bộ đếm?

- A. Chỉ khi ứng dụng khởi động nguội (từ trạng thái đã tắt hẳn)
- B. Cả khởi động nguội và mỗi lần đưa ứng dụng từ nền trở lại trước màn hình
- C. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:B

## Q2. Khi người chơi bấm Start mà interstitial chưa tải xong

Theo hợp đồng, mỗi mạng có thời hạn chờ 5 giây, và thử ba mạng nối tiếp có thể chờ tới 15 giây, quá lâu ngay sau khi bấm Start. Một cách tránh là tải trước interstitial kế tiếp ngay khi ứng dụng khởi động xong và sau mỗi lần hiện.

Nếu đến lượt hiện mà quảng cáo chưa sẵn sàng thì sao?

- A. Bỏ qua lượt này, vào màn chơi ngay, không chờ
- B. Chờ tối đa một thời gian ngắn (nêu số giây ở Other) rồi bỏ qua nếu vẫn chưa có
- C. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:A

## Q3. Lượt interstitial bị bỏ qua có được bù không

Với N bằng 3, interstitial hiện ở lần bấm thứ 3, 6, 9. Nếu lần thứ 3 bị bỏ qua vì chưa sẵn sàng, có thể hiện ở lần thứ 4 hoặc chờ đến lần thứ 6.

Xử lý thế nào?

- A. Không bù: lượt bị bỏ qua mất luôn, lần hiện kế tiếp là lần thứ 6
- B. Bù ngay: lượt bị bỏ qua được chuyển sang lần bấm kế tiếp, nên hiện ở lần thứ 4 nếu đã sẵn sàng
- C. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:B

## Q4. Nơi lưu ID đơn vị quảng cáo (ad unit ID)

ID ứng dụng và ID đơn vị quảng cáo của AdMob, Unity, AppLovin là định danh công khai, nhưng mỗi mạng có ID riêng cho Android và iOS, và có ID thử riêng để dùng khi phát triển.

Lưu ở đâu?

- A. Một tệp hằng số trong mã nguồn, dùng ID thử trong bản debug và ID thật trong bản phát hành
- B. Đặt trên Firebase Remote Config để đổi không cần phát hành lại
- C. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:X- Hãy đặt theo đúng policy của android và ios 

## Q5. Thời điểm hỏi đồng ý của người dùng

Hộp thoại đồng ý chỉ hiện với người dùng ở khu vực cần (EU/EEA) hoặc trên iOS. Theo thiết kế, việc này chạy nền và không chặn màn Splash.

Hộp thoại hiện lúc nào?

- A. Ngay sau khi vào màn Home lần đầu, trước mọi quảng cáo
- B. Ngay trước lần cần quảng cáo đầu tiên (interstitial hoặc banner)
- C. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:A

## Consolidated Summary Confirmation

- Lần mở ứng dụng: tăng ở cả khởi động nguội và mỗi lần đưa ứng dụng từ nền trở lại trước màn hình (Q1)
- Interstitial chưa sẵn sàng khi bấm Start: bỏ qua lượt này và vào màn chơi ngay, không chờ. Tải trước interstitial kế tiếp khi ứng dụng khởi động xong và sau mỗi lần hiện (Q2)
- Lượt bị bỏ qua: được bù, chuyển sang lần bấm Start kế tiếp nếu đã sẵn sàng (Q3)
- ID đơn vị quảng cáo: đặt theo đúng chính sách của Android và iOS. Mình hiểu là lưu trong tệp hằng số trong mã nguồn, riêng cho từng nền tảng và từng mạng, dùng ID thử trong bản debug và ID thật trong bản phát hành, để không bao giờ tạo lượt hiện hay bấm quảng cáo thật khi đang phát triển (Q4)
- Đồng ý của người dùng: hỏi ngay sau khi vào màn Home lần đầu, trước mọi quảng cáo (Q5)

Does this all look correct before I generate the artifact?

- Looks correct
- Request changes

[Answer]: Looks correct
