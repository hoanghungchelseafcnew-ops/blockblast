# Initiative Brief — Gemstone Journey

## Sources

- [intent] `ideation/intent-capture/intent-statement.md`, `stakeholder-map.md`
- [market] `ideation/market-research/competitive-analysis.md`
- [feas] `ideation/feasibility/feasibility-assessment.md`, `constraint-register.md`
- [scope] `ideation/scope-definition/scope-document.md`, `intent-backlog.md`
- [wire] `ideation/rough-mockups/wireframes.md`
- [Q1]–[Q4] `approval-handoff-questions.md`

## Intent & vấn đề

Game Block Puzzle hiện tại thiếu mục tiêu rõ ràng. Giải pháp là nâng cấp thành hành trình 36 level (6 đá quý × 6 công đoạn chế tác), dành cho người chơi casual trên Android/iOS. Thước đo thành công là session time và retention. [intent]

## Xác thực thị trường

Các game tham chiếu (Block Blast!, Block Puzzle Jewel, Woodoku) chủ yếu chơi theo kiểu endless. Hệ thống tiến trình 6 × 6 là điểm khác biệt. Rủi ro là chủ đề đá quý đã có game dùng. Toàn bộ nhận định về đối thủ đều là giả thuyết, chưa được kiểm chứng. [market]

## Khả thi & rủi ro chính

Khả thi, mức rủi ro thấp đến trung bình. Các rủi ro chính và cách giảm thiểu, đã được chấp nhận ở [Q2]:
- Bundle ID iOS không được chứa `_`, nên dùng `com.h2.game.blockBlast`.
- Người chơi mất tiến trình khi gỡ app.
- Remote Config có thể lỗi, khi đó dùng giá trị mặc định trong app.
- Băng thông Firebase Storage ở gói miễn phí có hạn mức.

[feas] [Q2]

Ràng buộc: chỉ có một developer, chỉ dùng gói miễn phí, không có deadline cứng, không phát hành ở EU, đối tượng 13+. [feas]

## Ranh giới scope

- **In:** S-01 đến S-12, trừ S-07. Gồm Classic only, điểm theo level, Remote Config, Analytics, ảnh nền (Storage kèm fallback), Victory, Journey Complete, lưu tiến trình cục bộ, đổi package, offline, asset, ràng buộc kỹ thuật. [scope] [wire] [Q1]
- **Out:** chọn level (S-07/FR-07), Daily Gift, quảng cáo/IAP, đá quý 3D, đồng bộ tiến trình lên cloud, đa ngôn ngữ (giao diện chỉ tiếng Anh), phát hành tại EU. [scope] [wire] [Q1]

## Hình ảnh khái niệm

Gồm các màn: W-1 Home (nút PLAY), W-2 Game kèm W-2a Quit dialog, W-3 Game Over, W-4/W-5 Victory, W-5a Journey Complete, W-6 Settings. Xem wireframes. [wire] [Q3]

## Kế hoạch đội ngũ

Chỉ có một developer, người này cũng tự quyết định scope và priority. Không cần lập mob. Stage Team Formation đã được bỏ qua. [intent]

## Khuyến nghị

**GO**: chuyển sang Inception. [Q4]

## Assumptions & Open Questions

- [assumption] Hành vi của Home sau khi hoàn thành level 36, và việc BACK TO MENU sau khi thua có đặt lại về Rough Stone hay không, sẽ được chốt ở bước Requirements Analysis.
