# Quy tắc nghiệp vụ: u2-reward-ads

Nguồn: `requirements.md` (FR3), `stories.md` (US3.1), `decisions.md` (ADR-003, ADR-007), `contract-summary.md` (hợp đồng 2) và `functional-design-questions.md`.

```yaml
rules:
  - id: BR6.1
    statement: Nút reward chỉ có ở Journey và chỉ khi cờ bật.
    category: policy
    applies_to: GameOverOverlay
    trigger: lớp phủ Game Over hiện
    logic: IF chế độ là Journey AND reward_enabled là true AND ván thua này chưa nhận thưởng THEN hiện nút WATCH AD TO TRY AGAIN.
    violation: nút không hiện
    source: FR3.1, FR3.2, ADR-007
  - id: BR6.2
    statement: Hoãn ghi nhận thua.
    category: policy
    applies_to: LevelGameController
    trigger: hết nước đi ở Journey
    logic: IF hết nước đi THEN chuyển sang trạng thái thua nhưng chưa hạ tiến trình; chỉ ghi nhận thua khi người chơi bấm PLAY AGAIN hoặc BACK TO MENU.
    violation: không áp dụng
    source: FR3.5, ADR-003
  - id: BR6.3
    statement: Nhận thưởng thì chơi tiếp cùng level từ đầu.
    category: policy
    applies_to: LevelGameController
    trigger: AdMediator trả earned hoặc no_ad
    logic: IF người chơi nhận thưởng THEN điểm về 0, bàn cờ xóa sạch, khay khối mới, trạng thái đang chơi, cùng level; không ghi nhận thua và không hạ tiến trình.
    violation: không áp dụng
    source: FR3.4, FR3.5, ADR-007
  - id: BR6.4
    statement: Đóng quảng cáo sớm thì không thưởng.
    category: policy
    applies_to: LevelGameController
    trigger: AdMediator trả closed_early
    logic: IF đóng sớm THEN giữ lớp phủ Game Over, nút reward vẫn hiện để thử lại, không thưởng.
    violation: không áp dụng
    source: FR3.6, Q1
  - id: BR6.5
    statement: Mỗi ván thua nhận thưởng tối đa một lần.
    category: constraint
    applies_to: LevelGameController
    trigger: sau khi nhận thưởng
    logic: IF ván thua này đã nhận thưởng THEN nút không hiện lại cho ván đó; một lần thua mới sau khi chơi tiếp là một ván thua mới và nút hiện lại.
    violation: nút không hiện
    source: FR3.3, Q1, Q2
  - id: BR6.6
    statement: Lưu điểm cao trước khi về 0.
    category: calculation
    applies_to: LevelGameController
    trigger: nhận thưởng
    logic: IF điểm của ván vừa thua cao hơn điểm cao đã lưu THEN lưu điểm đó làm điểm cao trước khi đặt điểm về 0.
    violation: không áp dụng
    source: Q4
  - id: BR6.7
    statement: Lần thua chưa ghi nhận được ghi nhận ở lần mở sau.
    category: policy
    applies_to: LevelGameController, ProgressRepository
    trigger: ứng dụng bị tắt khi đang ở lớp phủ Game Over
    logic: IF có dấu lần thua chưa ghi nhận khi ứng dụng mở lại THEN ghi nhận thua (hạ tiến trình như hiện nay) trước khi người chơi vào màn chơi.
    violation: không áp dụng
    source: Q3
  - id: BR6.8
    statement: Thua được ghi nhận đúng một lần.
    category: constraint
    applies_to: LevelGameController
    trigger: người chơi rời lớp phủ Game Over
    logic: IF lần thua đã được ghi nhận THEN không ghi nhận lại khi bấm thêm nút hoặc khi mở lại ứng dụng.
    violation: không áp dụng
    source: NFR7
```

## Tóm tắt

| Quy tắc | Nội dung |
|---------|----------|
| BR6.1 | Điều kiện hiện nút |
| BR6.2, BR6.7, BR6.8 | Thời điểm và tính duy nhất của việc ghi nhận thua |
| BR6.3, BR6.4, BR6.6 | Kết quả của reward |
| BR6.5 | Giới hạn mỗi ván thua |

Hệ quả cần biết: theo Q2 mỗi lần thua là một ván thua mới, và theo ADR-007 không có quảng cáo vẫn được thưởng. Vì vậy một người chơi tắt mạng có thể chơi lại cùng level không giới hạn mà không bị hạ tiến trình. Bạn đã chấp nhận hệ quả này ở ADR-007.

## Assumptions & Open Questions

None.
