# Câu hỏi thiết kế chức năng: u2-reward-ads

Unit này thêm nút WATCH AD TO TRY AGAIN ở lớp phủ Game Over của chế độ Journey. Đã chốt ở các bước trước: hoãn ghi nhận thua đến khi người chơi rời lớp phủ Game Over (ADR-003), nút luôn hiện khi `reward_enabled` là true và không có quảng cáo thì thưởng ngay (ADR-007), xem xong thì điểm về 0, bàn cờ sạch, khay mới, level không bị hạ (US3.1). Hiện mã nguồn ghi nhận thua bằng cách hạ tiến trình về level đầu của viên đá và bỏ viên đá đang có (`_applyLoss` trong `journey_controller.dart`).

## Q1. Khi nào tính là "đã dùng reward" ở một ván thua

AC3.1.6 nói nút không hiện lại khi đã dùng reward ở ván thua đó. Có hai cách hiểu, và chúng khác nhau khi người chơi đóng quảng cáo sớm.

- A. Chỉ tính là đã dùng khi người chơi đã nhận thưởng. Đóng quảng cáo sớm thì nút vẫn hiện để thử lại
- B. Tính là đã dùng ngay khi bấm nút, kể cả khi đóng quảng cáo sớm
- C. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:A

## Q2. "Ván thua" là gì khi người chơi đã nhận thưởng và thua lần nữa

Sau khi nhận thưởng, người chơi chơi tiếp ở cùng level với điểm 0. Nếu họ thua lần nữa, câu hỏi là nút reward có hiện lại không.

- A. Không: một level chỉ được nhận thưởng một lần cho đến khi người chơi thắng hoặc rời level. Lần thua thứ hai ghi nhận thua như bình thường
- B. Có: mỗi lần thua là một ván thua mới, nên được nhận thưởng thêm một lần
- C. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:B

## Q3. Ứng dụng bị tắt khi đang ở lớp phủ Game Over

Theo ADR-003, thua chỉ được ghi nhận khi người chơi rời lớp phủ. Nếu ứng dụng bị tắt hoặc vào nền rồi bị hệ điều hành đóng khi đang ở lớp phủ, lần thua chưa được ghi nhận.

Lần mở sau thì sao?

- A. Coi như người chơi đã thua: lần mở sau ghi nhận thua (hạ tiến trình như hiện nay) trước khi vào Home
- B. Coi như chưa thua: người chơi vẫn ở level đó với tiến trình giữ nguyên
- C. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:A

## Q4. Điểm cao nhất (BEST) khi nhận thưởng

Hiện game lưu điểm cao của level khi thua. Khi nhận thưởng thì điểm về 0 và ván chưa kết thúc.

- A. Vẫn lưu điểm của ván vừa thua làm điểm cao nếu cao hơn điểm cũ, rồi mới về 0
- B. Không lưu, vì ván chưa kết thúc
- C. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:A
