# Thiết kế bảo mật: u4-update-and-share

Nguồn: `security-requirements.md`, `tech-stack-decisions.md`, `functional-spec.md`, `contract-summary.md` và `nfr-design-questions.md`. Không chứa mã triển khai.

| ID | Thiết kế |
|----|----------|
| NFR8.1 | Một hàm kiểm tra dùng chung cho popup và chia sẻ: phân tích chuỗi thành URL, chấp nhận khi scheme đúng là `https`, có tên máy chủ, không có khoảng trắng hay ký tự điều khiển. Mọi giá trị khác là không hợp lệ |
| NFR8.2 | Mở đường dẫn qua một interface `StoreLauncher` có bản thật dùng `url_launcher` ở chế độ `externalApplication` |
| NFR8.3 | Log chỉ ghi kết quả so sánh ("update available" hoặc lý do bỏ qua), không ghi nguyên chuỗi cấu hình dài |
| NFR3.4 | `InstalledVersionReader` (bản thật dùng `package_info_plus`) và `StoreLauncher` đều là interface có bản giả trong test |

## Assumptions & Open Questions

None.
