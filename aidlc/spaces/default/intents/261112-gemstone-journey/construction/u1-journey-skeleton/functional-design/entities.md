# Entities — U1 `u1-journey-skeleton`

## Sources

- [comp] `inception/domain-design/components.md` (LevelConfig, Level, PlayerProgress, PlayerSettings, BoardState, LevelRound)
- [contract] `inception/contract-design/contract-summary.md` (C1, C2, C3, C5, E1, E3)
- [req] `inception/requirements-analysis/requirements.md` (FR2, FR3, FR8)
- [Q1]–[Q4] `functional-design-questions.md`

```yaml
entities:
  - name: LevelConfig
    description: Cấu hình 36 mốc điểm (và URL ảnh tùy chọn) đã được validate, đang có hiệu lực trong phiên
    attributes:
      - { name: version, type: integer, required: true, min: 1 }
      - { name: levels, type: "map<gemId, GemConfig>", required: true, constraints: "đúng 6 gem; mỗi gem đúng 6 sub" }
      - { name: source, type: enum, required: true, allowed: [remote, cached, default] }
    constraints:
      - "Toàn bộ cấu hình hoặc hợp lệ hết, hoặc bị thay bằng cấu hình mặc định (không có trạng thái nửa vời)"
    relationships:
      - { to: Level, cardinality: "1 → 36", direction: "LevelConfig là nguồn của Level" }

  - name: GemConfig
    description: Phần cấu hình của một đá quý trong LevelConfig
    attributes:
      - { name: gemId, type: enum, required: true, allowed: [rose_quartz, amethyst, blue_topaz, emerald, sapphire, ruby] }
      - { name: order, type: integer, required: true, min: 1, max: 6, unique: true }
      - { name: name, type: string, required: true }
      - { name: subLevels, type: "map<subId, SubLevelConfig>", required: true, constraints: "đúng 6 sub" }

  - name: SubLevelConfig
    description: Phần cấu hình của một level con
    attributes:
      - { name: subId, type: enum, required: true, allowed: [rough_stone, slabbing, shaping, sanding, polishing, bling] }
      - { name: order, type: integer, required: true, min: 1, max: 6, unique: "trong cùng gem" }
      - { name: name, type: string, required: true }
      - { name: targetScore, type: integer, required: true, min: 1, max: 10000000 }
      - { name: backgroundUrl, type: string, required: false, default: null, constraints: "https; host firebasestorage.googleapis.com hoặc *.firebasestorage.app" }

  - name: Level
    description: Một trong 36 level của hành trình, bất biến trong phiên
    attributes:
      - { name: levelIndex, type: integer, required: true, unique: true, min: 1, max: 36 }
      - { name: gemId, type: enum, required: true, allowed: [rose_quartz, amethyst, blue_topaz, emerald, sapphire, ruby] }
      - { name: gemName, type: string, required: true }
      - { name: gemOrder, type: integer, required: true, min: 1, max: 6 }
      - { name: subId, type: enum, required: true, allowed: [rough_stone, slabbing, shaping, sanding, polishing, bling] }
      - { name: subName, type: string, required: true }
      - { name: subOrder, type: integer, required: true, min: 1, max: 6 }
      - { name: targetScore, type: integer, required: true, min: 1, max: 10000000 }
      - { name: backgroundUrl, type: string, required: false, default: null }
      - { name: assetPath, type: string, required: true, constraints: "assets/design/Level<gemOrder>/<subOrder>.jpg" }
    constraints:
      - "levelIndex = (gemOrder - 1) × 6 + subOrder"
    relationships:
      - { to: LevelConfig, cardinality: "36 → 1", direction: "Level được dựng từ LevelConfig" }

  - name: PlayerProgress
    description: Tiến trình hành trình đã lưu của người chơi (key `progress`)
    attributes:
      - { name: currentLevelIndex, type: integer, required: true, min: 1, max: 36, default: 1 }
      - { name: completedLevels, type: "set<integer>", required: true, default: [], constraints: "mỗi phần tử trong 1..36" }
      - { name: unlockedGems, type: "set<gemId>", required: true, default: [], note: "U1 không ghi; U2 dùng" }
      - { name: journeyCompleted, type: boolean, required: true, default: false, note: "U1 luôn false" }
      - { name: highestLevelReached, type: integer, required: true, min: 1, max: 36, default: 1, note: "level cao nhất người chơi từng MỞ được (đã tới), không phải đã hoàn thành (BR4.1)" }
    constraints:
      - "highestLevelReached ≥ currentLevelIndex"
      - "highestLevelReached không giảm trong phiên và qua các lần ghi thành công"
    relationships:
      - { to: Level, cardinality: "N → 1 (currentLevelIndex), N → N (completedLevels)", direction: "tham chiếu theo levelIndex" }

  - name: PlayerSettings
    description: Cài đặt bền vững của người chơi
    attributes:
      - { name: tutorialCompleted, type: boolean, required: true, default: false, note: "key cũ `tutorial_completed` được giữ; giá trị không phải bool → false + log (BR3.5)" }
      - { name: soundMuted, type: boolean, required: true, default: false, note: "U1 chưa dùng; U3" }

  - name: BoardState
    description: Trạng thái bảng 8×8 và khay khối của một ván (chỉ trong bộ nhớ)
    attributes:
      - { name: cells, type: "grid 8×8 of Cell", required: true }
      - { name: trayBlocks, type: "list<Block>", required: true, min: 0, max: 3 }
      - { name: score, type: integer, required: true, min: 0, default: 0 }
      - { name: comboStreak, type: integer, required: true, min: 0, default: 0 }

  - name: LevelRound
    description: Một ván chơi ở chế độ level (chỉ trong bộ nhớ)
    attributes:
      - { name: roundId, type: string, required: true, unique: true }
      - { name: levelIndex, type: integer, required: true, min: 1, max: 36 }
      - { name: targetScore, type: integer, required: true, min: 1, constraints: "chốt lúc start, không đổi trong ván; luôn ≥ 1 (BR5.5)" }
      - { name: status, type: enum, required: true, allowed: [playing, resolving, won, lost, quit], default: playing, note: "U1 dùng `lost` cho overlay Game Over cũ nhưng KHÔNG đổi tiến trình (BR5.7); sửa đổi contract C2 u1_defaults" }
      - { name: clearing, type: boolean, required: true, default: false, note: "true trong 180ms animation xóa dòng (BR5.10)" }
      - { name: progressPercent, type: integer, required: true, min: 0, max: 100 }
      - { name: revived, type: boolean, required: true, default: false, note: "U1 giữ REVIVE cũ (Q2)" }
      - { name: outcome, type: JourneyOutcome, required: false }
    relationships:
      - { to: Level, cardinality: "N → 1" }
      - { to: BoardState, cardinality: "1 → 1" }

  - name: JourneyOutcome
    description: Kết quả trả về sau khi xử lý thắng (U1)
    attributes:
      - { name: nextLevel, type: Level, required: false, note: "null khi đang ở level 36" }
      - { name: highestLevelReached, type: integer, required: true, min: 1, max: 36 }
      - { name: unlockedGemId, type: gemId, required: false, default: null, note: "U1 luôn null" }
      - { name: journeyCompleted, type: boolean, required: true, default: false, note: "U1 luôn false" }
```

## Tóm tắt (đã sửa theo review-01)

- **Cấu hình**: `LevelConfig` gồm `GemConfig` và `SubLevelConfig`. `LevelConfig` sinh ra 36 `Level` bất biến trong phiên.
- **Lưu bền vững**: `PlayerProgress` và `PlayerSettings` (SharedPreferences qua `ProgressRepository`).
- **Trong bộ nhớ**: `LevelRound` sở hữu một `BoardState`. Thắng sinh ra `JourneyOutcome`.
- Các trường dành cho unit sau (`unlockedGems`, `soundMuted`, `status=lost`, `unlockedGemId`, `journeyCompleted`) đã có từ U1 với giá trị mặc định, theo contract C1, C2 và C5.

## Assumptions & Open Questions

None.

> Đã sửa theo `reviews/review-01.md`: R-02 (nghĩa `highestLevelReached`), R-06 (`status=lost` cho overlay ở U1), R-07 (`targetScore ≥ 1`, cờ `clearing`), R-10 (tutorial hỏng).
