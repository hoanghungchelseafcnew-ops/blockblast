# Architecture Decision Records

## ADR-001: Tách TrayGenerator không tĩnh khỏi danh mục hình
- **Context:** `BlockGenerator.generateThree()` là hàm tĩnh, không biết bảng hay level, dùng `Random` cố định.
- **Decision:** Tạo `TrayGenerator` nhận `Random` tiêm vào, thay `generateThree`; phần bảng hình và màu thành `BlockCatalog`.
- **Consequences:** Test theo seed được, tuân quy ước tách logic. Phải đổi `BoardEngine` và test dùng `BlockSource`.
- **Alternatives Rejected:** mở rộng hàm tĩnh với tham số (khó test, tiếp tục trạng thái toàn cục).

## ADR-002: DifficultyProfile là lớp thuần riêng
- **Context:** Tỉ lệ nhỏ/vừa/lớn, rescueRate và ngưỡng 60% cần chỉnh thường xuyên.
- **Decision:** Một lớp thuần chứa mọi hằng số; Endless dùng level 18.
- **Consequences:** Chỉnh cân bằng ở một nơi, dễ test; thêm một lớp.
- **Alternatives Rejected:** để trong TrayGenerator (lẫn logic và dữ liệu).

## ADR-003: Controller truyền mức độ khó, engine không biết mốc điểm
- **Context:** `BoardEngine` hiện không biết level và mốc điểm.
- **Decision:** Controller truyền mức độ khó khi reset và refill; engine không giữ trạng thái level.
- **Consequences:** Giữ ranh giới hiện có; chữ ký reset và refill thêm tham số.
- **Alternatives Rejected:** engine giữ thuộc tính `difficultyLevel` (trạng thái ẩn, dễ quên gán).

## ADR-004: Thêm shareVictory cạnh shareScore
- **Context:** Victory cần văn bản có tên level; Game Over chỉ có điểm.
- **Decision:** Thêm `shareVictory({screenshot, levelName, score})`, giữ `shareScore`.
- **Consequences:** Hai phương thức rõ mục đích, cần cập nhật fake trong test.
- **Alternatives Rejected:** thêm tham số tùy chọn cho `shareScore` (hành vi mơ hồ).
