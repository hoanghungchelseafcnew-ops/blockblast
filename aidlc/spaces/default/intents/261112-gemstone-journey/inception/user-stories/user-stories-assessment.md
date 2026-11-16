# User Stories Assessment — Gemstone Journey

- **Decision**: Execute
- **Rationale**: Thay đổi chủ yếu là các tính năng người chơi nhìn thấy (hành trình level, Victory, Journey Complete, endless, Home, Game Over) và có logic nghiệp vụ không đơn giản (quy tắc khi thua, mở khóa, lưu tiến trình, fallback config). Story kèm acceptance criteria dạng Given/When/Then giúp kiểm thử từng hành vi độc lập.
- **Factors considered**:
  - Loại dự án: brownfield enhancement.
  - Phạm vi UI: 7 màn hoặc overlay (W-1..W-6, W-2a, W-5a).
  - Độ phức tạp: chuyển trạng thái 36 level, chế độ endless, offline.
- **Key areas**: tiến trình level và quy tắc thua (FR2, FR8), Victory và Journey Complete (FR6), endless (FR9), offline và fallback (FR3, FR5, NFR6).
- **Skip?** Không. Có một persona chính (người chơi casual) và một persona phụ (developer/vận hành), nên giữ mức chi tiết vừa phải.
