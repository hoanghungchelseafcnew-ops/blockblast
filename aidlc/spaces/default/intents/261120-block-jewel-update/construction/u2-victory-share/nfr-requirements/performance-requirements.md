# Performance Requirements: u2-victory-share

Nguồn: functional-spec.md (unit này), requirements.md (NFR1, NFR6), technology-stack.md.

| ID | Yêu cầu | Cách kiểm |
|---|---|---|
| NFR1.1 | Bấm SHARE không làm đứng UI: chụp và ghi file chạy bất đồng bộ (`await`), khung hình Victory tiếp tục vẽ | quan sát trên thiết bị; widget test xác nhận nút bị vô hiệu khi đang chia sẻ |
| NFR1.2 | Khung chia sẻ mở trong vòng 2 giây sau khi bấm trên máy tầm trung | đo thủ công trên thiết bị |

## Ngoài phạm vi
Không thay đổi hiệu năng của trò chơi; unit không chạm logic bảng.
