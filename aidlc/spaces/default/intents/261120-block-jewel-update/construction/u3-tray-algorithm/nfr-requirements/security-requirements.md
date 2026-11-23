# Security Requirements: u3-tray-algorithm

Nguồn: functional-spec.md, rules.md (BR5.2, BR5.3), requirements.md (NFR4, NFR6, NFR7).

U3 là thư viện logic thuần chạy trên máy người chơi: không mạng, không tài khoản, không dữ liệu cá nhân, không quyền mới. Yêu cầu bảo mật vì vậy hẹp.

| ID | Yêu cầu | Cách kiểm |
|---|---|---|
| NFR6.1 | U3 không đọc, ghi hay gửi dữ liệu ra ngoài: không file, không mạng, không SharedPreferences, không Firebase. Chỉ nhận bảng, level và `Random`, trả khay | đọc code; test không dùng mock IO |
| NFR6.2 | Log lỗi bộ giải (`GjLog`) không chứa dữ liệu cá nhân, chỉ chứa level, độ đầy và tier | đọc code |
| NFR7.1 | Không đổi dữ liệu tiến trình đã lưu và cấu hình Remote Config; level đầu vào được kẹp vào 1..36 | test với level ngoài khoảng; so sánh khóa lưu trữ |
| NFR7.2 | Không thêm quyền, gói hay dịch vụ mới | so sánh `pubspec.yaml`, manifest |
| NFR4.1 | Mọi chuỗi hiển thị (nếu có, ví dụ thông báo lỗi người dùng thấy) bằng tiếng Anh; U3 không thêm chuỗi UI | đọc code |
| NFR2.2 | Bộ giải không treo hay ném lỗi chưa xử lý trên đầu vào bất thường (bảng đầy, bảng rỗng, ô băng, ô bom): dùng ngân sách nút, bắt ngoại lệ, rơi về mức hạ kế tiếp | test thuộc tính và test biên |

## Mối đe dọa

Không có tác nhân ngoài hay dữ liệu không tin cậy. Rủi ro đáng kể duy nhất là từ chối dịch vụ cục bộ: bộ giải chạy quá lâu trên luồng UI làm treo game. Giảm bằng ngân sách nút cố định (`solverNodeBudget`) và giới hạn số ứng viên (BR5.4).
