# Architecture Decisions — Gemstone Journey

## Sources

- [req] `inception/requirements-analysis/requirements.md`
- [codekb] `aidlc/spaces/default/codekb/block-crush-game-main/architecture.md`
- [prac] `inception/practices-discovery/team-practices.md`
- [Q1]–[Q5] `domain-design-questions.md`
- [review] `reviews/review-01.md` (R-01..R-09)
- `components.md`

## ADR-001: Tách logic ván chơi khỏi `_GameScreenState`

- **Context**: Toàn bộ state, cách tính điểm, timer và lưu trữ hiện nằm trong `_GameScreenState` (395 dòng). Tính năng mới thêm level, thắng/thua, Victory, analytics và endless. Practices bắt buộc tách logic sang controller/service. NFR10 yêu cầu coverage ≥ 80% trên toàn bộ codebase. [codekb] [prac] [req]
- **Decision**: Đưa state và quy tắc ván chơi vào controller `ChangeNotifier` (`LevelGameController`, `EndlessGameController`). Screen (`GameplayUI`, `VictoryUI`) chỉ render và chuyển thao tác kéo-thả. `BoardLogic` và `BlockGenerator` giữ nguyên, được gom vào `BoardEngine` cùng `TurnResolver` mới. [Q1]
- **Consequences**:
  - (+) Unit test được thắng/thua/điểm mà không cần widget.
  - (+) Screen gọn hơn.
  - (−) Refactor lớn ở `game_screen.dart`, dễ phát sinh regression kéo-thả. Cần widget test cho kéo-thả.
- **Alternatives Rejected**: giữ logic trong widget và chỉ thêm controller cho phần level. Bị loại vì vi phạm practices và khó test.

## ADR-002: Hai controller riêng cho level và endless, chung `TurnResolver`

- **Context**: Chế độ level có target, Victory, quy tắc thua reset về Rough Stone và analytics. Chế độ endless không có target, lưu điểm khi tạm dừng, thua thì về 0. Phần xử lý lượt đặt khối giống hệt nhau. [req FR2, FR9]
- **Decision**: Hai controller `LevelGameController` và `EndlessGameController`. `TurnResolver` trong `BoardEngine` là nơi duy nhất tính điểm. [Q2]
- **Consequences**:
  - (+) Mỗi controller đơn giản, không có nhánh `if (mode)` rải rác.
  - (−) Một phần wiring bị lặp (khởi tạo bảng, âm thanh).
- **Alternatives Rejected**: một `GameSessionController` kèm mode policy. Ít code hơn nhưng người dùng chọn tách riêng cho rõ ràng.

## ADR-003: Quy tắc hành trình thuần, tách khỏi lưu trữ và analytics

- **Context**: Quy tắc FR2 là logic nghiệp vụ quan trọng nhất và cần test kỹ. Review R-04 chỉ ra `JourneyController` phụ thuộc analytics, nên không còn thuần. [req FR2, FR8] [review]
- **Decision**:
  - `JourneyController` chỉ phụ thuộc `LevelCatalog` và `ProgressRepository`. `onLevelWon` và `onLevelLost` trả về `Future<JourneyOutcome>`.
  - `LevelGameController` dùng `JourneyOutcome` để tự gửi event và user property. Như vậy toàn bộ analytics của ván level nằm ở một nơi.
  - `ProgressRepository` chỉ đọc/ghi. [Q3]
- **Consequences**:
  - (+) Test quy tắc bằng repository giả lập trong bộ nhớ, không cần fake analytics.
  - (+) Không lệch bộ thuộc tính analytics giữa hai nơi.
  - (−) Thêm kiểu `JourneyOutcome`.
- **Alternatives Rejected**: gộp vào `ProgressService` (trộn I/O với quy tắc). Để `JourneyController` gọi analytics (không thuần, hai nơi cùng sở hữu analytics).

## ADR-004: Giao tiếp trực tiếp qua `provider` và constructor injection

