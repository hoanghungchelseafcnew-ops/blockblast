# Contract Summary — Gemstone Journey

## Sources

- [units] `inception/units-generation/unit-of-work.md`, `unit-of-work-dependency.md` (DAG: u2→u1, u3→u2, u4→u1, u5→u1,u2, u6→u2)
- [comp] `inception/domain-design/components.md`, `decisions.md` (ADR-004, 005, 006, 008, 009, 010)
- [req] `inception/requirements-analysis/requirements.md` (FR3, FR4, FR8, FR9, NFR4, NFR6)
- [Q1]–[Q3] `contract-design-questions.md`

## Contracts

| # | Provider Unit | Consumer | Mechanism | Owner |
|---|---------------|----------|-----------|-------|
| C1 | U1 `JourneyController` | U2 (mở rộng), `LevelGameController` | API Dart nội bộ (`Future`) | U1, U2 mở rộng thêm |
| C2 | U1 `LevelGameController` state | U3 `VictoryUI`, U2 `GameplayUI` | API Dart nội bộ (`ChangeNotifier`) | U1 |
| C3 | U1 `LevelCatalog` / `Level` | U4 `BackgroundImageService`, U2 | API Dart nội bộ | U1 |
| C4 | U1 `AnalyticsService` (interface, no-op) | U5 (triển khai Firebase), `LevelGameController`, `SessionTracker` | API Dart nội bộ | U1 định nghĩa, U5 triển khai |
| C5 | U1 `ProgressRepository` | U2, U3, U5, U6 | API Dart nội bộ (`Future`, hàng đợi ghi tuần tự) | U1 |
| C6 | U4 `GemTheme` | U1/U3 widget (thay `ThemeManager` / `VictoryColors`) | API Dart nội bộ | U4 |
| E1 | External: Firebase Remote Config (người dùng soạn JSON) | U1 `LevelConfigService` | Shared schema (JSON) | U1 (schema). Người dùng chịu trách nhiệm nội dung |
| E2 | U5 `AnalyticsService` | External: Firebase Analytics / người dùng đọc số liệu | Event schema | U5 |
| E3 | U1 `ProgressRepository` (bản app N) | U1 `ProgressRepository` (bản app N+1) | Shared schema (SharedPreferences) | U1 |

**Quan hệ với DAG** [review R-01]: DAG trong `unit-of-work-dependency.md` chỉ ghi **phụ thuộc trực tiếp ở thời điểm xây dựng** (unit nào phải xong trước). Cột Consumer ở trên ghi **mọi nơi dùng contract**, kể cả qua bắc cầu:
- U3 và U6 dùng C5 (`ProgressRepository` của U1) thông qua cạnh u3→u2→u1 và u6→u2→u1.
- U5 dùng C4 và C5 thông qua cạnh trực tiếp u5→u1.

Vì vậy, khi sửa một contract do U1 sở hữu (C1–C5, E1, E3), phải kiểm tra **mọi consumer trong bảng này**, không chỉ các unit kề nó trong DAG.

---

## C1 — JourneyController

```yaml
# Dart API contract (shared-schema)
contract: JourneyController
owner: u1-journey-skeleton
extended_by: u2-level-rules
types:
  JourneyOutcome:
    nextLevel: Level?            # null khi journeyCompleted
    highestLevelReached: int     # 1..36, không bao giờ giảm
    unlockedGemId: String?       # U2: id gem vừa mở khóa (thắng Bling)
    journeyCompleted: bool       # U2: true sau Ruby · Bling
methods:
  currentLevel:  { returns: Level, sync: true }
  journeyCompleted: { returns: bool, sync: true }          # U2
  onLevelWon:  { params: [Level level, int score], returns: Future<JourneyOutcome>,
                 guarantee: "hoàn tất SAU KHI ProgressRepository ghi xong (ADR-008)" }
  onLevelLost: { params: [Level level, int score], returns: Future<JourneyOutcome>,   # U2
                 guarantee: "đặt currentLevel = Rough Stone của gem; xóa các sub của gem khỏi completedLevels; giữ highScores" }
errors:
  write_failure: "repository log lỗi và đánh dấu dirty (xem C5); Future vẫn hoàn tất với outcome tính từ cache bộ nhớ; không throw (không treo resolving)"
u1_defaults:   # [review R-02] U1 phải biên dịch và chạy khi chưa có U2
  JourneyOutcome.unlockedGemId: "luôn null ở U1"
  JourneyOutcome.journeyCompleted: "luôn false ở U1 (level 36 thắng → nextLevel = null, giữ nguyên ở level 36)"
  journeyCompleted getter: "có từ U1, luôn trả về false cho tới U2"
  onLevelLost: "KHÔNG có ở U1. Thua ở U1 dùng Game Over cũ, không đổi tiến trình. U2 thêm phương thức này"
```

