# Đặc tả chức năng: u2-reward-ads

Nguồn: `rules.md`, `stories.md` (US3.1), `mockups.md`, `interaction-spec.md`, `decisions.md` (ADR-003, ADR-007), `contract-summary.md` và `functional-design-questions.md`. Không phụ thuộc ngôn ngữ lập trình.

## Thay đổi so với hành vi hiện tại

Hiện tại, khi hết nước đi, `LevelGameController` gọi ngay `JourneyController.onLevelLost`: tiến trình bị hạ về level đầu của viên đá, viên đá đang có bị bỏ, và điểm cao được lưu, trước khi lớp phủ Game Over hiện. Unit này tách việc "kết thúc ván" khỏi việc "ghi nhận thua". (BR6.2)

## Luồng 1: Hết nước đi ở Journey

1. Hết nước đi: trạng thái chuyển sang thua, lớp phủ Game Over hiện, chưa hạ tiến trình. (BR6.2)
2. Lưu một dấu "có lần thua chưa ghi nhận" cho level này, để dùng nếu ứng dụng bị tắt. (BR6.7)
3. Dòng "You will return to <level>" vẫn hiện. Nếu nút reward hiện, thêm dòng nhỏ "Watch an ad to stay on this level". (`mockups.md`)
4. Nút WATCH AD TO TRY AGAIN hiện khi `reward_enabled` là true và ván này chưa nhận thưởng. (BR6.1)

## Luồng 2: Bấm WATCH AD TO TRY AGAIN

1. Gọi `AdMediator.reward` (hợp đồng 2).
2. Kết quả `earned` hoặc `no_ad`: lưu điểm cao nếu cao hơn (BR6.6), xóa dấu lần thua chưa ghi nhận, rồi bắt đầu lại cùng level: điểm 0, bàn cờ sạch, khay mới, đang chơi. Không ghi nhận thua. (BR6.3)
3. Kết quả `closed_early`: giữ lớp phủ, nút vẫn hiện để thử lại, không thưởng. (BR6.4)
4. Trong lúc chờ quảng cáo, bấm nút lần nữa không có tác dụng.
5. Sau khi chơi tiếp, nếu người chơi lại hết nước đi, đó là một ván thua mới và nút hiện lại. (BR6.5)

## Luồng 3: Bấm PLAY AGAIN hoặc BACK TO MENU

1. Ghi nhận thua đúng một lần: hạ tiến trình, lưu điểm cao, xóa dấu lần thua chưa ghi nhận. (BR6.2, BR6.8)
2. PLAY AGAIN: interstitial nếu đến lượt (đã có từ `u1-ads-core`), rồi bắt đầu ở level trả về như hiện nay.
3. BACK TO MENU: về Home như hiện nay.

## Luồng 4: Mở lại ứng dụng khi còn dấu lần thua chưa ghi nhận

1. Khi dịch vụ được dựng, nếu có dấu lần thua chưa ghi nhận, ghi nhận thua cho level đó và xóa dấu. (BR6.7)
2. Người chơi vào Home và thấy level đã bị hạ như hiện nay.

## Máy trạng thái: ván chơi Journey

| Trạng thái | Sự kiện | Điều kiện | Trạng thái kế | Hành động |
|-----------|---------|-----------|---------------|-----------|
| đang chơi | hết nước đi | | thua, chưa ghi nhận | lưu dấu, hiện lớp phủ |
| thua, chưa ghi nhận | nhận thưởng (`earned` hoặc `no_ad`) | nút đang hiện | đang chơi | lưu điểm cao, xóa dấu, bắt đầu lại cùng level |
| thua, chưa ghi nhận | đóng quảng cáo sớm | | thua, chưa ghi nhận | không làm gì |
| thua, chưa ghi nhận | PLAY AGAIN hoặc BACK TO MENU | | thua, đã ghi nhận | ghi nhận thua, xóa dấu |
| thua, đã ghi nhận | PLAY AGAIN | | đang chơi | bắt đầu ở level trả về |

## Tóm tắt quy tắc (suy ra từ rules.md)

Tám quy tắc BR6.1 đến BR6.8: điều kiện hiện nút, hoãn và ghi nhận thua đúng một lần, kết quả của reward, giới hạn mỗi ván thua, lưu điểm cao, và xử lý lần thua chưa ghi nhận khi mở lại.

## Assumptions & Open Questions

None.
