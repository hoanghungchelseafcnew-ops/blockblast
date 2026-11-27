# Câu hỏi thiết kế chức năng: u3-banner

Unit này thêm banner dưới cùng màn chơi (Journey và Endless). Đã chốt ở các bước trước: banner thích ứng (adaptive) đặt dưới cùng, hiện ở mọi màn chơi từ lần mở ứng dụng thứ `banner_start_visit` (mặc định 3), cũng hiện ở Endless, ẩn hẳn khi không tải được (FR2, US4.1). Lần mở ứng dụng gồm lần khởi động và mỗi lần quay lại từ nền, trừ lần quay lại do quảng cáo, hộp thoại đồng ý hay bảng chia sẻ (BR5.3). Mạng được thử theo `ads_priority`, mỗi mạng tối đa 5 giây (BR2.5).

Hiện màn chơi là một cột gồm phần đầu (điểm, thanh tiến độ), vùng chữ combo và vùng bàn cờ cộng khay khối co giãn theo chỗ còn lại. Lớp phủ Game Over và Victory phủ toàn màn hình.

## Q1. Lần mở thứ N đến khi người chơi đang ở màn chơi

Người chơi có thể đang ở màn chơi, ra nền rồi quay lại, và lần quay lại đó làm bộ đếm chạm đúng N.

- A. Banner hiện ngay trên màn chơi đang mở
- B. Banner chỉ hiện từ lần vào màn chơi kế tiếp
- C. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:A

## Q2. Khoảng trống khi banner đang tải

Banner cần một lúc để tải. FR2.4 đã chốt là không tải được thì không chừa khoảng trống.

- A. Không chừa chỗ khi đang tải. Khi banner tải xong, bàn cờ và khay khối co lại một lần để nhường chỗ
- B. Chừa sẵn chỗ bằng chiều cao banner ngay khi vào màn chơi. Nếu tải thất bại thì bỏ khoảng trống đó và bàn cờ giãn ra
- C. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:A

## Q3. Banner khi lớp phủ Game Over hoặc Victory hiện

- A. Banner vẫn hiện dưới cùng, lớp phủ chỉ phủ phần phía trên banner
- B. Lớp phủ che cả banner như che phần còn lại của màn chơi
- C. Ẩn banner khi có lớp phủ, hiện lại khi chơi tiếp
- X. Other (please specify)

[Answer]:B

## Q4. Tải lại khi không mạng nào có banner

Khi mọi mạng trong `ads_priority` đều không có banner, vùng banner ẩn đi.

- A. Chỉ thử lại ở lần vào màn chơi kế tiếp
- B. Thử lại định kỳ trong lúc đang ở màn chơi (mỗi 60 giây), hiện ngay khi có
- C. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:A

## Q5. Giữ banner giữa các ván

Khi người chơi chuyển level (CONTINUE, PLAY AGAIN, nhận thưởng) mà vẫn ở màn chơi, hoặc quay về Home rồi vào lại.

- A. Giữ nguyên banner đang hiện khi chuyển ván trong cùng màn chơi; ra Home rồi vào lại thì tải banner mới
- B. Tải banner mới ở mỗi ván
- C. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:A

## Assumptions & Open Questions

- [assumption] Banner không tải khi người chơi chưa trả lời hộp thoại đồng ý (BR3.1), và dùng chế độ không cá nhân hóa khi người chơi từ chối (BR3.2).
- [assumption] Trên màn hình ngắn, bàn cờ và khay khối thu nhỏ theo chỗ còn lại như hiện nay, nên banner không bao giờ che chúng (AC4.1.6).
- [assumption] Bản debug dùng ID banner thử của AdMob; ID thật của ba mạng điền trước khi phát hành, như u1 và u2.