## C2 — LevelGameController (state cho UI)

```yaml
contract: LevelGameController
owner: u1-journey-skeleton
kind: ChangeNotifier
state:
  status: enum [playing, resolving, won, lost, quit]   # lost từ U2
  level: Level
  targetScore: int        # chốt lúc start (ADR-010)
  score: int
  bestScore: int          # U2
  progressPercent: int    # floor(score/target*100), tối đa 99 khi score < target, 100 khi won
  board: BoardState
  outcome: JourneyOutcome?   # có giá trị khi won/lost
actions:
  start(): void
  onDragStart(BlockModel) / onDragUpdate(Offset) / placeAt(int row, int col): void   # bị bỏ qua khi status != playing
  quit(): void             # chỉ khi playing; không gọi onLevelLost
invariants:
  - "won/lost chỉ được set một lần cho mỗi round"
  - "won ưu tiên hơn hết nước đi trong cùng lượt"
  - "UI chỉ mở VictoryUI khi status == won"
u1_defaults:   # [review R-02]
  status: "enum có ĐỦ 5 giá trị [playing, resolving, won, lost, quit] ngay từ U1. U1 chưa bao giờ đặt `lost` (dùng Game Over cũ), nên thêm hành vi ở U2 không làm vỡ `switch` nào"
  bestScore: "U1 luôn = 0 và UI ẩn BEST khi = 0. U2 điền giá trị thật"
switch_rule: "Mọi `switch` trên `status` phải liệt kê đủ các case (không dùng default). Nếu sau này thêm giá trị enum, compiler sẽ báo mọi call site, và phải sửa hết trong cùng lần thay đổi"
```

## C3 — Level / LevelCatalog

```yaml
contract: Level
owner: u1-journey-skeleton
fields:
  levelIndex: int        # 1..36
  gemId: String          # rose_quartz|amethyst|blue_topaz|emerald|sapphire|ruby
  gemName: String
  gemOrder: int          # 1..6
  subId: String          # rough_stone|slabbing|shaping|sanding|polishing|bling
  subName: String
  subOrder: int          # 1..6
  targetScore: int       # 1..10,000,000
  backgroundUrl: String? # đã validate https + host (ADR-006); null nếu không có/sai
  assetPath: String      # assets/design/Level<gemOrder>/<subOrder>.jpg
LevelCatalog:
  levels: List<Level>          # đúng 36 phần tử, bất biến trong phiên
  byIndex(int): Level
  next(Level): Level?          # null cho level 36
  firstSubOf(String gemId): Level
  isBling(Level): bool
  isFinal(Level): bool
```

## C4 — AnalyticsService (interface)

```yaml
contract: AnalyticsService
owner: u1-journey-skeleton (interface + NoopAnalyticsService)
implemented_by: u5-analytics (FirebaseAnalyticsService, FakeAnalyticsService)
methods:
  logLevelStart:    { params: [Level level] }
  logLevelComplete: { params: [Level level, int score, int target] }
  logLevelFail:     { params: [Level level, int score, int target] }
  logGameSession:   { params: [int durationSec] }
  setProgressProperties: { params: [String currentMajorLevel, int highestLevelReached] }
  setConfigSource: { params: [String source], note: "remote|cached|default; gọi một lần sau bootstrap [review R-05]" }
all_methods:
  returns: Future<void>
  errors: "không throw; lỗi SDK được log"
```

## C5 — ProgressRepository

```yaml
contract: ProgressRepository
owner: u1-journey-skeleton
lifecycle: "load() một lần trong AppBootstrap; sau đó đọc đồng bộ từ cache"
reads:
  progress: PlayerProgress
  highScore(int levelIndex): int          # U2
  endlessState: EndlessState              # U6
  soundMuted: bool                        # U3
  tutorialCompleted: bool
writes:   # mọi hàm trả về Future hoàn tất khi đã ghi đĩa; tuần tự qua 1 hàng đợi (ADR-009)
  savePlayerProgress(PlayerProgress)
  saveHighScore(int levelIndex, int score)        # U2
  addPlayTime(int seconds)                        # U5
  saveEndlessState(EndlessState)                  # U6
  setSoundMuted(bool)                             # U3
  setTutorialCompleted(bool)
errors:
  - "một lần ghi lỗi được log và KHÔNG làm hỏng chuỗi hàng đợi cho các lần ghi sau"
  - "key hỏng khi đọc → mặc định cho riêng key đó + log"
write_failure_recovery:   # [review R-03]
  - "Ghi lỗi → key đó được đánh dấu dirty, giá trị đúng vẫn nằm trong cache"
  - "Lần ghi kế tiếp (bất kỳ key nào) sẽ ghi lại các key dirty trước, sau đó mới ghi key mới"
  - "AppLifecycleState.paused → flushDirty(): thử ghi lại mọi key dirty"
  - "Thử lại tối đa 3 lần cho mỗi key dirty. Vẫn lỗi thì giữ dirty trong phiên, log lỗi. Rủi ro còn lại (app bị kill khi vẫn còn key dirty) được chấp nhận"
  - "Không hiện lỗi cho người chơi"
u1_defaults:   # [review R-02]
  highScore: "có từ U1, luôn trả 0 cho tới U2"
  saveHighScore: "có từ U1 (ghi được), U1 chưa gọi"
```

