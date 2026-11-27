# Quy tắc nghiệp vụ: u3-banner

Nguồn: `requirements.md` (FR2, FR5.1, NFR2), `stories.md` (US4.1), `unit-of-work.md` (U3), `unit-of-work-story-map.md`, `components.md` (`AdMediator`, `GameScreen`), `contract-summary.md` (hợp đồng 2, `banner` trả `BannerResult`) và `functional-design-questions.md`.

```yaml
rules:
  - id: BR7.1
    statement: Banner chỉ được yêu cầu từ lần mở ứng dụng thứ N.
    category: policy
    applies_to: AdMediator, GameScreen
    trigger: màn chơi (Journey hoặc Endless) hiện
    logic: IF số lần mở ứng dụng >= banner_start_visit AND đồng ý đã được xử lý THEN tải banner; ELSE không có vùng banner.
    violation: vùng banner không hiện
    source: FR2.2, BR3.1
  - id: BR7.2
    statement: Chạm ngưỡng khi đang ở màn chơi thì tải banner ngay.
    category: policy
    applies_to: GameScreen
    trigger: lần quay lại từ nền được tính là một lần mở trong lúc màn chơi đang mở
    logic: IF màn chơi chưa có banner AND số lần mở vừa chạm banner_start_visit THEN tải banner ngay trên màn chơi đang mở.
    violation: không áp dụng
    source: FR2.1, FR2.2, Q1
  - id: BR7.3
    statement: Thử các mạng theo ads_priority.
    category: policy
    applies_to: AdMediator
    trigger: cần tải banner
    logic: IF cần banner THEN thử từng mạng theo ads_priority, mỗi mạng tối đa 5 giây, dừng ở mạng đầu tiên có banner.
    violation: mạng đó coi như không có banner
    source: FR5.1, BR2.5
  - id: BR7.4
    statement: Không chừa chỗ khi banner đang tải.
    category: constraint
    applies_to: GameScreen
    trigger: banner đang tải
    logic: IF banner chưa tải xong THEN bố cục như không có banner; khi tải xong, vùng banner hiện dưới cùng và bàn cờ cùng khay khối co lại một lần để nhường chỗ, không bị che.
    violation: không áp dụng
    source: FR2.4, AC4.1.6, Q2
  - id: BR7.5
    statement: Không tải được thì ẩn hẳn và chỉ thử lại ở lần vào màn chơi sau.
    category: policy
    applies_to: GameScreen, AdMediator
    trigger: mọi mạng đều không có banner hoặc lỗi
    logic: IF không mạng nào có banner THEN vùng banner ẩn, không chừa khoảng trống, không thử lại cho đến lần vào màn chơi kế tiếp.
    violation: không áp dụng
    source: FR2.4, Q4
  - id: BR7.6
    statement: Lớp phủ che cả banner.
    category: constraint
    applies_to: GameScreen
    trigger: lớp phủ Game Over hoặc Victory hiện
    logic: IF có lớp phủ THEN lớp phủ phủ toàn màn hình, kể cả vùng banner; banner vẫn giữ nguyên bên dưới.
    violation: không áp dụng
    source: Q3
  - id: BR7.7
    statement: Một banner cho mỗi lần vào màn chơi.
    category: constraint
    applies_to: GameScreen
    trigger: chuyển ván trong màn chơi, hoặc rời màn chơi
    logic: IF chuyển ván (CONTINUE, PLAY AGAIN, nhận thưởng) mà vẫn ở màn chơi THEN giữ banner đang hiện; IF rời màn chơi THEN giải phóng banner; lần vào sau tải banner mới.
    violation: không áp dụng
    source: Q5
  - id: BR7.8
    statement: Banner có ở cả Endless.
    category: policy
    applies_to: EndlessGameScreen
    trigger: màn Endless hiện
    logic: IF màn Endless hiện THEN áp dụng BR7.1 đến BR7.7 như màn Journey.
    violation: không áp dụng
    source: FR2.3
  - id: BR7.9
    statement: Lỗi banner không làm dừng game.
    category: constraint
    applies_to: AdMediator, GameScreen
    trigger: SDK ném lỗi khi tải hoặc hiện banner
    logic: IF có lỗi THEN ghi log, coi như không có banner (BR7.5), người chơi tiếp tục chơi.
    violation: không áp dụng
    source: NFR2
```

## Tóm tắt

| Quy tắc | Nội dung |
|---------|----------|
| BR7.1, BR7.2 | Khi nào banner được yêu cầu |
| BR7.3 | Thứ tự mạng |
| BR7.4, BR7.5, BR7.6 | Bố cục: đang tải, thất bại, có lớp phủ |
| BR7.7 | Vòng đời banner trong màn chơi |
| BR7.8 | Endless |
| BR7.9 | Lỗi |

## Assumptions & Open Questions

None.
