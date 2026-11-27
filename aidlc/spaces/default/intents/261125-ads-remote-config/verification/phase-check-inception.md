# Kiểm tra cuối giai đoạn đặc tả

**Kết quả: ĐẠT, kèm các điểm cần xử lý trước khi xây dựng (xem bên dưới).**

## Độ phủ truy vết

| Tài liệu | Mô tả | GAP | ORPHAN | Mục sai đích |
|----------|-------|-----|--------|--------------|
| `user-stories/traceability.json` | 44 mã yêu cầu `FR` và `NFR` đến stories | 0 | 0 | 0 |
| `domain-design/traceability.json` | 8 stories đến thành phần | 0 | 0 | 0 |
| `units-generation/traceability.json` | 8 stories đến unit | 0 | 0 | 0 |

Contract Design không có `traceability.json` vì nó sở hữu hợp đồng, không sở hữu độ phủ yêu cầu.

Một số yêu cầu được hoãn có tên bước nhận: NFR3 và NFR6 sang nfr-requirements, NFR7 sang build-and-test, và NFR5 ghi N/A có lý do.

## Điểm cần xử lý trước hoặc trong giai đoạn xây dựng

- `requirements.md` (FR3.1) và `stories.md` (AC3.1.2) còn ghi ẩn nút reward khi chưa có quảng cáo, trong khi quyết định hiện hành là nút luôn hiện và thưởng ngay khi không có quảng cáo (`decisions.md` ADR-007). Cần cập nhật hai tài liệu này, hoặc xem quyết định hiện hành là nguồn đúng khi thực hiện.
- `wireframes.md` và `user-flow.md` của giai đoạn ý tưởng còn ghi reward ads là "chơi lại level từ đầu". Quyết định hiện hành nằm ở `mockups.md`.
- Thời gian chờ tối đa khi thử ba mạng (tới 15 giây) và dạng tên phiên bản được chấp nhận là các câu hỏi mở trong `contract-summary.md`.
- Lệnh kiểm tra tự động chưa chọn, điểm kiểm tra đầu tiên sẽ hỏi lại.
- Các lượt kiểm tra của chuyên gia ở nhiều bước không hoàn thành, và các nhận xét "độc lập" ở Practices Discovery và User Stories do conductor tự viết.

## Nhất quán giữa các giai đoạn

Không có mâu thuẫn chưa được ghi nhận giữa yêu cầu, stories, thành phần và unit, ngoài các điểm đã nêu ở trên.

## Phê duyệt

- [ ] Người dùng xác nhận kết quả kiểm tra này khi duyệt bước Delivery Planning
