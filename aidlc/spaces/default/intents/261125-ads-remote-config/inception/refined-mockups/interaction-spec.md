# Đặc tả tương tác: Quảng cáo và Remote Config

Định dạng theo `component-spec-template.md`, điều chỉnh cho ứng dụng di động (không có hover, không có breakpoint web). Nguồn: `mockups.md`, `stories.md`, `requirements.md`.

## RewardAdButton (nút xem reward ads)

| Field | Value |
|---|---|
| Component | RewardAdButton |
| Description | Nút chính trong lớp phủ Game Over, để xem quảng cáo và chơi tiếp level đó |
| Category | input |

### States

| State | Description | Trigger |
|---|---|---|
| default | Hiện với nhãn WATCH AD TO TRY AGAIN | `reward_enabled` là true và chưa dùng reward ở ván thua này (US3.1, AC3.1.1) |
| hidden | Không hiện | `reward_enabled` là false, đã dùng reward ở ván này, hoặc ở chế độ Endless (AC3.1.6, AC3.1.7) |
| pressed | Quảng cáo hiện, hoặc thưởng ngay nếu không có quảng cáo | người chơi bấm nút (Q8) |

### Hành vi sau khi bấm

| Tình huống | Kết quả |
|-----------|---------|
| Quảng cáo xem đủ | Điểm về 0, bàn cờ xóa sạch, khay khối mới, chơi tiếp level đó, tiến trình không bị hạ (AC3.1.3, AC3.1.4) |
| Quảng cáo đóng sớm | Không thưởng, quay lại lớp phủ Game Over, nút vẫn có thể bấm lại (AC3.1.5, và xem Câu hỏi mở) |
| Không có quảng cáo khi bấm | Thưởng ngay như đã xem đủ (Q8) |

### Props / Inputs

| Prop | Type | Required | Default | Description |
|---|---|---|---|---|
| label | string | yes | WATCH AD TO TRY AGAIN | Nhãn nút, tiếng Anh |
| palette | GemPalette | yes | | Bảng màu theo viên đá hiện tại |
| onPressed | callback | yes | | Hành động khi bấm |

### Responsive Behaviour

| Kích thước | Behaviour |
|---|---|
| Điện thoại hướng dọc | Nút rộng 220dp như các nút khác của lớp phủ, nhãn một dòng và thu nhỏ chữ nếu thiếu chỗ (như `GemPrimaryButton`) |

### Accessibility

| Requirement | Implementation |
|---|---|
| Vai trò | button |
| Vùng chạm | cao tối thiểu 56dp (như `GemPrimaryButton`), đạt mức 48dp trở lên |
| Nhãn | Nhãn hiển thị WATCH AD TO TRY AGAIN, đọc được bởi trình đọc màn hình |
| Tương phản | chữ so với nền nút tối thiểu 4.5 trên 1 (`GemPalette.onPrimary` trên `buttonFill`) |

## AdBannerSlot (vùng banner)

| Field | Value |
|---|---|
| Component | AdBannerSlot |
| Description | Dải banner cố định dưới cùng màn chơi |
| Category | display |

### States

| State | Description | Trigger |
|---|---|---|
| hidden | Không hiện và không chiếm chỗ | lần mở ứng dụng chưa đến `banner_start_visit`, hoặc banner chưa tải, hoặc tải lỗi (AC4.1.1, AC4.1.5) |
| shown | Banner thích ứng theo chiều rộng màn hình, trên dải nền tối | lần mở ứng dụng từ `banner_start_visit` trở đi và banner đã tải (AC4.1.2) |

### Responsive Behaviour

| Kích thước | Behaviour |
|---|---|
| Điện thoại hướng dọc | Chiều cao do quảng cáo quyết định theo chiều rộng. Phần trên co lại để bàn cờ và khay khối không bị che (AC4.1.6) |

### Accessibility

| Requirement | Implementation |
|---|---|
| Vai trò | Quảng cáo, không phải điều khiển của game |
| Focus | Không nhận focus bàn phím khi game đang chơi để không cản trở thao tác kéo thả |

## UpdateDialog (popup cập nhật)

| Field | Value |
|---|---|
| Component | UpdateDialog |
| Description | Hộp thoại báo có bản mới trên màn Home |
| Category | feedback |

### States

| State | Description | Trigger |
|---|---|---|
| hidden | Không hiện | bản cài đặt không thấp hơn phiên bản cấu hình, cấu hình hoặc đường dẫn không hợp lệ, hoặc đã hiện trong lần mở ứng dụng này (AC5.1.2, AC5.1.5) |
| shown | Hộp thoại với tiêu đề "Update available" | bản cài đặt thấp hơn, vào Home (AC5.1.1) |

### Hành động

| Nút | Kết quả |
|-----|---------|
| UPDATE | Mở trang cửa hàng của nền tảng (AC5.1.3) |
| LATER | Đóng hộp thoại (AC5.1.4) |

### Props / Inputs

| Prop | Type | Required | Default | Description |
|---|---|---|---|---|
| storeUrl | string | yes | | Đường dẫn của nền tảng đang chạy |
| palette | GemPalette | yes | | Màu cho nút UPDATE |

### Accessibility

| Requirement | Implementation |
|---|---|
| Vai trò | dialog |
| Focus ban đầu | Nút LATER có `autofocus`, như `QuitDialog` |
| Vùng chạm | mỗi nút tối thiểu 112 x 48dp, như `QuitDialog` |
| Phím quay lại | Tương đương LATER |

## Câu hỏi mở

- Khi người chơi đóng quảng cáo sớm rồi quay lại Game Over, `stories.md` (AC3.1.6) nói nút không hiện nữa sau khi đã dùng reward ở ván này. Cần xác nhận "đã dùng" là đã bấm nút hay đã nhận thưởng. Đề xuất: chỉ tính là đã dùng khi đã nhận thưởng. (`requirements.md` FR3.3)

## Assumptions & Open Questions

None.
