# Delivery Planning Questions

Một Bolt là một lượt xây dựng một phần công việc, kết thúc bằng thứ chạy được. Có 3 unit độc lập (U1 `u1-app-shell`, U2 `u2-victory-share`, U3 `u3-tray-algorithm`), nên thứ tự do bạn chọn.

## Question 1
Xây gì trước?

A. Một lát mỏng chạy xuyên suốt trước (U1: đổi tên và splash, chạy app đến chơi 1 level, theo quy ước "bản mỏng" của team), rồi phần rủi ro nhất (U3 thuật toán), cuối cùng U2 (chia sẻ).
B. Phần giá trị cao nhất trước: U3, rồi U2, rồi U1.
C. Phần rủi ro nhất trước: U3, rồi U1, rồi U2.
X. Other (please specify)

[Answer]:A

## Question 2
Có chấm điểm xếp hạng công việc bằng mô hình WSJF (giá trị và độ gấp chia cho kích thước) không?

A. Không, ba unit ít nên sắp xếp theo lập luận ngắn là đủ.
B. Có, ghi bảng điểm.
X. Other (please specify)

[Answer]:A

## Question 3
Một Bolt lớn cỡ nào?

A. Mỗi Bolt một unit (3 Bolt).
B. Gộp U1 và U2 thành một Bolt, U3 một Bolt (2 Bolt).
X. Other (please specify)

[Answer]:A

## Question 4
Các Bolt chạy đồng thời hay lần lượt?

A. Lần lượt (một người phát triển, một lúc một việc).
B. Đồng thời được cho các unit độc lập.
X. Other (please specify)

[Answer]:A

## Question 5
Có gì bên ngoài team có thể làm chậm không (API, dữ liệu, duyệt, bên thứ ba)?

A. Không. Remote Config giữ nguyên; chỉ cần bạn tự kiểm tra splash trên thiết bị Android 12+ và iOS thật.
B. Có (ghi rõ ở Other: ai giữ, mất bao lâu, chặn Bolt nào, nếu trễ thì làm gì).
X. Other (please specify)

[Answer]:A

## Question 6
Điều bạn lo nhất ở đợt này, để làm sớm?

A. Thuật toán khối làm game quá dễ hoặc quá khó (cân bằng).
B. Splash vẫn hiện hai lần trên một số máy Android.
C. Ảnh chia sẻ không đủ toàn màn hình hoặc bị lỗi trên một số máy.
X. Other (please specify)

[Answer]:A

## Question 7
Cách thi công (Construction):

A. Làm lần lượt từng unit (hoàn thành unit này rồi mới sang unit kế), tất cả trong phiên này.
B. Mỗi unit do một team riêng sở hữu và duyệt riêng.
X. Other (please specify)

[Answer]:A
