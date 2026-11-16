# Performance Design — U1 `u1-journey-skeleton`

## Sources

- [nfr] `nfr-requirements/performance-requirements.md` (NFR5.1–NFR5.5)
- [fd] `functional-design/rules.md` (BR5.1, BR5.3, BR5.10)
- [Q1] `nfr-design-questions.md`

## D-P1 — Lượt chơi đồng bộ, không I/O (NFR5.1, NFR5.4)

- `TurnResolver.resolve(board, block, row, col, combo) → TurnResult` là hàm thuần, duyệt bảng 8×8 (O(64)) như `BoardLogic` hiện có.
- `LevelGameController` chỉ gọi `notifyListeners()` **một lần mỗi lượt**, sau khi đã tính xong điểm, %, trạng thái thắng.
- Preview khi kéo: giữ cách làm hiện tại (`setState` trên board). Tách `RepaintBoundary` riêng cho header để việc cập nhật điểm không vẽ lại board.

## D-P2 — Cấu hình mặc định là hằng số (NFR5.2, Q1)

`DefaultLevelConfig.json` là `const String` trong Dart, parse một lần lúc khởi động. Không đọc file, không có độ trễ I/O, và luôn có sẵn kể cả khi asset bị hỏng.

## D-P3 — Ngân sách khởi động (NFR5.2)

| Bước | Ngân sách |
|------|-----------|
| `Firebase.initializeApp` | ≤ 1500ms (D-R1) |
| `fetchAndActivate` | ≤ min(2000ms, phần còn lại − 500ms) (D-R2) |
| Validate và dựng catalog | thường < 5ms (36 phần tử) |
| Đọc SharedPreferences | không tính (thường < 50ms) |
| **Tổng phần Firebase** | **≤ 3500ms** |

## D-P4 — Thắng nhanh (NFR5.3)

Animation xóa dòng (180ms) và việc ghi prefs chạy song song (D-R7). Thời gian từ đạt mốc đến Victory ≈ max(180ms, thời gian ghi), giới hạn trên là 3s.

## D-P5 — Không rò rỉ (NFR5.5)

- Mỗi ván tạo `LevelGameController` mới qua `ChangeNotifierProvider` gắn với route Game. Rời route thì `dispose()` tự chạy.
- Gỡ toàn bộ `Timer` của Time Attack. Không còn `Timer.periodic`.
- Timer 3s của D-R7 dùng `Future.delayed` và không giữ tham chiếu sau khi xong.

## Assumptions & Open Questions

None.
