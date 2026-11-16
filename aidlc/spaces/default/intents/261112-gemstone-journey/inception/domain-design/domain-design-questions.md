# Domain Design Questions — Gemstone Journey

Bối cảnh:
- Codebase hiện tại dồn toàn bộ logic vào `_GameScreenState`.
- Practices bắt buộc tách logic sang controller/service (ChangeNotifier qua `provider`).
- Requirements thêm Remote Config, Analytics, lưu tiến trình, ảnh nền, endless và màu đá quý.

Dưới đây là cách chia component tôi đề xuất (sẽ chốt sau khi bạn trả lời):

| Component | Trách nhiệm |
|-----------|-------------|
| `LevelCatalog` | Danh sách 36 level, thứ tự, mốc điểm (từ config) |
| `LevelConfigService` | Fetch, validate và fallback Remote Config (mốc điểm và URL ảnh) |
| `ProgressRepository` | Đọc/ghi SharedPreferences: tiến trình, high score, endless, mute |
| `JourneyController` | Quy tắc hành trình: level hiện tại, thắng sang level kế, thua reset Rough Stone, mở khóa, journey complete |
| `GameSessionController` | State của một ván: board, khay khối, điểm, combo, phát hiện thắng/thua (tách từ `_GameScreenState`) |
| `EndlessController` | Lưu và khôi phục điểm endless, reset khi thua |
| `AnalyticsService` | Bọc Firebase Analytics |
| `BackgroundImageService` | Chọn ảnh (URL hoặc asset), cache, precache |
| `GemTheme` | Màu theo đá quý (thay `ThemeManager`) |
| `AudioController` | Giữ lại, thêm mute được lưu, victory/unlock, stopSfx |
| UI: Home, Game, Victory, Splash | Chỉ render |

---

## Q1. Logic một ván chơi nên tách thế nào?

A. Tách `GameSessionController` (ChangeNotifier) ra khỏi `_GameScreenState`. Screen chỉ render. `BoardLogic` và `BlockGenerator` giữ nguyên là logic thuần
B. Giữ logic trong `_GameScreenState`, chỉ thêm logic level vào controller mới
X. Other (please specify)

[Answer]:A

---

## Q2. Chế độ level và endless dùng chung một controller ván chơi không?

A. Dùng chung `GameSessionController`, chỉ khác "mode policy" (`LevelModePolicy` có target/Victory, `EndlessModePolicy` lưu điểm). Ít code trùng nhất
B. Hai controller riêng (`LevelGameController`, `EndlessGameController`)
X. Other (please specify)

[Answer]:B

---

## Q3. Quy tắc hành trình (`JourneyController`) và lưu trữ (`ProgressRepository`) tách riêng hay gộp?

A. Tách: `JourneyController` là logic thuần, test được không cần prefs. `ProgressRepository` chỉ đọc/ghi
B. Gộp vào một `ProgressService`
X. Other (please specify)

[Answer]:A

---

## Q4. Các thành phần giao tiếp với nhau thế nào?

A. Gọi trực tiếp qua `provider`. Controller nhận service qua constructor (dependency injection) để mock được trong test. Không dùng event bus
B. Dùng event bus hoặc stream cho các sự kiện như thắng/thua (Analytics và Audio lắng nghe)
X. Other (please specify)

[Answer]:A

---

## Q5. Thư mục mã nguồn cho các component mới?

A. Theo cấu trúc đề xuất trong file requirements: `lib/core/firebase/` (config, analytics), `lib/features/game/{controllers,models}` (session, level, progress), `lib/features/victory/`. Thêm `lib/core/services/` cho progress và background
B. Gom tất cả service vào `lib/core/services/`, controller vào `lib/features/<feature>/controllers/`
X. Other (please specify)

[Answer]:A

---

Trả lời trong chat được, ví dụ: "1A 2A 3A 4A 5A"

---

## Consolidated Summary Confirmation

Does this all look correct before I generate the artifact?

- Q1: Tách logic ván chơi khỏi `_GameScreenState` sang controller. Screen chỉ render. `BoardLogic` và `BlockGenerator` giữ nguyên là logic thuần
- Q2: Hai controller riêng: `LevelGameController` và `EndlessGameController`
- Q3: Tách `JourneyController` (logic thuần) và `ProgressRepository` (chỉ đọc/ghi)
- Q4: Gọi trực tiếp qua `provider`, inject service qua constructor để mock được trong test. Không dùng event bus
- Q5: Thư mục theo cấu trúc đề xuất trong file requirements: `lib/core/firebase/`, `lib/core/services/`, `lib/features/game/{controllers,models}`, `lib/features/victory/`

- Looks correct
- Request changes

[Answer]: Looks correct
