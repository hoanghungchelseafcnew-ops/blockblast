# Phân công: Quảng cáo và Remote Config

Một Bolt là một lượt xây dựng cho một phần việc, kết thúc bằng một thứ chạy được (xem `bolt-plan.md`). Một mob là nhóm cùng làm một Bolt. Nguồn: `bolt-plan.md`, `team-practices.md` và `delivery-planning-questions.md`.

Bước Team Formation đã được bỏ qua vì dự án chỉ có một developer, nên không có mob nhiều người. Theo quy tắc mặc định, mọi Bolt do aidlc-developer-agent (AI) thực hiện, còn bạn là người duyệt và là người chạy lệnh kiểm tra. (`team-practices.md`)

| Bolt | Unit | Người thực hiện | Người duyệt và kiểm tra |
|------|------|-----------------|-------------------------|
| B1 | `u1-ads-core` | aidlc-developer-agent | Bạn: duyệt điểm kiểm tra, chạy `flutter analyze` và `flutter test --coverage` |
| B2 | `u2-reward-ads` | aidlc-developer-agent | Bạn |
| B3 | `u3-banner` | aidlc-developer-agent | Bạn |
| B4 | `u4-update-and-share` | aidlc-developer-agent | Bạn |

Quy ước làm việc: AI sinh code và test, bạn tự commit và tự chạy lệnh kiểm tra rồi báo kết quả. Nhánh và merge theo mặc định của tổ chức (nhánh ngắn hạn, gộp vào `main`). (`team-practices.md`)

Bố trí người làm: một phiên làm việc, lần lượt từng Unit. Không có đội sở hữu từng unit. (Q8 của delivery-planning)

## Assumptions & Open Questions

None.
