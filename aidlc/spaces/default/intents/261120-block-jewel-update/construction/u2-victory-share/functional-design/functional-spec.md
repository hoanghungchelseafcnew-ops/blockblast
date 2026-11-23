# Functional Spec: u2-victory-share

Nguồn: unit-of-work.md (U2), unit-of-work-story-map.md, requirements.md (FR3, FR2.4), components.md (ScoreShareService, VictoryOverlay, GameScreen). Unit giao diện (ui): spec này tự chứa luồng tương tác.

## Quy tắc (rules)
| ID | Quy tắc | Nguồn |
|---|---|---|
| BR1.1 | Màn Victory hiện nút SHARE ở cả 3 biến thể `sub`, `gemUnlock`, `journeyComplete` | FR3.1 |
| BR1.2 | Bấm SHARE chụp toàn bộ màn hình hiện tại (Scaffold của GameScreen, gồm nền, bảng và overlay) qua `ScreenshotController` hiện có, rồi mở khung chia sẻ hệ điều hành kèm ảnh | FR3.2 |
| BR1.3 | Văn bản kèm: `I cleared <Level.displayName> with <score> points in Block Jewel!` | FR3.3 |
| BR1.4 | Lỗi chụp hoặc chia sẻ ghi `GjLog.error('Game', ...)` và không ném ra ngoài; Victory vẫn dùng được | FR3.4 |
| BR1.5 | SHARE không khóa CONTINUE/BACK TO MENU; bấm SHARE không đánh dấu `_leaving`; trong lúc đang chia sẻ, bấm SHARE thêm lần nữa bị bỏ qua | FR3.4 |
| BR1.6 | Game Over vẫn dùng `shareScore`; văn bản đổi thành `I scored <score> in Block Jewel!` | FR3.5, FR2.4 |
| BR1.7 | Ảnh chỉ ghi vào thư mục tạm và chỉ gửi khi người chơi bấm SHARE | NFR6 |

## Luồng
1. Thắng level → `LevelGameController.status == won` → GameScreen hiện `VictoryOverlay(onShare: ...)`.
2. Người chơi bấm SHARE → `VictoryOverlay` gọi `onShare` (một lần mỗi lần bấm khi không đang chia sẻ).
3. GameScreen gọi `shareService.shareVictory(screenshot, levelName: level.displayName, score)`.
4. Service: `capture()` → nếu null thì dừng, ghi log; ghi `victory.png` vào thư mục tạm → `Share.shareXFiles`.
5. Người chơi quay lại game, Victory vẫn hiện; CONTINUE/BACK TO MENU hoạt động như cũ.

## Trạng thái nút SHARE
`idle` → (bấm) → `sharing` → (Future kết thúc, thành công hay lỗi) → `idle`. Ở `sharing` nút bị vô hiệu.
