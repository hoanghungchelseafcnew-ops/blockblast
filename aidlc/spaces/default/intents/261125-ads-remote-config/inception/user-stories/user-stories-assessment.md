# Đánh giá nhu cầu user stories

## Quyết định

Execute.

## Lý do

Sáng kiến thay đổi trải nghiệm trực tiếp của người chơi (banner, nút reward ads, interstitial, popup cập nhật, link trong nội dung chia sẻ) và có một người dùng thứ hai là nhà phát triển điều chỉnh hành vi qua Firebase. Yêu cầu đã có tiêu chí pass (`requirements.md`), và user stories chuyển chúng thành các lát cắt dọc có tiêu chí chấp nhận Given/When/Then để bước thiết kế và kiểm thử dùng. (`requirements.md`, `scope-document.md`)

## Yếu tố đã xem xét

- Loại dự án: thêm tính năng vào game đã có (brownfield). (`business-overview.md`)
- Phạm vi giao diện: có, ở màn chơi, lớp phủ Game Over, màn Home và nội dung chia sẻ. (`wireframes.md`)
- Độ phức tạp: có logic nghiệp vụ nhiều nhánh (đếm lần mở và lần bấm Start, điều kiện hiện nút reward, thứ tự mạng, so phiên bản). (`requirements.md`)
- Người dùng: người chơi và nhà phát triển vận hành cấu hình. (`stakeholder-map.md`)

## Nơi stories mang lại nhiều giá trị nhất

- Luồng reward ads (FR3), vì có nhiều trạng thái và thay đổi cách game ghi nhận thua.
- Bộ đếm lần mở ứng dụng và lần bấm Start (FR2, FR4), vì dễ hiểu sai khi nào đếm.
- Popup cập nhật và link chia sẻ (FR6, FR7), vì phụ thuộc vào giá trị cấu hình rỗng hoặc sai.
