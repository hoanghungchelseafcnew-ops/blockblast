**Collaborator:** aidlc-quality-agent

> Conductor viết thay, đóng vai quality agent (agent con không có công cụ file; người dùng đã đồng ý). Chỉ dựa trên bản nháp stories.md, personas.md, file Q&A và requirements.md, không xem đóng góp của agent khác.

## Contribution

- **Khả năng kiểm thử:** phần lớn AC viết theo Given/When/Then, có giá trị cụ thể (500, 1.200, Amethyst · Shaping) nên kiểm thử được. Một số AC lại là câu khẳng định trạng thái, không có Given/When: AC2.1.2, AC3.2.2, AC3.4.1, AC5.4.2, AC8.1.1, AC8.4.2, AC8.6.1. Đây là các ràng buộc tĩnh, kiểm tra được bằng grep, review code hoặc widget test. Chấp nhận được, nhưng nên ghi rõ cách kiểm tra.
- **Ca biên còn thiếu:**
  - AC2.3.1: đạt target **đúng bằng** (score = target) cũng phải thắng. Ký hiệu ≥ đã bao gồm trường hợp này, nhưng nên có test riêng.
  - US1.4: thua ở level con đầu tiên của đá quý thứ 2 (Amethyst · Rough Stone). Rose Quartz phải vẫn hoàn thành nguyên vẹn.
  - US4.2: QUIT khi score endless = 0 thì lưu 0, không lỗi.
- **Kiểm thử bằng tay:** AC6.4.3 (DebugView), AC8.1.2/AC8.2.2 (build), AC8.6.3 (profile FPS) do người dùng chạy. Nên gom thành một checklist kiểm tra tay để Build & Test dùng lại.
- **Coverage 80%:** cần sớm có test cho `BoardLogic` và `BlockGenerator` hiện có. Đây là phần dễ tăng coverage nhất.

## Positions

- AGREE: AC dạng Given/When/Then với giá trị cụ thể.
- OBJECT: thêm 3 ca biên ở trên vào AC (knowledge dispute, lead có thể tự bổ sung).
