# Business Rules: u3-tray-algorithm

Ký hiệu: `t = (level − 1) / 35` (level 1 → 0, level 36 → 1); "độ đầy" là số ô đã lấp trên bảng 8×8.

```yaml
rules:
  - id: BR1.1
    statement: "Khay đã chuẩn bị thì bất biến: không khối nào bị thay thế hay đổi hình sau đó."
    category: constraint
    applies_to: Tray
    trigger: "Sau khi TrayGenerator trả khay cho BoardEngine"
    logic: "IF khay đã được trả về THEN không có bước nào sửa blocks của khay"
    violation: "Lỗi lập trình; test phát hiện khi blocks khay đổi giữa lúc chuẩn bị và lúc người chơi đặt"
    source: "Câu 1 = X (người dùng, message f0e6f665); thay thế FR4.1"
  - id: BR1.2
    statement: "Bảo đảm mức strict: TrayGenerator ưu tiên chọn khay mà với MỌI thứ tự đặt 3 khối đều có cách đặt hết cả 3."
    category: policy
    applies_to: TrayGenerator
    trigger: "Chuẩn bị khay mới"
    logic: "FOR EACH ứng viên (tối đa maxStrictCandidates): IF cả 6 thứ tự đều có ít nhất một chuỗi vị trí đặt hết 3 khối (đặt tuần tự, có xóa dòng giữa chừng) THEN chọn khay này với tier = strict"
    violation: "Không có ứng viên đạt trong giới hạn: hạ xuống BR1.3"
    source: "Câu 1 = X, Câu 4 = B; FR4.1 (thay thế)"
  - id: BR1.3
    statement: "Hạ mức relaxed: khi không có khay strict thì chọn khay có ít nhất một thứ tự đặt hết 3 khối."
    category: policy
    applies_to: TrayGenerator
    trigger: "BR1.2 không tìm được ứng viên strict"
    logic: "FOR EACH ứng viên (tối đa maxRelaxedCandidates): IF tồn tại ít nhất một thứ tự và chuỗi vị trí đặt hết 3 khối THEN chọn khay này với tier = relaxed"
    violation: "Không có ứng viên đạt: hạ xuống BR1.4"
    source: "Câu 5 = A"
  - id: BR1.4
    statement: "Khay cuối cùng và điều kiện thua: khi cả hai mức trên không có khay, thử khay ba khối 1x1; nếu khay đó cũng không đặt hết được thì Game Over ngay khi chuẩn bị khay."
    category: policy
    applies_to: TrayGenerator
    trigger: "BR1.3 không tìm được ứng viên"
    logic: "IF khay {1x1, 1x1, 1x1} đặt hết được (tier = fallback) THEN dùng khay đó ELSE trả gameOver = true và không hiển thị khay"
    violation: "Không áp dụng; đây chính là hành vi thua"
    source: "Câu 3 = B, Câu 5 = A; AC4.1.2"
  - id: BR1.5
    statement: "Với mọi bảng có ít nhất 3 ô trống, kết quả chuẩn bị khay luôn có khay (không Game Over)."
    category: constraint
    applies_to: TrayGenerator
    trigger: "Chuẩn bị khay mới"
    logic: "IF số ô trống >= 3 THEN khay {1x1, 1x1, 1x1} luôn đặt hết được (mỗi lần đặt cần một ô trống, xóa dòng chỉ thêm ô) nên TrayResult.gameOver = false"
    violation: "Lỗi lập trình; kiểm bằng test thuộc tính trên nhiều seed (NFR2)"
    source: "AC4.1.3, NFR2"
  - id: BR2.1
    statement: "Khối cứu: khi sinh mỗi khối, với xác suất rescueRate chọn một khối có thể xóa ít nhất một hàng hoặc cột."
    category: policy
    applies_to: TrayGenerator
    trigger: "Sinh từng khối của khay ứng viên"
    logic: "IF bảng có ít nhất một hình xóa được hàng/cột AND random < rescueRate THEN chọn ngẫu nhiên một hình xóa được (isClearing = true) bỏ qua nhóm kích thước"
    violation: "Không có; nếu không có hình nào thì dùng BR2.2"
    source: "FR4.3, AC4.2.1"
  - id: BR2.2
    statement: "Khi không có hình nào xóa được dòng thì áp dụng luật thường."
    category: policy
    applies_to: TrayGenerator
    trigger: "BR2.1 không có hình xóa được"
    logic: "IF không có hình xóa được dòng THEN chọn nhóm kích thước theo BR3.1–BR3.3"
    violation: "Không có"
    source: "AC4.2.2"
  - id: BR2.3
    statement: "rescueRate giảm tuyến tính theo level."
    category: calculation
    applies_to: DifficultyProfile
    trigger: "Tính TrayRates"
    logic: "rescueRate = rescueRateStart + (rescueRateEnd - rescueRateStart) * t, tức 0.30 - 0.20 * t; level 1 = 30%, level 36 = 10%"
    violation: "Level ngoài 1..36 được kẹp vào khoảng này"
    source: "FR4.4, AC4.2.3, AC4.4.2"
  - id: BR3.1
    statement: "Tỉ lệ nhỏ/vừa/lớn theo level (bảng tối đa 60%)."
    category: calculation
    applies_to: DifficultyProfile
    trigger: "Tính TrayRates khi độ đầy <= fullBoardThresholdCells"
    logic: "small = 0.40 - 0.15 * t; medium = 0.45; large = 0.15 + 0.15 * t (level 1: 40/45/15, level 36: 25/45/30)"
    violation: "Không có"
    source: "FR4.6, AC4.3.2, AC4.4.1; Câu 2 = A"
  - id: BR3.2
    statement: "Khi bảng đầy trên 60% (hơn 38 trong 64 ô), tăng khối nhỏ và giảm khối lớn so với mức BR3.1 của cùng level."
    category: calculation
    applies_to: DifficultyProfile
    trigger: "Tính TrayRates khi độ đầy > fullBoardThresholdCells"
    logic: "small' = small + 0.25; large' = large * 0.40; medium' = 1 - small' - large' (level 1: 65/29/6)"
    violation: "Không có"
    source: "FR4.5, AC4.3.1; Câu 2 = A"
  - id: BR3.3
    statement: "Tối đa 2 khối lớn trong một khay."
    category: constraint
    applies_to: TrayGenerator
    trigger: "Chọn nhóm kích thước cho khối thứ 2 hoặc 3"
    logic: "IF khay đã có maxLargePerTray khối lớn THEN chọn lại nhóm kích thước chỉ trong nhỏ/vừa theo tỉ lệ tương đối"
    violation: "Không có"
    source: "Quy tắc hiện có, giữ lại (Câu 2)"
  - id: BR4.1
    statement: "Độ khó tăng theo level: tỉ lệ khối lớn tăng và rescueRate giảm khi level tăng."
    category: policy
    applies_to: DifficultyProfile
    trigger: "So sánh TrayRates giữa các level"
    logic: "large(level 36) > large(level 1) AND rescueRate(level 36) < rescueRate(level 1)"
    violation: "Test cân bằng phải fail"
    source: "AC4.4.1, AC4.4.2"
  - id: BR4.2
    statement: "Endless dùng cùng thuật toán với mức độ khó cố định level 18."
    category: policy
    applies_to: EndlessGameController
    trigger: "Chuẩn bị khay trong Endless"
    logic: "level = endlessLevel (18); mọi rule BR1.x–BR3.x áp dụng như Journey"
    violation: "Không có"
    source: "AC4.5.1, AC4.5.2"
  - id: BR5.1
    statement: "Mọi hằng số cân bằng nằm ở một nơi (DifficultyConstants)."
    category: constraint
    applies_to: DifficultyProfile
    trigger: "Chỉnh cân bằng"
    logic: "IF cần đổi tỉ lệ, ngưỡng, giới hạn ứng viên hay ngân sách bộ giải THEN chỉ sửa DifficultyConstants, không sửa logic"
    violation: "Review mã từ chối hằng số rải rác"
    source: "FR4.7, AC4.6.1"
  - id: BR5.2
    statement: "Cùng bảng, cùng level, cùng seed thì cho đúng cùng một khay."
    category: constraint
    applies_to: TrayGenerator
    trigger: "Chuẩn bị khay"
    logic: "TrayGenerator chỉ lấy ngẫu nhiên từ Random được tiêm vào; thứ tự ứng viên và thứ tự duyệt của bộ giải cố định; bộ giải dùng ngân sách theo số nút, không theo thời gian đồng hồ"
    violation: "Test theo seed fail"
    source: "FR4.9, AC4.6.2"
  - id: BR5.3
    statement: "Giữ nguyên tỉ lệ băng 5%, bom 5% và bảng màu."
    category: constraint
    applies_to: TrayGenerator
    trigger: "Sinh từng khối"
    logic: "Gán băng/bom/màu theo đúng cơ chế và tỉ lệ hiện có; u3 không đổi các giá trị này"
    violation: "Test so với hành vi hiện có fail"
    source: "FR4.8, AC4.6.3"
  - id: BR5.4
    statement: "Chuẩn bị một khay (kể cả bộ giải) hoàn thành dưới 16 ms trên máy tầm trung."
    category: constraint
    applies_to: TrayGenerator
    trigger: "Chuẩn bị khay"
    logic: "Bộ giải duyệt tối đa solverNodeBudget nút cho một lần chuẩn bị, thoát sớm khi tìm được cách đặt; ứng viên bị cạn ngân sách coi là chưa chứng minh được và bị loại ở mức hiện tại; khay fallback không cần ngân sách"
    violation: "Test hiệu năng trên bảng đầy 60–90% vượt 16 ms thì giảm ngân sách hoặc số ứng viên"
    source: "NFR1"
```

## Tóm tắt luật

| ID | Nhóm | Nội dung ngắn |
|---|---|---|
| BR1.1 | constraint | Khay bất biến sau khi chuẩn bị |
| BR1.2 | policy | Ưu tiên khay strict (mọi thứ tự đều đặt hết được) |
| BR1.3 | policy | Hạ xuống relaxed (một thứ tự đặt hết được) |
| BR1.4 | policy | Khay 1x1 cuối cùng, nếu không được thì Game Over |
| BR1.5 | constraint | Từ 3 ô trống trở lên không bao giờ Game Over |
| BR2.1–BR2.3 | policy/calculation | Khối cứu và rescueRate 30% → 10% |
| BR3.1–BR3.3 | calculation/constraint | Tỉ lệ nhỏ/vừa/lớn, thay đổi khi bảng đầy trên 60%, tối đa 2 khối lớn |
| BR4.1–BR4.2 | policy | Độ khó tăng theo level, Endless dùng level 18 |
| BR5.1–BR5.4 | constraint | Hằng số một nơi, tất định theo seed, giữ băng/bom/màu, dưới 16 ms |
