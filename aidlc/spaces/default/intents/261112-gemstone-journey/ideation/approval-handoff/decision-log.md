# Decision Log — Ideation (Gemstone Journey)

## Sources

- [intent] `ideation/intent-capture/intent-capture-questions.md`
- [market] `ideation/market-research/market-research-questions.md`
- [feas] `ideation/feasibility/feasibility-questions.md`
- [scope] `ideation/scope-definition/scope-definition-questions.md`, `scope-document.md`
- [wire] `ideation/rough-mockups/rough-mockups-questions.md`, `wireframes.md`
- [Q1]–[Q4] `approval-handoff-questions.md`

## Quyết định

| ID | Stage | Quyết định | Nguồn |
|----|-------|-----------|-------|
| D-01 | Intent Capture | 36 level (6 × 6) chủ đề đá quý. Khách hàng là người chơi casual trên Android/iOS. Thước đo: session time và retention | [intent] |
| D-02 | Intent Capture | Chỉ có một stakeholder (developer/owner) và không cần báo cáo. Scope `feature` | [intent] |
| D-03 | Market Research | Tham chiếu Block Blast!, Block Puzzle Jewel, Woodoku. Điểm khác biệt: chủ đề đá quý kèm ảnh nền riêng cho từng level | [market] |
| D-04 | Market Research | Dùng dịch vụ có sẵn: Firebase Remote Config và Firebase Analytics | [market] |
| D-05 | Feasibility | Tiến trình chỉ lưu cục bộ. Phát hành toàn cầu trừ EU. Đối tượng 13+. Chỉ dùng gói miễn phí, không có deadline. Không dùng AWS | [feas] |
| D-06 | Feasibility | Đổi package sang `com.h2.game.block_blast` | [feas] |
| D-07 | Scope Definition | Đợt này chỉ làm theo file requirements. Quảng cáo/IAP để sau | [scope] |
| D-08 | Scope Definition | Ảnh nền lấy từ Firebase Storage, có fallback. Đá quý dùng 2D (3D để sau). iOS dùng ID `com.h2.game.blockBlast`. "Sync" chỉ áp dụng cho analytics và Remote Config | [scope] |
| D-09 | Scope Definition | Thứ tự triển khai theo phụ thuộc (PU-1 → PU-6). Được dùng asset placeholder | [scope] |
| D-10 | Team Formation | Bỏ qua stage này vì chỉ có một developer | [intent] |
| D-11 | Rough Mockups | **Bỏ S-07 (chọn level)**. Home có một nút PLAY vào thẳng level hiện tại. Bỏ Daily Gift | [wire] |
| D-12 | Rough Mockups | Level 36 có màn Journey Complete, không có CONTINUE. Thua thì PLAY AGAIN về Rough Stone. Bấm ← hoặc Back thì hiện dialog xác nhận thoát | [wire] |
| D-13 | Rough Mockups | Giao diện chỉ dùng tiếng Anh. Chỉ hỗ trợ điện thoại, màn hình dọc. Accessibility ở mức cơ bản | [wire] |
| D-14 | Approval & Handoff | Đồng ý với scope, chấp nhận rủi ro và mockup. Quyết định **GO** sang Inception | [Q1] [Q2] [Q3] [Q4] |

## Assumptions & Open Questions

- [assumption] D-11 làm lệch so với FR-07 trong file requirements và S-07 trong scope document đã duyệt. Thay đổi này cần được phản ánh ở bước Requirements Analysis.