## C6 — GemTheme

```yaml
contract: GemTheme
owner: u4-visual-theme
api:
  forGem(String gemId): GemPalette
GemPalette:
  primary: Color
  secondary: Color
  onPrimary: Color
  buttonFill: Color     # Amethyst dùng #7A4FB0, gem khác = primary
values: "theo design-system-mapping.md (FR12.1)"
transition: "U1 giữ ThemeManager; U3 dùng VictoryColors.accent tạm; U4 thay tất cả và xóa ThemeManager + victory_colors.dart"
```

---

## E1 — Remote Config `level_config` (external, shared schema)

```yaml
# Shared schema: Firebase Remote Config parameter
parameter: level_config
type: JSON (string)
owner: u1-journey-skeleton
versioning: >
  Trường `version` là số nguyên ≥ 1. App chấp nhận mọi version ≥ 1 và BỎ QUA trường không biết. [Q1]
  Thay đổi gây vỡ (đổi tên/cấu trúc) → tạo parameter mới `level_config_v2`. App cũ vẫn đọc `level_config`.
schema:
  version: integer (>=1, required)
  levels:            # object, đúng 6 key gem
    <gemId>:         # rose_quartz | amethyst | blue_topaz | emerald | sapphire | ruby
      order: integer (1..6, required)
      name: string (required)
      sub_levels:    # object, đúng 6 key sub
        <subId>:     # rough_stone | slabbing | shaping | sanding | polishing | bling
          order: integer (1..6, required)
          name: string (required)
          target_score: integer (1..10000000, required)
          background_url: string (optional; https; host firebasestorage.googleapis.com hoặc *.firebasestorage.app)
validation:
  whole_config_rejected_when: [JSON parse lỗi, thiếu/thừa gem hoặc sub, trùng order, target_score ngoài khoảng hoặc không phải số nguyên, version < 1 hoặc thiếu]
  per_level_only_when: [background_url sai → null cho level đó]
  warning_only: [target_score không tăng dần]
fallback: "config mặc định nhúng trong app = JSON trong file requirements (FR3.1), không có background_url"
fetch: { minimumFetchInterval: 12h, timeout: 2s, retry: none }
config_source_signal:   # [review R-05]
  - "LevelConfig.source ∈ {remote, cached, default} được log lúc khởi động (debugPrint)"
  - "U5: thêm user property `config_source` (additive theo E2) để biết trên console có người chơi nào đang dùng `default` do quên dán JSON hay không"
validation_bounds_location: >
  [review R-04] Giới hạn 1..10,000,000 của target_score là HẰNG SỐ TRONG CODE (LevelConfigService.maxTargetScore),
  KHÔNG thuộc schema. Đổi giới hạn chỉ cần sửa code, không cần `level_config_v2`.
  Tương tự với danh sách host ảnh cho phép (LevelConfigService.allowedImageHosts).
example: |
  {"version":1,"levels":{"rose_quartz":{"order":1,"name":"Rose Quartz","sub_levels":{
    "rough_stone":{"order":1,"name":"Rough Stone","target_score":500,
      "background_url":"https://firebasestorage.googleapis.com/v0/b/<bucket>/o/bg%2Frose_quartz%2F1.jpg?alt=media"}, "...": "..."}}, "...": "..."}}
```

## E2 — Analytics event schema (external)

```yaml
# AsyncAPI-style event contract (fire-and-forget to Firebase Analytics)
asyncapi: 2.6.0
info: { title: Gemstone Journey analytics, version: 1.0.0 }
x-owner: u5-analytics
x-versioning: >
  Tên event và tên tham số là CỐ ĐỊNH. Chỉ được THÊM tham số. Muốn đổi nghĩa/tên thì tạo event mới hậu tố _v2. [Q2]
channels:
  level_start:
    publish: { message: { payload: { type: object, properties: {
      major: { type: string, description: gemId },
      sub: { type: string, description: subId },
      level_index: { type: integer, minimum: 1, maximum: 36 } } } } }
  level_complete:
    publish: { message: { payload: { type: object, properties: {
      major: { type: string }, sub: { type: string },
      level_index: { type: integer, minimum: 1, maximum: 36 },
      score: { type: integer }, target: { type: integer } } } } }
  level_fail:
    publish: { message: { payload: { $ref: '#/channels/level_complete/publish/message/payload' } } }
  game_session:
    publish: { message: { payload: { type: object, properties: {
      duration_sec: { type: integer, minimum: 0 } } } } }
x-user-properties:
  current_major_level: { type: string, description: gemId hiện tại }
  highest_level_reached: { type: string, description: "1..36 (Firebase user property là string). Khi phân tích phải ép sang số, vì sắp xếp theo chuỗi sẽ sai ('10' < '9') [review R-06]" }
  config_source: { type: string, enum: [remote, cached, default], description: "nguồn LevelConfig lúc khởi động [review R-05]" }
x-rules:
  - "endless mode KHÔNG gửi level_* (FR9.8)"
  - "offline: SDK tự xếp hàng (FR4.3)"
  - "không gửi dữ liệu cá nhân"
```

