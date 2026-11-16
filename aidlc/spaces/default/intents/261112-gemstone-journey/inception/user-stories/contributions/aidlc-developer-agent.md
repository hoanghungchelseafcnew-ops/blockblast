**Collaborator:** aidlc-developer-agent

> Conductor viết thay, đóng vai developer agent (agent con không có công cụ file; người dùng đã đồng ý). Chỉ dựa trên bản nháp stories.md, personas.md, file Q&A và requirements.md, không xem đóng góp của agent khác.

## Contribution

- **Khả thi:** mọi story đều làm được với codebase hiện tại (`_GameScreenState`, `BoardLogic`, `AudioController`, `ThemeManager`). Những chỗ cần thay đổi nhiều nhất:
  - US2.1: gỡ Time Attack khoảng 7 chỗ.
  - US5.4: thay `ThemeManager` bằng màu theo đá quý. `BoardCell` và `DraggableBlock` đang `watch` theme.
  - US8.5: tách state sang `GameController`.
- **Kích thước story:**
  - US8.5 quá lớn (tách kiến trúc và đạt coverage 80% toàn bộ code). Nên coi đây là tiêu chí xuyên suốt hoặc Definition of Done, không phải một story riêng.
  - US7.2 gắn Firebase Storage. Requirements chỉ cho thêm `cached_network_image`, nên URL lấy trực tiếp từ Remote Config và không cần `firebase_storage` SDK. Cần ghi rõ để không vi phạm NFR4.
- **Phụ thuộc kỹ thuật:** US6.1 (config service) và US1.x (progress repository) là nền tảng. US8.1/US8.2 (đổi package) nên làm trước khi tạo Firebase project, vì `google-services.json` gắn với package ID.
- **Rủi ro test:**
  - AC1.6.1 ("kill app ở Victory") không tự động hóa được bằng `flutter test`. Nên đổi thành: "tiến trình được ghi vào prefs trước khi Victory hiển thị", kiểm tra bằng unit test, còn kill app do người dùng thử tay.
  - Tương tự, AC7.2.3 ("không có request mạng") nên kiểm tra bằng mock cache manager.

## Positions

- AGREE: mọi story là Must theo lựa chọn của người dùng.
- OBJECT: AC1.6.1 và AC7.2.3 cần được diễn đạt lại để kiểm thử tự động được (knowledge dispute, lead có thể tự sửa).
- OBJECT: US7.2 cần nói rõ không dùng `firebase_storage` SDK, chỉ dùng URL công khai kèm `cached_network_image`.
