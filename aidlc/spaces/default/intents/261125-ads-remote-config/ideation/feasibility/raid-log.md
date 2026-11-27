# Nhật ký RAID: Quảng cáo và Remote Config

## Risks

| ID | Rủi ro | Khả năng | Tác động | Xử lý đề xuất | Nguồn |
|----|--------|----------|----------|---------------|-------|
| R1 | Hiển thị quảng cáo cho người dùng EU/EEA hoặc iOS mà chưa có sự đồng ý hợp lệ, có thể bị cửa hàng từ chối hoặc vi phạm quy định | Trung bình | Cao | Giảm thiểu: đưa xử lý đồng ý vào phạm vi thiết kế | Q4, C7 |
| R2 | Khai báo sai nhóm đối tượng trên cửa hàng hoặc mạng quảng cáo, dẫn đến quảng cáo không phù hợp hoặc bị từ chối | Thấp | Trung bình | Giảm thiểu: xác nhận khai báo cho nhóm trên 13 tuổi trước khi gửi duyệt | Q5, C8 |
| R3 | Thời gian duyệt của cửa hàng làm chậm phát hành | Trung bình | Trung bình | Chấp nhận: không có mốc cố định | Q8, Q3 |
| R4 | Tích hợp ba mạng bằng ba SDK riêng làm tăng khối lượng và rủi ro lỗi (giả thuyết) | Trung bình | Trung bình | Giảm thiểu: đánh giá kỹ ở bước thiết kế | Q2 |

## Assumptions

None.

## Issues

| ID | Vấn đề | Nguồn |
|----|--------|-------|
| I1 | Ứng dụng chưa có trên cửa hàng nào, nên chưa có link thật cho popup cập nhật và nội dung chia sẻ | Q7 |

## Dependencies

| ID | Phụ thuộc | Nguồn |
|----|-----------|-------|
| D1 | Link cửa hàng thật phụ thuộc vào việc ứng dụng được duyệt và lên cửa hàng, sau đó cập nhật qua Remote Config | Q7, Q8 |
| D2 | Ad unit của AdMob, Unity, AppLovin phải còn hiệu lực khi kiểm tra | Q7 của intent-capture |

## Assumptions & Open Questions

None.
