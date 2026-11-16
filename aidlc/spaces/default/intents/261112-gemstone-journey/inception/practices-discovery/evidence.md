# Evidence — Practices Discovery

> Do agent con không có công cụ file, conductor tự đóng cả 4 vai (lead và 3 support) với sự đồng ý của người dùng. Mỗi vai support chỉ dựa trên bản nháp của lead và codekb.

## Lead (aidlc-pipeline-deploy-agent)

- `git log` báo "not a git repository". Không có `.github/`, `codemagic.yaml`, `fastlane/` hay `Makefile`.
- Đã đọc codekb: `code-quality-assessment.md`, `technology-stack.md`, `code-structure.md`, `architecture.md`.

## Quality (`contributions/aidlc-quality-agent.md`)

- Test hiện tại hỏng, coverage bằng 0, máy này không có `flutter`.
- Phản đối ngưỡng 80% cho toàn bộ code. Người dùng vẫn chọn toàn bộ codebase (Q4=B), nên ghi nhận phản đối này như rủi ro về khối lượng công việc.

## Developer (`contributions/aidlc-developer-agent.md`)

- Đề xuất bắt buộc tách controller. Người dùng đồng ý (Q7=A).
- Đề xuất không nuốt lỗi. Người dùng không chọn làm ràng buộc cứng, nên đây chỉ là khuyến nghị. Quy tắc giai đoạn construction ("silent failures are not acceptable") vẫn áp dụng.

## DevSecOps (`contributions/aidlc-devsecops-agent.md`)

- Đề xuất cấm ghi công khai Firebase Storage thành ràng buộc cứng. Người dùng không chọn (Q8 chỉ chọn A), nên chưa thành ràng buộc. Ghi nhận là rủi ro bảo mật cần xử lý ở NFR Design.

## Quyết định phỏng vấn

| Q | Quyết định |
|---|-----------|
| Q1, Q9 | Không dùng git, chấp nhận rủi ro (lệch khỏi `org.md` → Way of Working) |
| Q2 | Có walking skeleton |
| Q3 | Test-after |
| Q4 | Coverage 80% trên toàn bộ codebase |
| Q5 | Build và phát hành thủ công |
| Q6, Q10 | `flutter analyze` + `flutter test`. Người dùng tự chạy trên máy khác |
| Q7 | Bắt buộc tách controller/service |
| Q8 | ALWAYS: UI chỉ dùng tiếng Anh |

## Điểm chưa chắc chắn

- Không có git, nên Construction phải chạy trực tiếp trên workspace, không dùng worktree.
- AI không chạy được build/test, nên mọi bước verify phụ thuộc vào kết quả người dùng báo lại.
