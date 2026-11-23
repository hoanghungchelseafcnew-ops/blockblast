# Risk and Sequencing Rationale

- **Cách xếp:** walking skeleton trước (U1), rồi rủi ro trước (U3), cuối cùng U2. Không dùng WSJF (mô hình chấm giá trị, độ gấp chia cho kích thước) vì chỉ có 3 unit.
- **Vì sao U1 trước:** nhỏ nhất (S), chạm tên và khởi động nên mọi test và thiết bị sau đó dùng tên mới; theo quy ước team phải có bản mỏng chạy xuyên suốt trước. Tham chiếu: Cockburn (walking skeleton).
- **Vì sao U3 thứ hai:** rủi ro lớn nhất theo mối lo bạn nêu (cân bằng độ khó) và độ phức tạp L; cần nhiều vòng chỉnh hằng số, nên làm sớm.
- **Vì sao U2 cuối:** giá trị rõ nhưng rủi ro thấp (đã có sẵn gói và dịch vụ chia sẻ); không chặn unit nào.
- **Rủi ro chính và cách giảm:**
  - Cân bằng độ khó sai: hằng số ở một nơi (`DifficultyProfile`), test thống kê, bạn chơi thử trước khi phát hành.
  - Android 12+ vẫn hiện splash hệ thống: giới hạn nền tảng, đã giảm bằng nền cùng màu.
  - U2 và U3 cùng chạm `GameScreen`/controller: làm lần lượt nên không xung đột.
- **Không lệch thứ tự topo** (DAG rỗng).
