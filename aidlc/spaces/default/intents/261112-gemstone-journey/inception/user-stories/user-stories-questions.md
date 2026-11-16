# User Stories Plan & Questions — Gemstone Journey

## Kế hoạch đề xuất

- **Persona:**
  - P1 "Casual Player": người chơi casual trên điện thoại.
  - P2 "Developer/Owner": người cấu hình mốc điểm qua Remote Config và theo dõi analytics.
- **Định dạng:** "As a [persona], I want [goal], so that [benefit]", tuân theo INVEST. Acceptance criteria dạng Given/When/Then, có ID `ACx.y.z`.
- **Ưu tiên:** MoSCoW, dựa trên requirements.
- **Cách chia:** theo epic hoặc khu vực tính năng. Dự kiến khoảng 8 epic và 20–25 story.

---

## Q1. Chia story theo cách nào?

A. Theo epic/tính năng: Journey & Progress, Gameplay, Victory, Endless, Home & Settings, Config & Analytics, Assets & Offline, Platform
B. Theo luồng người chơi (mở app → chơi → thắng/thua → tiếp tục)
C. Theo persona
X. Other (please specify)

[Answer]:A

---

## Q2. Có viết story cho persona Developer/Owner không (cấu hình Remote Config, xem analytics, đổi package)?

A. Có. Viết story riêng cho P2 (Remote Config, Analytics, Platform)
B. Không. Các phần đó chỉ là technical task, chỉ viết story cho người chơi
X. Other (please specify)

[Answer]:A

---

## Q3. Mức chi tiết của story?

A. Vừa phải: mỗi story có 2–5 acceptance criteria, khoảng 20–25 story
B. Chi tiết: tách nhỏ, mỗi story có 1–3 AC, khoảng 35–45 story
C. Gọn: khoảng 10–12 story lớn, mỗi story nhiều AC
X. Other (please specify)

[Answer]:B

---

## Q4. Ưu tiên MoSCoW cho các phần "phụ"?

A. Must: hành trình level, quy tắc thua, Victory, lưu tiến trình, offline, Remote Config. Should: Analytics, endless, màu đá quý, SHARE. Could: preload ảnh, nén ảnh
B. Tất cả FR trong requirements đều là Must
C. Bạn tự quyết, tôi duyệt ở gate
X. Other (please specify)

[Answer]:B

---

Trả lời trong chat được, ví dụ: "1A 2A 3A 4A"

---

# Follow-up (từ mob review)

## Q5. Trên màn Victory (level con và Bling), nút CONTINUE xuất hiện khi nào?

Design đề xuất: hiện ngay để không chặn người chơi muốn đi nhanh.

A. Hiện ngay khi vào màn Victory. Hiệu ứng vẫn chạy song song
B. Chỉ hiện sau khi hiệu ứng chính (2–3 giây) kết thúc
C. Hiện sau khoảng 1 giây (cân bằng giữa hai cách trên)
X. Other (please specify)

[Answer]:A

---

## Consolidated Summary Confirmation

Does this all look correct before I generate the artifact?

- Q1: Chia theo epic/tính năng (8 epic)
- Q2: Có story riêng cho persona Developer/Owner (Remote Config, Analytics, Platform)
- Q3: Chi tiết: tách nhỏ, mỗi story 1–3 AC, khoảng 35–45 story
- Q4: Tất cả FR trong requirements đều là Must Have
- Q5: Nút CONTINUE trên Victory hiện ngay, hiệu ứng chạy song song

- Looks correct
- Request changes

[Answer]: Looks correct
