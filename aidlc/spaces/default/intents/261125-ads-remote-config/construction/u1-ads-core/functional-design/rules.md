# Quy tắc nghiệp vụ: u1-ads-core

Nguồn: `requirements.md`, `stories.md`, `contract-summary.md`, `components.md` và `functional-design-questions.md`.

```yaml
rules:
  - id: BR1.1
    statement: Dùng giá trị cấu hình khi hợp lệ.
    category: policy
    applies_to: AdsSettings
    trigger: ứng dụng khởi động và đọc cấu hình
    logic: IF tham số có giá trị hợp lệ THEN AdsSettings dùng giá trị đó.
    violation: không áp dụng
    source: FR1.1
  - id: BR1.2
    statement: Dùng giá trị mặc định khi không tải được cấu hình.
    category: policy
    applies_to: AdsSettings
    trigger: tải cấu hình thất bại hoặc quá hạn
    logic: IF không tải được cấu hình THEN AdsSettings dùng toàn bộ mặc định và ứng dụng chạy bình thường.
    violation: không áp dụng
    source: FR1.2
  - id: BR1.3
    statement: Giá trị số không hợp lệ được coi như thiếu.
    category: validation
    applies_to: AdsSettings
    trigger: đọc tham số số nguyên
    logic: IF giá trị không phải số nguyên dương THEN dùng mặc định của tham số đó và ghi một dòng cảnh báo vào nhật ký.
    violation: dùng mặc định, không báo cho người chơi
    source: FR1.3
  - id: BR1.4
    statement: Khởi tạo quảng cáo không chặn khởi động.
    category: constraint
    applies_to: AppBootstrap
    trigger: khởi động ứng dụng
    logic: IF khởi tạo quảng cáo hoặc đồng ý chưa xong THEN màn Splash vẫn chuyển sang Home trong hạn chót 3,5 giây và quảng cáo chưa hiện.
    violation: không áp dụng
    source: NFR1
  - id: BR2.1
    statement: Thử mạng theo thứ tự ads_priority.
    category: policy
    applies_to: AdMediator
    trigger: cần một quảng cáo
    logic: IF có danh sách mạng THEN thử mạng đứng đầu trước, và nếu không có quảng cáo thì thử mạng kế theo thứ tự.
    violation: không áp dụng
    source: FR5.3
  - id: BR2.2
    statement: Thứ tự mặc định khi ads_priority thiếu hoặc rỗng.
    category: policy
    applies_to: AdsSettings
    trigger: đọc ads_priority
    logic: IF ads_priority thiếu hoặc rỗng THEN dùng admob, unity, applovin.
    violation: không áp dụng
    source: FR5.2
  - id: BR2.3
    statement: Tên mạng lạ bị bỏ qua.
    category: validation
    applies_to: AdsSettings
    trigger: đọc ads_priority
    logic: IF một tên không thuộc admob, unity, applovin THEN bỏ tên đó và giữ các mạng còn lại theo thứ tự.
    violation: bỏ qua tên đó
    source: FR5.2
  - id: BR2.4
    statement: Không có quảng cáo thì game chạy tiếp.
    category: constraint
    applies_to: AdMediator
    trigger: mọi mạng không có quảng cáo
    logic: IF mọi mạng không có quảng cáo hoặc lỗi THEN không hiện quảng cáo và game chạy tiếp, không báo lỗi cho người chơi.
    violation: không áp dụng
    source: NFR2
  - id: BR2.5
    statement: Mỗi mạng có thời hạn chờ 5 giây.
    category: constraint
    applies_to: AdMediator
    trigger: tải quảng cáo của một mạng
    logic: IF một mạng không phản hồi trong 5 giây THEN coi như không có quảng cáo ở mạng đó và thử mạng kế.
    violation: không áp dụng
    source: contract-summary hợp đồng 2
  - id: BR3.1
    statement: Chưa có quảng cáo nào trước khi đồng ý được xử lý.
    category: constraint
    applies_to: AdMediator
    trigger: cần một quảng cáo
    logic: IF ConsentStatus.state là not_processed hoặc required THEN không yêu cầu quảng cáo nào.
    violation: không có quảng cáo
    source: FR8.1
  - id: BR3.2
    statement: Từ chối đồng ý thì quảng cáo không cá nhân hóa.
    category: policy
    applies_to: ConsentService
    trigger: người dùng từ chối
    logic: IF state là denied THEN personalizedAllowed là false và quảng cáo vẫn hiện ở dạng không cá nhân hóa.
    violation: không áp dụng
    source: FR8.2
  - id: BR3.3
    statement: Đồng ý thì có thể cá nhân hóa.
    category: policy
    applies_to: ConsentService
    trigger: người dùng đồng ý hoặc không áp dụng
    logic: IF state là granted hoặc not_applicable THEN personalizedAllowed là true.
    violation: không áp dụng
    source: FR8.2
  - id: BR3.4
    statement: Hỏi đồng ý ngay sau khi vào Home lần đầu.
    category: policy
    applies_to: ConsentService
    trigger: lần đầu vào màn Home
    logic: IF người dùng thuộc khu vực cần đồng ý hoặc dùng iOS cần xin phép theo dõi THEN hiện hộp thoại ngay sau khi vào Home lần đầu và trước mọi quảng cáo.
    violation: không có quảng cáo cho đến khi xử lý xong
    source: FR8.1
  - id: BR4.1
    statement: Đếm lần bấm Start và lưu bền.
    category: calculation
    applies_to: AdCounterState
    trigger: người chơi bấm PLAY ở Home hoặc PLAY AGAIN ở Game Over
    logic: IF có một lần bấm Start THEN startCount tăng đúng một và được lưu, giữ khi thoát ứng dụng.
    violation: không áp dụng
    source: FR4.1
  - id: BR4.2
    statement: Hiện interstitial sau mỗi N lần bấm Start.
    category: policy
    applies_to: AdMediator
    trigger: sau khi startCount đã tăng
    logic: IF startCount chia hết cho interstitialEveryNStarts HOẶC interstitialCarriedDue là true THEN cần hiện interstitial ngay sau khi bấm và trước khi màn chơi mở.
    violation: không áp dụng
    source: FR4.2
  - id: BR4.3
    statement: Interstitial áp dụng cả ở Endless.
    category: policy
    applies_to: AdMediator
    trigger: bấm PLAY ở chế độ Endless
    logic: IF chế độ là Endless THEN tính lần bấm Start và hiện interstitial như Journey.
    violation: không áp dụng
    source: FR4.4
  - id: BR4.4
    statement: Chưa sẵn sàng thì bỏ qua và bù ở lần sau.
    category: policy
    applies_to: AdMediator
    trigger: cần hiện interstitial mà InterstitialSlot.ready là false
    logic: IF cần hiện mà quảng cáo chưa sẵn sàng THEN bỏ qua lượt này, vào màn chơi ngay không chờ, và đặt interstitialCarriedDue là true; khi một interstitial hiện thành công thì đặt lại là false.
    violation: không áp dụng
    source: FR4.5
  - id: BR4.5
    statement: Không có khoảng cách tối thiểu giữa hai interstitial.
    category: policy
    applies_to: AdMediator
    trigger: đủ điều kiện hiện interstitial
    logic: IF đủ điều kiện THEN hiện, không xét thời gian kể từ lần hiện trước.
    violation: không áp dụng
    source: FR4.3
  - id: BR4.6
    statement: Tải trước interstitial kế tiếp.
    category: policy
    applies_to: AdMediator
    trigger: ứng dụng khởi động xong và đồng ý đã xử lý, hoặc sau mỗi lần interstitial hiện xong
    logic: IF điều kiện trên THEN bắt đầu tải interstitial kế tiếp để InterstitialSlot sẵn sàng.
    violation: không áp dụng
    source: Q2 của functional-design-questions
  - id: BR5.1
    statement: Đếm lần mở ứng dụng, lưu bền.
    category: calculation
    applies_to: AdCounterState
    trigger: ứng dụng khởi động nguội hoặc trở lại trước màn hình từ nền
    logic: IF xảy ra một trong hai sự kiện và không thuộc ngoại lệ BR5.3 THEN appOpenCount tăng đúng một và được lưu.
    violation: không áp dụng
    source: FR2.1
  - id: BR5.2
    statement: ID quảng cáo thử cho bản debug, ID thật cho bản phát hành.
    category: constraint
    applies_to: AdNetworkAdapters
    trigger: dựng cấu hình mạng quảng cáo
    logic: IF là bản debug THEN dùng ID thử của từng mạng và từng nền tảng; IF là bản phát hành THEN dùng ID thật. ID nằm trong một tệp hằng số riêng cho từng nền tảng và từng mạng.
    violation: không áp dụng
    source: Q4 của functional-design-questions
  - id: BR5.3
    statement: Không đếm lần quay lại do quảng cáo hoặc hộp thoại hệ thống.
    category: constraint
    applies_to: AdCounterState
    trigger: ứng dụng trở lại trước màn hình
    logic: IF lần trở lại xảy ra do quảng cáo toàn màn hình vừa đóng, hộp thoại đồng ý hoặc xin phép theo dõi, hoặc bảng chia sẻ của hệ điều hành THEN không tăng appOpenCount.
    violation: không đếm
    source: Q1 của functional-design-questions
```

## Tóm tắt

| Nhóm | Quy tắc |
|------|---------|
| Cấu hình | BR1.1 đến BR1.4 |
| Thứ tự mạng | BR2.1 đến BR2.5 |
| Đồng ý | BR3.1 đến BR3.4 |
| Interstitial | BR4.1 đến BR4.6 |
| Bộ đếm và ID | BR5.1 đến BR5.3 |

BR5.3 là quy tắc mình thêm vì Q1 chọn tính cả lần quay lại từ nền: nếu không loại trừ, mỗi lần quảng cáo toàn màn hình đóng hoặc bảng chia sẻ đóng cũng bị đếm là một lần mở, làm banner hiện sớm hơn dự kiến.

## Assumptions & Open Questions

None.
