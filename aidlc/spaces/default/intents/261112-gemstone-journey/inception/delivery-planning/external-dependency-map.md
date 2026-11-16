# External Dependency Map — Gemstone Journey

## Sources

- `bolt-plan.md`, [contract] `inception/contract-design/contract-summary.md` (E1–E3, open questions)
- [units] `unit-of-work.md` (checklist tiền điều kiện của U1)
- [feas] `ideation/feasibility/raid-log.md` (D1–D4)

Không có team hay API bên thứ ba nào khác. Mọi phụ thuộc bên ngoài đều do **Developer/Owner** thực hiện.

| # | Hạng mục | Chủ sở hữu | Thời gian ước tính | Chặn Bolt | Nếu trễ |
|---|----------|-----------|-------------------|-----------|---------|
| X1 | Zip sao lưu thư mục dự án | Developer/Owner | 5 phút | B1 (bước 1 và 2) | Không bắt đầu B1. Không có git nên đây là cách quay lại duy nhất |
| X2 | Tạo Firebase project (Spark) và thêm app Android `com.h2.game.block_blast`, tải `google-services.json` | Developer/Owner | 15–30 phút | B1 (bước 1) | B1 dừng ở bước 1. Có thể làm trước bước 2–3 với fake config nhưng chưa chứng minh được skeleton |
| X3 | (Nếu có Mac) Thêm app iOS `com.h2.game.blockBlast`, tải `GoogleService-Info.plist` | Developer/Owner | 15 phút | Kiểm chứng iOS (không chặn B1) | Hoãn sang Build & Test |
| X4 | Tạo key Remote Config `level_config` với JSON mặc định (do code cung cấp) và publish | Developer/Owner | 10 phút | Ca kiểm chứng số 3 của B1 | App dùng mặc định (`config_source=default`). Skeleton vẫn chạy, nhưng đường remote chưa được chứng minh |
| X5 | Chạy `flutter analyze`, `flutter test --coverage`, build và demo trên máy có Flutter, rồi gửi lại kết quả | Developer/Owner | 10–30 phút mỗi Bolt | Checkpoint của **mọi** Bolt | Bolt không thể được duyệt |
| X6 | Upload 36 ảnh lên Storage `bg/<gemId>/<subOrder>.jpg`, rule chỉ cho đọc `bg/`, thêm `background_url` vào JSON | Developer/Owner | 30–60 phút | B4 (đường ảnh mạng) | B4 vẫn hoàn thành với ảnh assets. Đường Storage hoãn |
| X7 | Chốt tên event `game_session` | Developer/Owner | 1 phút | B5 (trước phát hành) | Dùng `game_session` như requirements |
| X8 | File âm thanh `victory` và `unlock.wav` (có thể dùng placeholder) | Developer/Owner | tùy | B3 (bản cuối) | Dùng placeholder, ví dụ tái dùng `combo.wav` |
