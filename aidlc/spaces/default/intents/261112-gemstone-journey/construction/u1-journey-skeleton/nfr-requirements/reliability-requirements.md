# Reliability Requirements — U1 `u1-journey-skeleton`

## Sources

- [req] `inception/requirements-analysis/requirements.md` NFR6, FR3, FR8
- [adr] `inception/domain-design/decisions.md` ADR-008, ADR-009, ADR-010
- [fd] `construction/u1-journey-skeleton/functional-design/rules.md` (BR1.4, BR1.5, BR1.8, BR3.1–BR3.3, BR4.3, BR5.9)
- [Q1] `nfr-requirements-questions.md`

| ID | Yêu cầu | Mục tiêu đo được | Cách kiểm |
|----|---------|------------------|-----------|
| NFR6.1 | Chơi được đầy đủ khi không có mạng | Chế độ máy bay từ lần mở đầu tiên: vào Home ≤ 3,5s **không tính thời gian đọc SharedPreferences** (Q1), level 1 target 500, thắng → level 2 | Kiểm chứng end-to-end ca 2 (người dùng) và unit test bootstrap với fake lỗi |
| NFR6.2 | Firebase lỗi hoặc thiếu không làm hỏng app | Thiếu file cấu hình, init lỗi, hoặc init > 1,5s: app vẫn vào Home với `config_source=default`, không có màn lỗi (BR1.5). Lời gọi `Firebase.initializeApp()` được bọc bằng `catch` **mọi loại lỗi** (không chỉ `FirebaseException`) cùng timeout | Unit test bootstrap với fake ném `Exception`, `Error`, và treo. **Android:** người dùng tạm đổi tên `google-services.json` rồi build |
| NFR6.2.1 | iOS thiếu `GoogleService-Info.plist` không crash | Trên iOS, khi plist không có trong target Runner, `initializeApp()` báo lỗi ở phía Dart. Lỗi đó được bắt theo NFR6.2. Không gọi API native nào của Firebase trước khi init thành công | **Chỉ khi có Mac:** người dùng bỏ plist khỏi target rồi chạy. **Không có Mac:** phần kiểm này hoãn sang Build & Test cùng toàn bộ phần kiểm chứng iOS. U1 vẫn hoàn thành theo Android (unit-of-work R-04) |
| NFR6.3 | Tiến trình đã thắng không bị mất trong điều kiện bình thường | Sau khi Victory hiện, tiến trình đã nằm trên đĩa (ghi thành công), hoặc đang dirty và được thử lại tối đa 3 lần cùng một lần flush khi paused (BR3.3) | Unit test thứ tự gọi. Người dùng kill app ở Victory rồi mở lại (ca 4) |
| NFR6.4 | App không bao giờ kẹt | Splash ≤ 3,5s cho phần Firebase. Resolving ≤ 3s. Không có thao tác nào chờ vô hạn, **trừ** đọc SharedPreferences (Q1, rủi ro chấp nhận) | Unit test với fake treo |
| NFR6.8 | Không ghi dữ liệu mặc định đè lên dữ liệu thật | **Hàng đợi ghi chỉ bắt đầu chạy sau khi `load()` kết thúc.** Mọi lời gọi ghi trước đó được xếp hàng và chờ, không bị từ chối. Đây là hành vi duy nhất (xử lý góp ý R-12) | Unit test: gọi `savePlayerProgress` trước khi `load()` xong thì việc ghi chỉ chạy sau `load()` và sau khi cache đã có dữ liệu thật |
| NFR6.8.1 | `load()` lỗi thì không ghi đè tiến trình | Nếu đọc prefs ném lỗi (PlatformException, I/O): thử đọc lại **một lần** ngay. Vẫn lỗi thì repository vào **chế độ chỉ-đọc** cho cả phiên. Game chơi với cache mặc định (level 1) trong bộ nhớ, **mọi lệnh ghi bị bỏ qua kèm log `warn`**, và dữ liệu trên đĩa giữ nguyên. Lần mở app sau thử đọc lại từ đầu | Unit test với fake prefs ném lỗi 1 lần (đọc lại thành công) và ném lỗi 2 lần (chế độ chỉ-đọc, không có lệnh ghi nào chạm đĩa) |
| NFR6.9 | Cấu hình hỏng không lây sang phiên sau | Cấu hình đã activate nhưng không hợp lệ thì dùng mặc định, và lần fetch hợp lệ kế tiếp sẽ ghi đè (BR1.4) | Unit test |

## Graceful degradation

| Sự cố | Hành vi |
|-------|---------|
| Không có mạng | Dùng cached hoặc default, chơi bình thường |
| Firebase init lỗi hoặc chậm | Dùng default trong phiên này |
| JSON cấu hình sai | Dùng default, log lỗi |
| URL ảnh sai | Bỏ URL của level đó (U1 chưa dùng URL) |
| Ghi prefs lỗi | Giữ trong cache, dirty, thử lại |
| Đọc prefs lỗi | Đọc lại 1 lần, vẫn lỗi thì chế độ chỉ-đọc cả phiên (NFR6.8.1) |
| Prefs hỏng | Dùng mặc định cho key hỏng, log |

## Assumptions & Open Questions

- [assumption] Đọc SharedPreferences luôn hoàn tất (Q1). Nếu treo thì Splash treo theo. Rủi ro này được chấp nhận vì SharedPreferences là bộ nhớ cục bộ.