- **Context**: App nhỏ, một developer. Cần mock Firebase và prefs trong test. Hiện chỉ dùng `provider`. [codekb] [req NFR1, NFR4]
- **Decision**: Component gọi trực tiếp nhau. Dependency được truyền qua constructor, wiring ở `main.dart` bằng `MultiProvider`. `AppBootstrap` gom thứ tự khởi tạo, nên UI không gọi thẳng `LevelConfigService`. Không dùng event bus hay thư viện DI mới. [Q4] [review R-03]
- **Consequences**:
  - (+) Không thêm dependency.
  - (+) Luồng gọi dễ đọc.
  - (−) `LevelGameController` phụ thuộc 6 component. Chấp nhận được ở quy mô này.
- **Alternatives Rejected**: event bus/stream, vì khó truy vết. get_it/riverpod, vì vi phạm NFR4.

## ADR-005: Seam test cho mọi phụ thuộc bên ngoài

- **Context**: AI không chạy được test và Firebase không có trong môi trường test. Coverage ≥ 80% trên toàn bộ codebase là mức sàn không được hạ. Review R-09 chỉ ra còn thiếu seam cho Remote Config, đồng hồ, prefs và tải ảnh. [prac] [req NFR10] [review]
- **Decision**: Có seam inject được cho từng phụ thuộc:
  - `AnalyticsService` (abstract): Firebase impl và fake.
  - `RemoteConfigClient` (abstract): Firebase impl và fake. `LevelConfigService` chứa toàn bộ logic validate và fallback, test qua fake.
  - `Clock` (abstract) cho `SessionTracker` và timeout của bootstrap.
  - `SharedPreferences.setMockInitialValues` cho `ProgressRepository`.
  - `ImageLoader` cho `BackgroundImageService`.
  - Player inject được cho `AudioController`.
  - `Random` inject được cho `BlockGenerator`.
  - Các lớp Firebase impl được giữ mỏng, chỉ chuyển tiếp lời gọi. Chúng **không** bị loại khỏi phép đo coverage (không hạ mức sàn). Phần chưa được test sẽ ghi rõ ở Build & Test.
- **Consequences**:
  - (+) Hầu hết logic test được không cần thiết bị hay Firebase.
  - (−) Thêm vài interface nhỏ.
  - (−) Nếu coverage thật thấp hơn 80% vì widget hoặc impl mỏng, cần bổ sung widget test. Không được nới ngưỡng.
- **Alternatives Rejected**: gọi Firebase trực tiếp từ controller (không test được). Đánh dấu `coverage:ignore` cho adapter (bị loại vì làm yếu mức sàn đã cam kết).

## ADR-006: Ảnh nền qua URL công khai đã validate và `cached_network_image`, không dùng `firebase_storage` SDK

- **Context**: NFR4 chỉ cho thêm `firebase_core`, `firebase_remote_config`, `firebase_analytics` và `cached_network_image`. FR5 cần ảnh từ Firebase Storage kèm fallback. URL đến từ Remote Config nên là dữ liệu không tin cậy (R-05). [req] [review]
- **Decision**:
  - Remote Config chứa download URL công khai.
  - `LevelConfigService` chỉ nhận URL `https` với host `firebasestorage.googleapis.com` hoặc `*.firebasestorage.app`. URL sai thì đặt `backgroundUrl = null` cho riêng level đó (giữ asset), không loại cả config.
  - `BackgroundImageService` hiện asset ngay, cross-fade 300ms khi ảnh mạng sẵn sàng.
  - Bucket chỉ cho đọc công khai thư mục ảnh và không cho ghi.
- **Consequences**:
  - (+) Không thêm SDK.
  - (+) Offline vẫn có ảnh.
  - (+) URL lạ không được tải.
  - (−) Đổi host (ví dụ dùng CDN riêng) phải sửa allowlist và phát hành bản mới.
  - (−) Băng thông của gói miễn phí là rủi ro đã được chấp nhận.
- **Alternatives Rejected**: `firebase_storage` SDK (vi phạm NFR4). Chỉ dùng asset (vi phạm FR5.2). Không validate URL (rủi ro bảo mật).

## ADR-007: Thay `ThemeManager` bằng `GemTheme` tĩnh

- **Context**: Người dùng chọn bỏ chọn theme (FR12.2). Màu theo đá quý lấy theo bảng 5.1. Chữ trắng trên nút Amethyst chỉ đạt 4.1:1. [req] [refined-mockups review]
- **Decision**: `GemTheme` là bảng tĩnh, gem hiện tại lấy từ `JourneyController`. Nút Amethyst dùng `#7A4FB0` (5.9:1), nền vẫn dùng `#9966CC`. Gỡ `ThemeManager`, `AppThemeType` và `theme_index`.
- **Consequences**:
  - (+) Ít state hơn.
  - (+) Đạt WCAG AA.
  - (−) `BoardCell` và `DraggableBlock` đang `watch<ThemeManager>` phải sửa.
