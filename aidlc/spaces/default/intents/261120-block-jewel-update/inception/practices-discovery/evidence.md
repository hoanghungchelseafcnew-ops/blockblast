# Evidence

## Đã kiểm tra
- `aidlc/spaces/default/memory/team.md` và `project.md` (nền đã được xác nhận trước đó).
- Tài liệu code KB: code-structure, technology-stack, dependencies, code-quality-assessment, architecture, business-overview.
- Repo: không có `.github/` hay pipeline CI/CD; có `.git/`; `analysis_options.yaml` dùng flutter_lints; `coverage/lcov.info` tồn tại.
- Cấu trúc `lib/` theo feature-first; test phản chiếu cấu trúc `lib/`.

## Quyết định phỏng vấn
Q1: có dùng git (B). Q2: giữ nguyên bốn mục còn lại (A). Chi tiết: `practices-discovery-questions.md`.

## Điều chưa chắc
- Đã xác nhận: team có dùng git (Q1 = B); ghi chú cũ "không dùng git" được cập nhật.
- Chưa chạy lại `flutter test --coverage` nên mức coverage hiện tại chưa được kiểm chứng.
- Ba file đóng góp của quality, developer và devsecops do người điều phối viết thay, vì các subagent không có công cụ đọc/ghi file trong phiên này.
