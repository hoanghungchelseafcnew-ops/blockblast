# Kế hoạch chia unit: Quảng cáo và Remote Config

Một unit là một nhóm thành phần được làm và kiểm thử cùng nhau. Đầu vào là `components.md` (12 thành phần), `decisions.md` (ADR-001 đến ADR-007), `requirements.md` và `stories.md` (8 stories, US1.1 đến US6.1). Bước này chỉ mô tả cái gì phụ thuộc cái gì. Thứ tự làm cụ thể sẽ quyết định ở bước lập kế hoạch giao hàng.

Thực hành của đội yêu cầu làm một bản mỏng chạy xuyên suốt trước, gồm đọc cấu hình từ Firebase cộng interstitial (`team-practices.md`). Unit đầu tiên phải là lát cắt nhỏ nhất chạy được từ đầu đến cuối.

## Q1. Cách nhóm stories thành units

- A. Bốn units:
  - `u1-ads-core` (nền tảng và interstitial): US1.1, US1.2, US1.3, US2.1. Đây là bản mỏng chạy xuyên suốt.
  - `u2-reward-ads`: US3.1.
  - `u3-banner`: US4.1.
  - `u4-update-and-share`: US5.1, US6.1.
  - Ưu: unit đầu tiên chạy được end to end, các unit sau độc lập với nhau. Nhược: `u1-ads-core` lớn (độ phức tạp L).
- B. Sáu units: tách nền tảng ra khỏi interstitial, và tách US5.1 khỏi US6.1.
  - Ưu: units nhỏ hơn. Nhược: unit nền tảng không chạy được xuyên suốt nếu đứng riêng, khó làm bản mỏng.
- C. Ba units: gộp banner vào unit reward.
  - Ưu: ít units hơn. Nhược: reward và banner khác nhau về rủi ro (reward đổi luồng thua ván), gộp lại khó tách khi lỗi.
- D. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:A

## Q2. Bản mỏng chạy xuyên suốt nằm ở unit đầu tiên

Unit đầu tiên theo Q1 phương án A chứa: đọc cấu hình, bộ đếm, thứ tự mạng (ít nhất một mạng chạy thật), xử lý đồng ý, và interstitial sau lần bấm Start.

Bạn muốn unit đầu tiên giữ phạm vi này không?

- A. Giữ nguyên: đủ cấu hình, bộ đếm, thứ tự mạng cho ba mạng, đồng ý và interstitial
- B. Làm mỏng hơn: chỉ một mạng quảng cáo (nêu mạng nào ở Other), hai mạng còn lại thêm ở unit sau
- C. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:A

## Q3. Mô hình triển khai

Game là một ứng dụng Flutter duy nhất, và đội phát hành tay.

- A. Một ứng dụng, một lần phát hành, mọi unit nằm chung trong ứng dụng đó (embedded)
- B. Mỗi unit có thể bật hoặc tắt riêng bằng cờ trên Firebase, ngoài `reward_enabled` đã có
- C. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:A

## Q4. Phát triển song song

Có một developer duy nhất, nhưng sơ đồ phụ thuộc vẫn cho thấy unit nào độc lập với unit nào.

- A. Ghi sơ đồ chặt chẽ theo phụ thuộc thật, và ghi rõ các unit có thể làm song song dù chỉ có một người làm lần lượt
- B. Ghi sơ đồ như một chuỗi tuần tự để đơn giản
- C. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:A

## Consolidated Summary Confirmation

- Bốn units: `u1-ads-core` (US1.1, US1.2, US1.3, US2.1), `u2-reward-ads` (US3.1), `u3-banner` (US4.1), `u4-update-and-share` (US5.1, US6.1) (Q1)
- Bản mỏng chạy xuyên suốt: `u1-ads-core` giữ nguyên phạm vi, đủ cấu hình, bộ đếm, thứ tự mạng cho ba mạng, đồng ý và interstitial (Q2)
- Triển khai: một ứng dụng, một lần phát hành, mọi unit nằm chung trong ứng dụng (Q3)
- Sơ đồ phụ thuộc: ghi theo phụ thuộc thật, nêu rõ các unit có thể làm song song dù chỉ một người làm lần lượt (Q4)
- Phụ thuộc dự kiến: `u2`, `u3` và `u4` đều phụ thuộc `u1`; `u2`, `u3`, `u4` độc lập với nhau
- Kiểu unit dự kiến: `u1-ads-core` là `library`, ba unit còn lại là `ui`
- Độ phức tạp dự kiến: `u1` là L, `u2` là M, `u3` là S, `u4` là S

Does this all look correct before I generate the artifact?

- Looks correct
- Request changes

[Answer]: Looks correct
