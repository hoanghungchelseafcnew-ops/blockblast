# Security Design: u2-victory-share

Nguồn: security-requirements.md, tech-stack-decisions.md (unit này).

| ID | Thiết kế |
|---|---|
| NFR6.1 | `getTemporaryDirectory()` + tên cố định `victory.png` (Game Over dùng `score.png`), ghi đè |
| NFR6.2 | Chỉ `VictoryOverlay` gọi `onShare` khi người chơi bấm; không có lời gọi tự động |
| NFR4.1 | Chuỗi tạo bởi hàm tĩnh `victoryShareText`/`scoreShareText`, tiếng Anh, có unit test |
| NFR7.1 | Không thêm gói hay quyền |
| NFR3.1 | Fake `ScoreShareService` ghi lại lời gọi để widget test |
| NFR5.1 | `flutter analyze` và `dart format` trong lệnh kiểm tra |
| NFR5.2 | Dùng lại gói đã có |

Lỗi ở ranh giới I/O (chụp, ghi file, mở share sheet) được bắt trong service và ghi `GjLog.error`; không ném lên UI.
