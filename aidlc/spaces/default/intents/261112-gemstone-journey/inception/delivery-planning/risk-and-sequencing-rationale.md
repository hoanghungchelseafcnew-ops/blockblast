# Risk & Sequencing Rationale — Gemstone Journey

## Sources

- `bolt-plan.md`, [units] `unit-of-work-dependency.md`
- [feas] `ideation/feasibility/raid-log.md`
- [prac] `inception/practices-discovery/team-practices.md`
- [Q1] `delivery-planning-questions.md`

## Heuristic

Thứ tự được chọn theo hai bước:
1. **Walking skeleton trước** (Cockburn). Walking skeleton là phiên bản tối giản chạy xuyên suốt, làm đầu tiên để chứng minh các phần ghép được với nhau. Bước này bắt buộc theo practices.
2. **Ưu tiên giá trị** cho phần còn lại (Cohn, value-first): sắp theo giá trị người chơi cảm nhận được, trong giới hạn của DAG. [Q1]

Không dùng chấm điểm WSJF (Weighted Shortest Job First, xếp hạng theo giá trị và độ khẩn cấp chia cho kích thước công việc). Với 6 unit, một người làm và DAG gần như tuyến tính, thứ tự gần như đã được DAG quyết định sẵn.

## Vì sao B1 (skeleton) đi đầu

- B1 gom các rủi ro lớn nhất ([feas] R2, R4 cùng refactor ADR-001): đổi package/bundle ID, tích hợp Firebase, refactor `_GameScreenState`. Thất bại sớm thì rẻ nhất.
- Không có git, nên cần một điểm đã chạy được sớm để các Bolt sau chỉ thêm vào, không phải sửa nền.

## Vì sao B2 → B3 trước B4

- B2 (quy tắc thua/mở khóa) và B3 (Victory, âm thanh) tạo ra **vòng chơi hoàn chỉnh**: thắng, thua, ăn mừng. Đây là lõi giá trị giải quyết vấn đề "game thiếu mục tiêu rõ ràng".
- B4 (giao diện, ảnh nền) đẹp hơn nhưng không đổi luật chơi. B4 cũng cần người dùng upload ảnh lên Storage. Đặt sau giúp người dùng có thời gian chuẩn bị.

## Vì sao B5, B6 cuối

- B5 (analytics) chỉ có giá trị khi đã có người chơi thật. B5 cần B2 để có event thua.
- B6 (endless) chỉ dành cho người đã chơi hết 36 level, nên có ít người dùng nhất ở giai đoạn đầu.

## Rủi ro chấp nhận khi chọn thứ tự này

| Rủi ro | Ảnh hưởng | Giảm thiểu |
|--------|-----------|-----------|
| B4 đến muộn, nên U1–U3 phải dùng màu tạm (`ThemeManager`, `VictoryColors`) | Khi U4 thay màu sẽ sửa lại file của U1 và U3 | Quy ước màu ở `unit-of-work.md` gom mọi chỗ cần thay về vài file. U4 chịu coverage cho các file đó |
| B1 lớn (L) | Skeleton trễ thì mọi thứ trễ | Chia 4 bước, mỗi bước build được, có 2 lần sao lưu |
| Không có git | Không quay lại được khi sinh code sai | Zip sao lưu trước B1 và trước bước tách logic. Khuyến nghị zip sau mỗi Bolt được duyệt |
| AI không build được | Lỗi biên dịch chỉ lộ ra khi người dùng build | Mỗi bước nhỏ, người dùng build ngay. `flutter analyze` là một phần của DoD |

## Điều tôi lo nhất

Refactor `_GameScreenState` ở bước 2 của B1 có thể làm hỏng kéo-thả hoặc tính điểm. Vì không có git, nếu hỏng thì phải khôi phục từ bản zip. Cách giảm rủi ro: unit test `TurnResolver` đối chiếu đúng công thức hiện tại (US2.2), và người dùng chơi thử ngay sau bước 2.
