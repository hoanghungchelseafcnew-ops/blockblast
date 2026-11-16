# Team Allocation — Gemstone Journey

## Sources

- `bolt-plan.md` (B1–B6)
- `ideation/intent-capture/stakeholder-map.md`: chỉ có một developer
- Team Formation đã được bỏ qua (dự án một người)
- [prac] `inception/practices-discovery/team-practices.md`

Một **mob** là nhóm cùng làm một Bolt. Dự án này không có nhiều nhóm, nên không cần lập mob hay Program Board (bảng điều phối nhiều nhóm).

| Bolt | Unit | Ai làm | Ai duyệt và kiểm chứng |
|------|------|--------|------------------------|
| B1 | U1 | aidlc-developer-agent (AI), trong phiên này | Developer/Owner: build, test, demo, duyệt checkpoint skeleton |
| B2 | U2 | aidlc-developer-agent (AI) | Developer/Owner |
| B3 | U3 | aidlc-developer-agent (AI) | Developer/Owner |
| B4 | U4 | aidlc-developer-agent (AI) | Developer/Owner (kèm upload ảnh lên Storage) |
| B5 | U5 | aidlc-developer-agent (AI) | Developer/Owner (kiểm tra DebugView) |
| B6 | U6 | aidlc-developer-agent (AI) | Developer/Owner |

## Ghi chú

- **Một phiên, tuần tự.** Không có git nên không dùng worktree hay giao unit cho nhóm (team ownership cần git). Mọi Bolt chạy tuần tự trong một workspace.
- **Agent con không có công cụ file** trong môi trường này. Người dùng đã đồng ý cho conductor tự đóng vai developer (và các vai khác) khi sinh code. Điều này đã được ghi lại ở Reverse Engineering.
- **AI không build hay test được** (máy không có Flutter). Mọi lệnh kiểm chứng do Developer/Owner chạy trên máy khác, rồi dán kết quả (log `flutter analyze`, `flutter test --coverage`, mô tả demo) vào chat để AI xử lý tiếp.
