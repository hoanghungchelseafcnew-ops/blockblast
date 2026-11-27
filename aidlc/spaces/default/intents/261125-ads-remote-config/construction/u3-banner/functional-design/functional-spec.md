# Đặc tả chức năng: u3-banner

Nguồn: `rules.md`, `unit-of-work.md` (U3), `unit-of-work-story-map.md` (US4.1 thuộc U3), `requirements.md` (FR2, FR5.1, NFR2), `components.md` (`AdMediator`, `AdCounters`, `GameScreen`), `contract-summary.md` (hợp đồng 2: `banner` trả `BannerResult` là `shown` kèm chiều cao hoặc `hidden`) và `functional-design-questions.md`. Không phụ thuộc ngôn ngữ lập trình.

## Thay đổi so với hành vi hiện tại

Hiện màn chơi Journey và Endless không có quảng cáo dưới cùng. Unit này thêm một vùng banner dưới cùng của cả hai màn, dùng lại `AdMediator` (thứ tự mạng, đồng ý) và `AdCounters` (số lần mở ứng dụng) của `u1-ads-core`.

## Luồng 1: Vào màn chơi

1. Màn chơi hiện với bố cục như hiện nay, chưa có vùng banner. (BR7.4)
2. Nếu số lần mở ứng dụng nhỏ hơn `banner_start_visit` hoặc đồng ý chưa được xử lý: không làm gì thêm. (BR7.1)
3. Ngược lại, yêu cầu `AdMediator.banner` với chiều rộng màn hình. Mediator thử từng mạng theo `ads_priority`, mỗi mạng tối đa 5 giây. (BR7.3)
4. Kết quả `shown`: vùng banner hiện dưới cùng với chiều cao của banner, bàn cờ và khay khối co lại một lần. (BR7.4)
5. Kết quả `hidden`: vùng banner không hiện, không chừa khoảng trống, không thử lại trong lần vào này. (BR7.5, BR7.9)

## Luồng 2: Chạm ngưỡng khi đang ở màn chơi

1. Người chơi ra nền rồi quay lại, lần quay lại được tính là một lần mở (BR5.3 của `u1-ads-core`).
2. Nếu màn chơi chưa có banner và chưa thử tải trong lần vào này, và số lần mở vừa đạt `banner_start_visit`: chạy bước 3 đến 5 của Luồng 1. (BR7.2)

## Luồng 3: Chuyển ván và rời màn chơi

1. CONTINUE, PLAY AGAIN hoặc nhận thưởng (`u2-reward-ads`) mà vẫn ở màn chơi: banner đang hiện được giữ nguyên. (BR7.7)
2. Lớp phủ Game Over hoặc Victory phủ toàn màn hình, kể cả vùng banner. (BR7.6)
3. Rời màn chơi: giải phóng banner. Lần vào sau bắt đầu lại từ Luồng 1. (BR7.7)

## Máy trạng thái: vùng banner của một lần vào màn chơi

| Trạng thái | Sự kiện | Điều kiện | Trạng thái kế | Hành động |
|-----------|---------|-----------|---------------|-----------|
| chưa đủ điều kiện | vào màn chơi hoặc quay lại từ nền | đủ lần mở và đã xử lý đồng ý | đang tải | yêu cầu banner |
| đang tải | `shown` | | đang hiện | hiện vùng banner, bố cục co lại |
| đang tải | `hidden` hoặc lỗi | | ẩn | không chừa chỗ |
| đang hiện | chuyển ván | | đang hiện | giữ nguyên |
| đang hiện, ẩn, đang tải | rời màn chơi | | kết thúc | giải phóng banner |

Trạng thái "ẩn" không quay lại "đang tải" trong cùng lần vào. (BR7.5)

## Tóm tắt quy tắc (suy ra từ rules.md)

Chín quy tắc BR7.1 đến BR7.9: điều kiện yêu cầu banner, tải ngay khi chạm ngưỡng giữa chừng, thứ tự mạng, bố cục khi đang tải, khi thất bại và khi có lớp phủ, vòng đời banner, áp dụng cho Endless, và xử lý lỗi.

## Assumptions & Open Questions

None.
