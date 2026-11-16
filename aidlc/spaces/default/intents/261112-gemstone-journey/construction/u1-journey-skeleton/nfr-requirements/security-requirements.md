# Security Requirements — U1 `u1-journey-skeleton`

## Sources

- [req] `inception/requirements-analysis/requirements.md` NFR4, NFR11
- [adr] `inception/domain-design/decisions.md` ADR-006
- [contract] `inception/contract-design/contract-summary.md` E1
- [fd] `construction/u1-journey-skeleton/functional-design/rules.md` BR1.2, BR1.3, BR6.2
- [Q2] `nfr-requirements-questions.md`
- Phase rules (construction): không hardcode secret, validate input ở ranh giới hệ thống

## Mô hình mối đe dọa (U1)

App chạy hoàn toàn phía client và không có tài khoản người dùng. U1 có hai đầu vào không tin cậy:
- **JSON `level_config` từ Remote Config.** Chỉ developer sửa được, nhưng vẫn có thể bị cấu hình sai hoặc tài khoản Firebase bị chiếm.
- **Dữ liệu SharedPreferences trên máy.** Người dùng root máy có thể sửa được.

Dữ liệu được bảo vệ chỉ là tiến trình game. Dữ liệu này không nhạy cảm, nên mục tiêu là app **không crash và không bị điều khiển sai** khi đầu vào xấu.

| ID | Yêu cầu | Mục tiêu đo được | Cách kiểm |
|----|---------|------------------|-----------|
| NFR11.1 | Không có secret trong mã Dart | Grep `AIza`, `apiKey`, `api_key` trong `lib/` cho 0 kết quả. Firebase đọc cấu hình từ `google-services.json` và `GoogleService-Info.plist` | Review và grep |
| NFR11.2 | File cấu hình Firebase không bị phát tán | Hai file chỉ nằm ở `android/app/` và `ios/Runner/`, không chép vào `lib/` hay `assets/`. Nếu sau này dùng git: thêm vào `.gitignore` | Review cấu trúc thư mục |
| NFR11.3 | JSON Remote Config là đầu vào không tin cậy | Validate toàn bộ theo BR1.2 (kiểu, khoảng 1..10M, đủ 36 cặp). Parser không throw ra ngoài. JSON lớn hơn **65.536 byte (mã hóa UTF-8)** bị coi là hỏng | Unit test với JSON lỗi, thiếu, thừa, số âm, chuỗi thay số, 100KB |
| NFR11.4 | URL ảnh chỉ trỏ tới Firebase Storage | Validate theo BR1.3. **Được phép:** scheme `https`; host `firebasestorage.googleapis.com` hoặc `<nhãn>.firebasestorage.app`; port rỗng hoặc 443; mọi path; query (download URL cần `?alt=media&token=...`). **Bị cấm:** scheme khác, userinfo, port khác, fragment (`#...`), host khác hoặc giả hậu tố. Path traversal (`..`) không tạo rủi ro vì host đã cố định, nhưng URL có `..` sau khi chuẩn hóa vẫn bị loại cho đơn giản. **Không ghim bucket** của dự án (Q2) | Unit test với: `http://…`, `https://user@firebasestorage.googleapis.com/…`, `https://evilfirebasestorage.app/…`, `https://x.firebasestorage.app:8443/…`, `https://firebasestorage.googleapis.com/v0/b/a/o/x.jpg?alt=media#f`, `https://firebasestorage.googleapis.com/v0/b/a/o/../x`, và một URL hợp lệ có `?alt=media&token=t` |
| NFR11.5 | Dữ liệu prefs bị sửa tay không làm crash | BR3.1, BR3.5: sai kiểu hoặc ngoài khoảng thì dùng mặc định kèm log. `currentLevelIndex` ngoài 1..36 hoặc sai kiểu thì về 1 **trước khi** tính `highestLevelReached` (góp ý R-11) | Unit test với `SharedPreferences.setMockInitialValues` chứa giá trị rác |
| NFR4.1 | Hạn chế bề mặt phụ thuộc | U1 chỉ thêm `firebase_core` và `firebase_remote_config`. Không thêm dev dependency mới: fake và mock viết tay | Diff `pubspec.yaml` |
| NFR11.6 | Không log dữ liệu nhạy cảm | Không log toàn bộ JSON cấu hình hay giá trị file cấu hình Firebase (API key, project id). Chỉ log tóm tắt: version, số level, lỗi đầu tiên | Review code |

## Rủi ro chấp nhận

- **Bucket không được ghim (Q2, góp ý R-13).** Nếu Remote Config bị sửa, URL có thể trỏ tới bucket Firebase của người khác. Hậu quả chỉ là hiển thị ảnh lạ, vì ảnh không thực thi được. URL chỉ được dùng từ U4. **Chủ sở hữu: U4 (`u4-visual-theme`).** Điều kiện xem lại: NFR Requirements của U4 phải xác nhận lại rủi ro này (giữ hoặc ghim bucket) trước khi tải ảnh mạng đầu tiên.
- Người dùng root máy có thể sửa tiến trình của chính mình. Chấp nhận được, vì game không có bảng xếp hạng.

## Assumptions & Open Questions

None.
