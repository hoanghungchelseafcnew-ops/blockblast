# Units Generation Questions — Gemstone Journey

Bối cảnh:
- Cả dự án là **một app Flutter duy nhất**, deploy bằng cách build rồi upload lên store thủ công.
- Domain Design có 17 component.
- Practices quy định **luôn làm walking skeleton trước**. Unit đầu tiên vì thế phải là một bản chạy được từ đầu đến cuối.
- Mỗi Unit là một nhóm tính năng được thiết kế và sinh code cùng nhau ở giai đoạn Construction.

## Đề xuất chia unit (theo tính năng)

| ID | Unit | Gồm | Kind |
|----|------|-----|------|
| U1 | `u1-journey-skeleton` | Đổi package Android/iOS, setup Firebase core và Remote Config (`LevelConfigService`, `LevelCatalog`, `AppBootstrap`), `ProgressRepository` cơ bản, `JourneyController` (thắng thì sang level kế), `BoardEngine`/`TurnResolver`, `LevelGameController` cơ bản, gỡ Time Attack, Home có nút PLAY, header có target và %, Victory tối giản (chỉ CONTINUE) | service |
| U2 | `u2-level-rules` | Đủ quy tắc FR2: thua thì reset về Rough Stone, mở khóa đá quý, Journey Complete, high score, ghi tuần tự, QuitDialog, Game Over mới (bỏ REVIVE) | service |
| U3 | `u3-victory-audio` | VictoryUI đầy đủ (sub, gemUnlock, journeyComplete), confetti, glow, animation 2D, âm thanh victory/unlock, mute được lưu, stopSfx | ui |
| U4 | `u4-visual-theme` | `GemTheme` (gỡ ThemeManager), `BackgroundImageService` và LevelBackground (asset, URL, cross-fade), font đóng gói, Splash, Home theo mockup, bỏ Daily Gift, khóa portrait | ui |
| U5 | `u5-analytics` | `AnalyticsService` (Firebase và fake), `SessionTracker`, event level và user property | service |
| U6 | `u6-endless-mode` | `EndlessGameController`, UI endless (header, quit, game over), Home "Journey Complete" | service |

US8.5 (coverage 80%) và US8.6 (a11y, hiệu năng) là tiêu chí xuyên suốt, áp dụng cho mọi unit.

---

## Q1. Cách chia unit như bảng trên có phù hợp không?

A. Đồng ý chia 6 unit như trên
B. Gộp thành 4 unit (U1 skeleton; U2+U6 rules và endless; U3+U4 giao diện; U5 analytics)
C. Chia nhỏ hơn (tách đổi package/Firebase thành unit riêng)
X. Other (please specify)

[Answer]:A

---

## Q2. Walking skeleton (U1) có bao gồm Firebase Remote Config thật không?

A. Có. Skeleton chứng minh luôn đường tích hợp rủi ro nhất: đổi package, Firebase project, fetch Remote Config, fallback. Bạn cần tạo Firebase project và đặt `google-services.json` / `GoogleService-Info.plist` trước khi chạy U1
B. Không. Skeleton chỉ dùng config mặc định trong app, Firebase để sang unit sau (skeleton nhỏ hơn, chạy được ngay không cần Firebase)
X. Other (please specify)

[Answer]:A

---

## Q3. Các unit sau skeleton có được làm song song không?

A. Có. Những unit không phụ thuộc nhau (ví dụ U3, U4, U5 sau U1) có thể làm theo bất kỳ thứ tự nào. Thứ tự cụ thể chốt ở bước Delivery Planning
B. Không. Làm tuần tự nghiêm ngặt U1 → U2 → U3 → U4 → U5 → U6
X. Other (please specify)

[Answer]:A

---

## Q4. Kind của các unit?

App là một khối deploy duy nhất. "service" ở đây là unit có logic nghiệp vụ và state, "ui" là unit chủ yếu là màn hình và hiệu ứng.

A. Đồng ý kind như bảng (U1, U2, U5, U6 là service; U3, U4 là ui)
B. Tất cả đều là service (một app)
X. Other (please specify)

[Answer]:A

---

Trả lời trong chat được, ví dụ: "1A 2A 3A 4A"

---

## Consolidated Summary Confirmation

Does this all look correct before I generate the artifact?

- Q1: Chia 6 unit theo tính năng (U1 journey-skeleton, U2 level-rules, U3 victory-audio, U4 visual-theme, U5 analytics, U6 endless-mode)
- Q2: Walking skeleton U1 gồm Firebase Remote Config thật. Người dùng tạo Firebase project và đặt file cấu hình trước khi chạy U1
- Q3: Cho phép làm song song các unit không phụ thuộc nhau. Thứ tự cụ thể chốt ở Delivery Planning
- Q4: Kind: U1, U2, U5, U6 là service. U3, U4 là ui

- Looks correct
- Request changes

[Answer]: Looks correct
