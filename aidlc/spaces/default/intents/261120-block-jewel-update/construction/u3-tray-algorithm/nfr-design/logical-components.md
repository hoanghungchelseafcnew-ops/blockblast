# Logical Components: u3-tray-algorithm

Nguồn: functional-spec.md, rules.md, nfr-requirements/*, components.md.

Tất cả chạy trong một tiến trình Flutter, trên luồng UI. Không có hạ tầng, mạng hay dịch vụ ngoài; không có miền lỗi riêng biệt giữa các thành phần.

## Thành phần và vai trò NFR

| Thành phần | Vai trò | Mẫu NFR áp dụng |
|---|---|---|
| `DifficultyConstants` | Chứa mọi hằng số cân bằng và giới hạn bộ giải | Cấu hình một nơi (NFR5.3) |
| `DifficultyProfile` | Hàm thuần (level, độ đầy) → `TrayRates`; kẹp level | Hàm thuần dễ test, không trạng thái (NFR3.1, NFR7.1) |
| `TrayGenerator` | Sinh ứng viên, gọi bộ giải, hạ tier, trả `TrayResult`; ranh giới bắt ngoại lệ | Tiêm `Random` (NFR2.4); thứ bậc tier là suy giảm có kiểm soát (NFR2.2) |
| `TraySolver` (bên trong TrayGenerator) | Tìm kiếm theo chiều sâu, ngân sách nút, thoát sớm | Ngân sách và thoát sớm (NFR1.1, NFR1.2, NFR5.4) |
| `BoardLogic` (có sẵn) | Kiểm tra đặt vừa, xóa dòng trên bản sao bảng | Dùng lại, không đổi |
| `BoardEngine` (có sẵn, sửa) | Gọi `TrayGenerator.prepare`, nhận `TrayResult` | Ranh giới duy nhất đến U3 |

## Thiết kế hiệu năng (NFR1)

- **Ngân sách tổng:** một biến đếm nút dùng chung cho cả strict và relaxed trong một lần `prepare`; cạn thì ứng viên hiện tại coi là chưa chứng minh. Khởi điểm: `solverNodeBudget` 20000, 30 ứng viên strict, 30 ứng viên relaxed (NFR1.2).
- **Thoát sớm:** DFS dừng ngay khi một chuỗi vị trí đặt hết 3 khối. Với strict, 6 thứ tự được kiểm lần lượt và dừng ở thứ tự đầu tiên không giải được (ứng viên bị loại).
- **Sắp xếp vị trí:** thử các vị trí theo thứ tự cố định, ưu tiên vị trí xóa được dòng và vị trí sát cạnh, để tìm nghiệm sớm mà vẫn tất định.
- **Bản sao bảng nhẹ:** mô phỏng trên bản sao dạng mảng phẳng 64 ô hoặc bitmask, không tạo đối tượng widget. Bản sao được tái sử dụng giữa các nhánh bằng cách hoàn tác thay vì sao chép lại khi có thể.
- **Khay fallback:** khi còn từ 3 ô trống, trả khay {1x1, 1x1, 1x1} không cần tìm kiếm (BR1.5).
- **Đo lường:** NFR1.1 được đo bằng test hiệu năng trên bảng đầy 60–90%; nếu vượt 16 ms thì giảm `solverNodeBudget` hoặc số ứng viên trước khi đổi thuật toán. Người dùng đo trên máy thật.
- **Không dùng isolate:** chi phí truyền dữ liệu và độ phức tạp không đáng với mức ngân sách này (NFR5.4); xem lại nếu đo thực tế vượt ngưỡng.

## Độ tin cậy và quan sát

- Khi ngân sách cạn hoặc có ngoại lệ, hạ tier theo thứ tự strict → relaxed → fallback → Game Over; Game Over chỉ do bước cuối (BR1.4), không do ngân sách.
- Log bằng `GjLog` ở mức debug cho tier đạt được và số nút đã dùng (hỗ trợ cân bằng); log mức lỗi cho ngoại lệ bộ giải. Không có metric, tracing hay cảnh báo: ngoài phạm vi một game offline.

## Blast radius

Lỗi trong U3 chỉ ảnh hưởng việc sinh khay. Vì `prepare` bắt mọi ngoại lệ và luôn có đường rơi về khay fallback hoặc Game Over, lỗi không làm sập `BoardEngine` hay màn chơi.
