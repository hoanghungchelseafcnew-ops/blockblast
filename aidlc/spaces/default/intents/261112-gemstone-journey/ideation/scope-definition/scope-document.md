# Scope Document — Gemstone Journey

## Sources

- [intent] `ideation/intent-capture/intent-statement.md`
- [feas] `ideation/feasibility/feasibility-assessment.md`, `constraint-register.md`, `raid-log.md`
- [req] File requirements (DocumentKB `01a1cee8-d5e3-778f-8ca4-4bc99c076955`), FR-01 đến FR-08, NFR-01 đến NFR-06. Nội dung này được đưa vào scope qua [Q1]
- [Q1]–[Q7] `scope-definition-questions.md`

## Mục tiêu đợt này

Nâng cấp game Block Puzzle hiện tại thành hành trình 36 level (6 đá quý × 6 công đoạn chế tác). Mục đích là cho người chơi casual một mục tiêu rõ ràng, qua đó tăng session time và retention. [intent] [Q1]

## In Scope

| ID | Hạng mục | Mô tả ngắn | Nguồn |
|----|----------|-----------|-------|
| S-01 | Classic mode only | Giữ gameplay hiện tại, ẩn chế độ chơi theo thời gian | [req FR-01] [Q1] |
| S-02 | Hệ thống điểm theo level | 36 mốc điểm. Thắng thì sang level tiếp theo. Thua thì về level con đầu tiên (Rough Stone) của level lớn hiện tại | [req FR-02] [Q1] |
| S-03 | Remote Config | Mốc điểm dạng JSON, fetch khi khởi động, có fallback mặc định trong app | [req FR-03] [Q1] |
| S-04 | Analytics | Các event `level_start`, `level_complete`, `level_fail`, `game_session` và user property | [req FR-04] [Q1] |
| S-05 | Ảnh nền 36 level | Ưu tiên Firebase Storage (URL trong Remote Config), dự phòng bằng assets. Ảnh bị blur khi đang chơi | [req FR-05] [Q2] |
| S-06 | Màn hình Victory | Confetti, glow, âm thanh, nút Continue. Khi xong level lớn có animation unlock đá quý **2D** | [req FR-06] [Q3] |
| S-07 | Giao diện chọn level | Màn hình chọn level lớn (journey) và level con, có trạng thái Locked/Unlocked/Completed | [req FR-07] [Q1] |
| S-08 | Lưu tiến trình | Lưu cục bộ bằng `shared_preferences` | [req FR-08] [feas] [Q5] |
| S-09 | Đổi package | Android: `com.h2.game.block_blast`. iOS: `com.h2.game.blockBlast` | [req NFR-03] [Q4] |
| S-10 | Hỗ trợ offline | Chơi được khi không có mạng. Khi có mạng lại thì gửi analytics và fetch lại Remote Config | [req NFR-06] [Q5] |
| S-11 | Asset | Tái sử dụng âm thanh có sẵn. Thêm `victory` và `unlock`. Được dùng placeholder | [req NFR-02] [Q7] |
| S-12 | Ràng buộc kỹ thuật | Tái sử dụng kiến trúc và Provider, hạn chế dependency, 60 FPS trên thiết bị tầm trung | [req NFR-01, NFR-04, NFR-05] [Q1] |

## Out of Scope

| Hạng mục | Lý do | Nguồn |
|----------|-------|-------|
| Quảng cáo (AdMob) và in-app purchase | Để intent sau | [Q1] |
| Viên đá quý 3D xoay | Thay bằng animation 2D trong đợt này | [Q3] |
| Đồng bộ tiến trình lên cloud | Tiến trình chỉ lưu cục bộ | [Q5] [feas] |
| Phát hành tại EU | Ràng buộc quy định C-R1 | [feas] |

## Ràng buộc kế thừa

Không có ngân sách (chỉ dùng gói miễn phí), không có deadline cứng, chỉ có một developer, không phát hành ở EU, đối tượng 13+. [feas]

## Tiêu chí hoàn thành (theo file requirements)

- **AC-01:** chơi được qua 36 level theo thứ tự, mốc điểm lấy đúng từ Remote Config, thua thì quay về đúng level. [req] [Q1]
- **AC-02:** màn hình Victory hiển thị ảnh nền rõ nét, có confetti và animation, có âm thanh. [req] [Q1]
- **AC-03:** Remote Config fetch được, Analytics ghi đúng event, fallback hoạt động khi offline. [req] [Q1]
- **AC-04:** app build thành công với package mới. [req] [Q4]

## Assumptions & Open Questions

- [assumption] Quy tắc khi thua được hiểu là quay về Rough Stone của level lớn đang chơi, theo ví dụ trong file requirements ("Amethyst > Shaping thua → Amethyst > Rough Stone"). Câu chữ "level lớn gần nhất đã hoàn thành" trong file requirements có thể đọc theo nghĩa khác, cần xác nhận lại ở bước Requirements Analysis.
- [assumption] Với quy mô dự kiến, Firebase Storage (gói miễn phí) có thể vượt hạn mức băng thông. Cần kiểm tra lại khi làm NFR Design.
