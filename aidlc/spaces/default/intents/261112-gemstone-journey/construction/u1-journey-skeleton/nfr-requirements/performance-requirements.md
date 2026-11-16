# Performance Requirements — U1 `u1-journey-skeleton`

## Sources

- [req] `inception/requirements-analysis/requirements.md` NFR5
- [fd] `construction/u1-journey-skeleton/functional-design/rules.md` (BR1.1, BR1.5, BR1.8, BR5.3, BR5.9, BR5.10)
- [Q1] `nfr-requirements-questions.md`

| ID | Yêu cầu | Mục tiêu đo được | Cách kiểm |
|----|---------|------------------|-----------|
| NFR5.1 | Kéo-thả khối sau khi tách `_GameScreenState` vẫn mượt như trước | Profile mode trên thiết bị tầm trung: không có chuỗi > 3 frame liên tiếp vượt 16ms khi kéo khối | Người dùng chạy `flutter run --profile` và xem DevTools |
| NFR5.2 | Khởi động đến Home bị chặn trên ở phần Firebase | `Firebase.initializeApp` ≤ 1,5s. fetchAndActivate ≤ 2s. Tổng phần Firebase ≤ 3,5s (BR1.8). **Thời gian đọc SharedPreferences không tính vào mức 3,5s** và không có timeout (Q1). Thông thường dưới 50ms | Unit test `AppBootstrap` với fake chậm. Người dùng đo cold start khi online, offline, và khi thiếu file cấu hình |
| NFR5.3 | Trạng thái resolving không kéo dài | Thắng → Victory ≤ 3s trong mọi trường hợp (BR5.9). Thông thường ≤ 200ms (180ms animation + ghi prefs) | Unit test với repository giả treo |
| NFR5.4 | Tính điểm và kiểm tra thắng không làm rớt frame | `TurnResolver` chạy đồng bộ, O(64) ô cho mỗi lượt. Không I/O trên luồng UI ngoài `await` ghi prefs | Review code và unit test |
| NFR5.5 | Không có rò rỉ khi chơi nhiều level liên tiếp | Mỗi `LevelRound` mới giải phóng controller và timer của round cũ. Không còn `Timer` của Time Attack | Review code (`dispose`) |

## Assumptions & Open Questions

- [assumption] Đọc SharedPreferences không có timeout (Q1). Rủi ro treo khi đọc dữ liệu cục bộ được chấp nhận vì rất thấp. Lựa chọn này cũng xử lý được góp ý R-12 (không ghi mặc định đè dữ liệu thật).