- **Alternatives Rejected**: giữ ThemeManager và thêm gem theme chồng lên (phức tạp, mâu thuẫn FR12.2).

## ADR-008: Lưu trước khi hiện Victory, và chống xử lý thắng/thua hai lần

- **Context**: US1.6 yêu cầu tiến trình được ghi trước khi hiện Victory. Một lượt đặt khối có thể vừa đạt mốc vừa hết nước đi. Review R-01. [stories] [review]
- **Decision**:
  - `LevelGameController` có trạng thái `playing → resolving → won|lost`. Khi vào `resolving`, input bị khóa và mọi sự kiện thắng/thua tiếp theo bị bỏ qua.
  - Controller `await` `JourneyController.onLevelWon` hoặc `onLevelLost`. Hai hàm này chỉ hoàn tất sau khi repository ghi xong. Chỉ sau đó mới chuyển sang `won` hoặc `lost` và notify UI.
  - **Thắng được ưu tiên hơn hết nước đi** trong cùng một lượt.
- **Consequences**:
  - (+) Kill app ở Victory không mất tiến trình.
  - (+) Không mở khóa hay ghi hai lần.
  - (−) Có độ trễ nhỏ (thời gian ghi prefs, thường vài ms) trước khi Victory hiện.
- **Alternatives Rejected**: hiện Victory rồi lưu song song (có thể mất tiến trình). Lưu ở `dispose` (không đảm bảo).

## ADR-009: `ProgressRepository` là bộ ghi duy nhất, ghi tuần tự theo từng key

- **Context**: `JourneyController`, `EndlessGameController`, `SessionTracker` và `AudioController` đều ghi dữ liệu, có thể đồng thời (ví dụ `paused` và `QUIT`). Ghi kiểu đọc-sửa-ghi trên một blob có thể ghi đè dữ liệu của nhau. Review R-02. [review]
- **Decision**:
  - Repository giữ cache trong bộ nhớ, nạp một lần lúc bootstrap.
  - Mọi lần ghi đi qua một hàng đợi tuần tự (Future chain).
  - Mỗi phần dữ liệu có key riêng: `progress`, `high_scores`, `total_play_time`, `endless_saved_score`, `endless_high_score`, `sound_muted`, `tutorial_completed`.
  - API cập nhật từng phần, mỗi hàm trả về Future hoàn tất khi đã ghi đĩa.
- **Consequences**:
  - (+) Không mất `completedLevels` do ghi chồng.
  - (+) Test được thứ tự ghi.
  - (−) Nhiều key hơn. Cần migration nhẹ (gỡ các key cũ).
- **Alternatives Rejected**: một blob JSON duy nhất (dễ ghi đè). Để mỗi component tự gọi SharedPreferences (không tuần tự hóa được).

## ADR-010: Cấu hình level bất biến trong phiên

- **Context**: Splash chỉ chờ Remote Config tối đa 2 giây. Config có thể activate muộn và làm mốc điểm thay đổi giữa ván. Review R-03, R-06. [review]
- **Decision**:
  - `AppBootstrap` dựng `LevelCatalog` một lần sau splash. Catalog không đổi trong suốt phiên. Config activate muộn chỉ có hiệu lực ở lần mở app sau.
  - `LevelRound` chốt `targetScore` lúc bắt đầu ván.
  - Validate config: đủ đúng 36 cặp gem/sub, không trùng, target là số nguyên 1..10,000,000. Target không tăng dần chỉ log cảnh báo.
- **Consequences**:
  - (+) Mốc điểm không nhảy giữa chừng.
  - (+) Config sai không làm hỏng điều hướng level.
  - (−) Thay đổi trên Remote Config cần một lần mở app mới có hiệu lực, ngoài khoảng fetch 12 giờ.
- **Alternatives Rejected**: cập nhật catalog trực tiếp khi config đổi (gây nhảy mốc điểm). Bắt buộc target tăng dần (chặt hơn requirements, có thể chặn cấu hình hợp lệ).