## E3 — SharedPreferences (shared schema giữa các phiên bản app)

```yaml
# Shared schema: local key-value store
owner: u1-journey-skeleton
versioning: "KHÔNG có schema version. Mỗi key đọc độc lập; key lạ bỏ qua; key hỏng → mặc định cho key đó + log. [Q3]"
keys:
  progress:            { type: string(JSON), shape: "{currentLevelIndex:int 1..36, completedLevels:[int], unlockedGems:[gemId], journeyCompleted:bool, highestLevelReached:int}", default: "level 1, rỗng, false, 1" }
  high_scores:         { type: string(JSON), shape: "{\"<levelIndex>\": int}", default: "{}" }
  total_play_time:     { type: int, unit: seconds, default: 0 }
  endless_saved_score: { type: int, default: 0 }
  endless_high_score:  { type: int, default: 0 }
  sound_muted:         { type: bool, default: false }
  tutorial_completed:  { type: bool, default: false, note: "giữ key cũ" }
legacy_keys_removed_on_every_start: [high_score, high_score_time, theme_index, last_login_date]   # idempotent
change_rules:
  - "Thêm key mới: an toàn"
  - "Không đổi kiểu/nghĩa của key đã có; nếu cần thì dùng key mới và đọc fallback từ key cũ"
  - "Parser của key JSON (progress, high_scores) BỎ QUA trường lạ, không coi là hỏng [review R-07]"
invariant_scope: >
  [review R-03] `highestLevelReached` không giảm TRONG PHIÊN và qua các lần ghi thành công.
  Nếu key `progress` hỏng thì về mặc định (= 1). Đây là ngoại lệ đã chấp nhận.
accepted_risks:
  - "Hạ cấp app (cài bản cũ hơn): bản cũ có thể không hiểu key mới. Vì parser bỏ qua trường lạ, dữ liệu cũ vẫn dùng được. Người chơi hạ cấp có thể mất tính năng mới. Chấp nhận ở quy mô dự án cá nhân [review R-07]"
```

---

## Contract ownership rules

- Mỗi contract có **một unit sở hữu** (cột Owner). Unit tiêu thụ không sửa contract, chỉ đề xuất thay đổi.
- Contract nội bộ (C1–C6) nằm trong cùng một codebase. Thay đổi gây vỡ được phép **trong cùng lần sửa**, với điều kiện cập nhật mọi nơi gọi và để `flutter analyze` sạch. Không có git nên không dùng nhánh để tách thay đổi.
- Các mở rộng đã lên kế hoạch (U2 thêm trường cho `JourneyOutcome`, thêm `onLevelLost`, `bestScore`, `lost`) chỉ **thêm**, không đổi các trường của U1.
- Contract với bên ngoài (E1–E3) **chỉ được thêm**:
  - Consumer bỏ qua trường lạ.
  - Muốn đổi gây vỡ thì dùng key/event mới (`_v2`) và giữ bản cũ cho các bản app cũ. [Q1] [Q2] [Q3]

## Open questions

| Contract | Question | Blocks |
|----------|----------|--------|
| E1 | Giới hạn trên 10,000,000 của target_score là hằng số trong code, không thuộc schema, nên đổi sau không cần `_v2`. Người dùng vẫn nên xác nhận giá trị | Không chặn (R-04) |
| E1 | Đường dẫn ảnh trên Storage (đề xuất `bg/<gemId>/<subOrder>.jpg`) và public-read cho thư mục `bg/`. Người dùng chốt trước khi upload ảnh ở U4 | U4 |
| E2 | `game_session` có thể trùng với session tự động của Firebase. Giữ theo FR4 và chốt tên trước khi phát hành U5 | U5 (trước phát hành) |

## Assumptions & Open Questions

- [assumption] Người dùng dán JSON mặc định (do code cung cấp) lên Remote Config ở bước chuẩn bị của U1. Nếu quên, log và user property `config_source = default` sẽ cho thấy điều đó.
- Bản này đã sửa theo `reviews/review-01.md` (R-01..R-07).
