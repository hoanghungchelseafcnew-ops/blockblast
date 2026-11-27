# Đặc tả chức năng: u4-update-and-share

Nguồn: `rules.md`, `unit-of-work.md` (U4), `unit-of-work-story-map.md` (US5.1, US6.1 thuộc U4), `requirements.md` (FR6, FR7, NFR4), `components.md` (`AppUpdateChecker`, `HomeScreen`, `ScoreShareService`), `contract-summary.md` (hợp đồng 3: `AdsSettings` có `androidVersion`, `androidUrl`, `iosVersion`, `iosUrl`) và `functional-design-questions.md`. Không phụ thuộc ngôn ngữ lập trình.

## Thay đổi so với hành vi hiện tại

Hiện Home không kiểm tra phiên bản, và nội dung chia sẻ chỉ có một câu (ví dụ "I scored 120 in Block Jewel!"). Unit này thêm việc kiểm tra phiên bản với popup trên Home, và thêm link cửa hàng vào cuối nội dung chia sẻ. Cả hai chỉ cần cấu hình đã đọc ở `u1-ads-core`, không cần quảng cáo.

## Luồng 1: Kiểm tra phiên bản khi vào Home

1. Đọc tên phiên bản đang cài, bỏ phần số build. (BR8.1)
2. Lấy phiên bản và đường dẫn của nền tảng đang chạy từ cấu hình (`android_version` và `android_url`, hoặc `ios_version` và `ios_url`).
3. Phiên bản nào sai dạng, hoặc đường dẫn không hợp lệ: dừng, không có popup. (BR8.1, BR8.3)
4. So phiên bản. Cấu hình lớn hơn bản cài thì có bản mới. (BR8.2)
5. Nếu luồng đồng ý quảng cáo chưa xong, chờ nó xong. (BR8.5)
6. Nếu popup chưa hiện trong lần mở này và người chơi vẫn ở Home: hiện popup và ghi là đã hiện trong lần mở này. (BR8.4)

## Luồng 2: Người chơi bấm trên popup

1. UPDATE: mở đường dẫn cửa hàng bằng trình mở ngoài, đóng popup. Lần quay lại từ cửa hàng không được tính là một lần mở mới, giống bảng chia sẻ (BR5.3). Không mở được thì ghi log. (BR8.6)
2. LATER, back hoặc chạm ra ngoài: đóng popup. (BR8.6)

## Luồng 3: Lần mở mới

Khi ứng dụng quay lại từ nền và lần đó được tính là một lần mở (BR5.3), dấu "đã hiện" được xóa. Lần vào Home kế tiếp chạy lại Luồng 1. (BR8.4)

## Luồng 4: Chia sẻ điểm hoặc chiến thắng

1. Tạo văn bản hiện có ("I scored N in Block Jewel!" hoặc câu chiến thắng).
2. Nếu đường dẫn của nền tảng đang chạy hợp lệ: thêm một dòng mới rồi đến đường dẫn. Không hợp lệ thì giữ nguyên văn bản. (BR9.1, BR8.3)

## Máy trạng thái: popup trong một lần mở ứng dụng

| Trạng thái | Sự kiện | Điều kiện | Trạng thái kế | Hành động |
|-----------|---------|-----------|---------------|-----------|
| chưa hiện | vào Home | có bản mới, đường dẫn hợp lệ, đồng ý đã xong | đang hiện | hiện popup |
| chưa hiện | vào Home | không có bản mới hoặc cấu hình sai | chưa hiện | không làm gì |
| đang hiện | UPDATE | | đã hiện | mở cửa hàng, đóng popup |
| đang hiện | LATER, back, chạm ra ngoài | | đã hiện | đóng popup |
| đã hiện | vào Home | | đã hiện | không làm gì |
| đã hiện | lần mở mới | | chưa hiện | xóa dấu |

## Tóm tắt quy tắc (suy ra từ rules.md)

Bảy quy tắc: BR8.1 đến BR8.6 cho kiểm tra phiên bản và popup, BR9.1 cho link trong nội dung chia sẻ. BR8.3 dùng chung cho cả hai phần.

## Assumptions & Open Questions

None.
