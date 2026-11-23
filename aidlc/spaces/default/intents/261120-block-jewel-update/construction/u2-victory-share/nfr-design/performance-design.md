# Performance Design: u2-victory-share

Nguồn: performance-requirements.md, tech-stack-decisions.md (unit này), functional-spec.md.

| ID | Thiết kế |
|---|---|
| NFR1.1 | `onShare` trả `Future`; `VictoryOverlay` giữ cờ `_sharing` để vô hiệu nút trong lúc chờ; không có tác vụ đồng bộ nặng trên luồng UI ngoài `capture()` của gói `screenshot` |
| NFR1.2 | Chụp ở `pixelRatio` mặc định của thiết bị, ghi PNG một lần vào thư mục tạm rồi mở khung chia sẻ; không nén hay xử lý ảnh thêm |
