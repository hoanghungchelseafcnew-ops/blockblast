# Scalability Requirements — U1 `u1-journey-skeleton`

## Sources

- [req] `inception/requirements-analysis/requirements.md` NFR6
- [market] `ideation/market-research/market-research-questions.md` Q7 (quy mô trên 100.000 người chơi)
- [feas] `ideation/feasibility/constraint-register.md` C-O2 (chỉ dùng gói miễn phí)
- [contract] `inception/contract-design/contract-summary.md` E1 (fetch 12h)

U1 là app client, không có server riêng. Phần "mở rộng" chỉ liên quan tới quota Remote Config khi có nhiều người chơi, và tới số lượng level trên máy.

| ID | Yêu cầu | Mục tiêu đo được | Cách kiểm |
|----|---------|------------------|-----------|
| NFR6.5 | Lượng gọi Remote Config phù hợp gói miễn phí ở quy mô 100.000 người chơi | `minimumFetchInterval = 12h`, nên mỗi thiết bị fetch **tối đa 2 lần trong 24 giờ**. Không fetch lại khi chuyển level | Review code: chỉ gọi `fetchAndActivate` trong bootstrap |
| NFR6.6 | Kích thước cấu hình bị chặn | JSON `level_config` ≤ 64KB (NFR11.3). 36 level cố định, không tăng | Unit test |
| NFR6.7 | Dữ liệu lưu trên máy không tăng không giới hạn | `completedLevels` ≤ 36 phần tử. Key `progress` ≤ 1KB | Unit test |

## Assumptions & Open Questions

- [assumption] Quota fetch của Remote Config ở gói miễn phí đủ cho quy mô mục tiêu với khoảng fetch 12h. Thông tin này cần kiểm tra lại trên tài liệu Firebase khi gần phát hành.
