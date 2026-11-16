# Logical Components — U1 `u1-journey-skeleton`

## Sources

- [comp] `inception/domain-design/components.md`
- [nfr] `construction/u1-journey-skeleton/nfr-requirements/*.md`
- [fd] `construction/u1-journey-skeleton/functional-design/functional-spec.md`
- [Q1] [Q2] `nfr-design-questions.md`

U1 là một tiến trình app Flutter duy nhất, không có backend. "Failure domain" ở đây là các ranh giới mà lỗi phải bị chặn lại, không được lan ra ngoài.

| Component logic | Vai trò NFR | Failure domain | Blast radius khi lỗi | Cô lập bằng |
|-----------------|-------------|----------------|----------------------|-------------|
| `FirebaseGateway` (bọc `Firebase.initializeApp`) | Timeout 1,5s, bắt mọi lỗi | SDK Firebase / native | Chỉ mất cấu hình remote, dùng default | `Future.timeout` + `catch (Object)` (D-R1) |
| `RemoteConfigClient` (interface) + `FirebaseRemoteConfigClient` | Fetch có giới hạn thời gian | Mạng / SDK RC | Dùng cached/default | Timeout theo ngân sách còn lại (D-R2) |
| `LevelConfigService` + `LevelConfigValidator` | Validate đầu vào không tin cậy | Dữ liệu JSON | Một URL hỏng → chỉ level đó; JSON hỏng → default | Hàm thuần, không throw (D-S1, D-S2) |
| `DefaultLevelConfig` (hằng số Dart, Q1) | Nguồn dự phòng luôn sẵn có | — | — | `const`, không I/O (D-P2) |
| `LevelCatalog` | Bất biến trong phiên | — | — | Dựng một lần, `List.unmodifiable` |
| `AppBootstrap` | Hạn chót 3,5s cho phần Firebase | Điều phối | Không bao giờ treo Splash (trừ đọc prefs) | `Stopwatch` + deadline (D-R3) |
| `ProgressRepository` | Hàng đợi ghi, dirty, chỉ-đọc | Đĩa / SharedPreferences | Ghi lỗi → giữ cache; đọc lỗi → chỉ-đọc | Future chain FIFO, cổng `loaded` (D-R4, D-R5) |
| `JourneyController` | Lưu trước Victory | Logic thuần + repo | — | Không throw (D-R6) |
| `TurnResolver` / `BoardEngine` | Hiệu năng lượt chơi | Logic thuần | — | Đồng bộ, O(64) (D-P1) |
| `LevelGameController` | Resolving tối đa 3s | Vòng đời ván | Kẹt resolving → hết hạn → won | `Future.any` với timer 3s (D-R7) |
| `GjLog` | Log thống nhất | — | — | Một điểm vào duy nhất (D-O1) |
| UI (Splash/Home/Game/Victory tạm) | 48dp, tiếng Anh | Widget | — | Chỉ render |

## Shared resources

- **SharedPreferences**: chỉ `ProgressRepository` đọc/ghi (bộ ghi duy nhất, ADR-009).
- **Firebase app instance**: chỉ `FirebaseGateway` khởi tạo. `FirebaseRemoteConfigClient` chỉ dùng sau khi gateway báo `ok`.

## Assumptions & Open Questions

None.
