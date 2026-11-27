# Câu hỏi thiết kế chức năng: u4-update-and-share

Unit này thêm popup báo có bản mới trên màn Home và link cửa hàng trong nội dung chia sẻ. Đã chốt ở các bước trước:
- Popup không bắt buộc, có hai nút LATER và UPDATE, hiện trên Home tối đa một lần mỗi lần mở ứng dụng (FR6.2, FR6.3).
- Chỉ so tên phiên bản, bỏ số build (FR6.1).
- Không hiện popup khi phiên bản hoặc đường dẫn trên cấu hình rỗng hay sai dạng (FR6.4).
- Link được thêm vào cuối nội dung chia sẻ, chọn theo hệ điều hành. Đường dẫn rỗng hay sai dạng thì nội dung giữ nguyên (FR7).
- Hiện chưa phát hành, nên link ban đầu là link giả, đổi qua Remote Config sau.

## Q1. "Một lần mỗi lần mở ứng dụng" tính thế nào

Quảng cáo đã dùng định nghĩa: lần mở gồm lần khởi động và mỗi lần quay lại từ nền (trừ quay lại do quảng cáo, hộp thoại hay bảng chia sẻ, BR5.3).

- A. Dùng cùng định nghĩa đó: người chơi quay lại từ nền rồi vào Home thì popup có thể hiện lại
- B. Chỉ tính lần khởi động: popup hiện tối đa một lần cho đến khi ứng dụng bị tắt hẳn rồi mở lại
- C. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:A

## Q2. Thứ tự giữa popup cập nhật và hộp thoại đồng ý quảng cáo

Ở lần vào Home đầu tiên, hộp thoại đồng ý quảng cáo (và hộp thoại xin phép theo dõi trên iOS) có thể hiện.

- A. Hộp thoại đồng ý trước; popup cập nhật hiện sau khi người chơi trả lời xong
- B. Popup cập nhật trước; hộp thoại đồng ý hiện sau khi popup đóng
- C. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:A

## Q3. Đường dẫn thế nào là hợp lệ

- A. Chỉ đường dẫn `https://` đầy đủ (ví dụ `https://play.google.com/store/apps/details?id=...`, `https://apps.apple.com/app/id...`)
- B. `http://` hoặc `https://`
- C. `https://` và thêm đường dẫn riêng của cửa hàng (`market://`, `itms-apps://`)
- X. Other (please specify)

[Answer]:A

## Q4. Cách nối link vào nội dung chia sẻ

- A. Xuống dòng rồi thêm link ở dòng riêng
- B. Thêm một dấu cách rồi link ngay sau câu hiện có
- C. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:A

## Assumptions & Open Questions

- [assumption] So phiên bản theo từng phần số, phần thiếu coi là 0: `1.0` bằng `1.0.0`, `1.0.10` cao hơn `1.0.9`.
- [assumption] Bấm nút back hoặc chạm ra ngoài popup được tính như LATER.
- [assumption] UPDATE mở cửa hàng bằng trình mở ngoài rồi đóng popup. Nếu không mở được thì ghi log và đóng popup, game vẫn chạy.
- [assumption] Popup chỉ hiện trên Home, không hiện ở màn chơi hay khi đang có lớp phủ khác.
