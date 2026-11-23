# Entities: u3-tray-algorithm

Nguồn: components.md (TrayGenerator, DifficultyProfile, BlockCatalog, BoardLogic), requirements.md (FR4, NFR1, NFR2), stories US4.1–US4.6 và 5 câu trả lời trong `functional-design-questions.md`.

```yaml
entities:
  - name: TrayRates
    description: "Tỉ lệ chọn khối cho một cặp (level, độ đầy bảng). Hàm thuần của DifficultyProfile, đã có trong components.md."
    owner: DifficultyProfile
    attributes:
      - { name: smallRate,   type: decimal, required: true, min: 0, max: 1 }
      - { name: mediumRate,  type: decimal, required: true, min: 0, max: 1 }
      - { name: largeRate,   type: decimal, required: true, min: 0, max: 1 }
      - { name: rescueRate,  type: decimal, required: true, min: 0, max: 1 }
    constraints:
      - "smallRate + mediumRate + largeRate = 1"
  - name: DifficultyConstants
    description: "Mọi hằng số cân bằng ở một nơi (FR4.7). Chỉnh được mà không sửa logic."
    owner: DifficultyProfile
    attributes:
      - { name: levelMin, type: integer, required: true, default: 1 }
      - { name: levelMax, type: integer, required: true, default: 36 }
      - { name: endlessLevel, type: integer, required: true, default: 18 }
      - { name: smallRateStart, type: decimal, required: true, default: 0.40 }
      - { name: smallRateEnd, type: decimal, required: true, default: 0.25 }
      - { name: mediumRate, type: decimal, required: true, default: 0.45 }
      - { name: largeRateStart, type: decimal, required: true, default: 0.15 }
      - { name: largeRateEnd, type: decimal, required: true, default: 0.30 }
      - { name: rescueRateStart, type: decimal, required: true, default: 0.30 }
      - { name: rescueRateEnd, type: decimal, required: true, default: 0.10 }
      - { name: fullBoardThresholdCells, type: integer, required: true, default: 38, description: "Bảng coi là đầy khi số ô đã lấp lớn hơn giá trị này (hơn 38 trong 64 ô, tức trên 60%)" }
      - { name: fullBoardSmallBonus, type: decimal, required: true, default: 0.25 }
      - { name: fullBoardLargeFactor, type: decimal, required: true, default: 0.40 }
      - { name: maxLargePerTray, type: integer, required: true, default: 2 }
      - { name: maxStrictCandidates, type: integer, required: true, default: 30 }
      - { name: maxRelaxedCandidates, type: integer, required: true, default: 30 }
      - { name: solverNodeBudget, type: integer, required: true, default: 20000, description: "Số nút tối đa mà bộ giải được duyệt cho một lần chuẩn bị khay (bảo vệ mục tiêu dưới 16 ms)" }
    constraints:
      - "Giá trị khởi điểm, chỉnh được về sau"
      - "Tỉ lệ băng 5% và bom 5% và bảng màu không nằm ở đây; giữ nguyên ở BlockCatalog/logic hiện có"
  - name: BlockModel
    description: "Khối trong khay. Đã có (BlockCatalog); u3 chỉ đọc."
    owner: BlockCatalog
    attributes:
      - { name: shape, type: shape matrix, required: true }
      - { name: color, type: palette color, required: true }
      - { name: isIce, type: boolean, required: true, default: false }
      - { name: iceHealth, type: integer, required: false }
      - { name: isBomb, type: boolean, required: true, default: false }
      - { name: isClearing, type: boolean, required: true, default: false, description: "Khối được chọn làm khối cứu" }
  - name: Tray
    description: "Khay gồm đúng 3 khối. Một khi đã chuẩn bị xong thì bất biến: không khối nào bị thay thế hay đổi hình."
    owner: TrayGenerator
    attributes:
      - { name: blocks, type: "list of BlockModel", required: true, constraints: "đúng 3 phần tử" }
      - { name: tier, type: SolvabilityTier, required: true }
    constraints:
      - "Bất biến sau khi chuẩn bị (BR1.1)"
  - name: SolvabilityTier
    description: "Mức bảo đảm giải được mà khay đạt, kết quả của bộ giải."
    owner: TrayGenerator
    allowed_values:
      - { value: strict, meaning: "Với MỌI thứ tự đặt 3 khối đều có ít nhất một cách đặt hết cả 3 (có tính xóa dòng giữa chừng)" }
      - { value: relaxed, meaning: "Tồn tại ít nhất MỘT thứ tự và một cách đặt hết cả 3" }
      - { value: fallback, meaning: "Khay ba khối 1x1, đặt hết được theo mọi thứ tự khi còn đủ ô" }
  - name: TrayResult
    description: "Kết quả chuẩn bị khay mà TrayGenerator trả về cho BoardEngine."
    owner: TrayGenerator
    attributes:
      - { name: tray, type: Tray, required: false, description: "Vắng khi gameOver = true" }
      - { name: gameOver, type: boolean, required: true }
    constraints:
      - "gameOver = true khi và chỉ khi không có khay nào đặt hết được kể cả khay fallback"
  - name: TrayRequest
    description: "Đầu vào cho một lần chuẩn bị khay."
    owner: TrayGenerator
    attributes:
      - { name: board, type: "BoardLogic board 8x8", required: true }
      - { name: level, type: integer, required: true, min: 1, max: 36, description: "Endless truyền endlessLevel (18)" }
      - { name: random, type: "Random tiêm được", required: true }
relationships:
  - { from: Tray, to: BlockModel, cardinality: "1 - 3", direction: "Tray gồm 3 BlockModel" }
  - { from: Tray, to: SolvabilityTier, cardinality: "1 - 1", direction: "Tray mang mức giải được" }
  - { from: TrayResult, to: Tray, cardinality: "1 - 0..1", direction: "gameOver thì không có Tray" }
  - { from: TrayRequest, to: TrayRates, cardinality: "1 - 1", direction: "DifficultyProfile tính TrayRates từ level và độ đầy của board" }
  - { from: TrayRates, to: DifficultyConstants, cardinality: "N - 1", direction: "TrayRates suy ra từ hằng số" }
```

## Tóm tắt

- `Tray` là thực thể mới và bất biến. Khác với yêu cầu ban đầu (FR4.1: thay một khối khi không khối nào vừa), khay không bao giờ bị sửa sau khi tạo; việc bảo đảm có nước đi nằm ở bước chọn khay trước khi hiển thị.
- `SolvabilityTier` ghi lại mức bảo đảm mà khay đạt, để test và log kiểm tra được.
- `DifficultyConstants` gom toàn bộ hằng số cân bằng ở một nơi; `TrayRates` được suy ra từ đó.
- Không có thực thể lưu trữ lâu dài: u3 không đổi dữ liệu tiến trình đã lưu hay Remote Config (NFR7).
