# Security Design — U1 `u1-journey-skeleton`

## Sources

- [nfr] `nfr-requirements/security-requirements.md` (NFR11.1–NFR11.6, NFR4.1)
- [fd] `functional-design/rules.md` (BR1.2, BR1.3, BR3.1, BR3.5)
- [adr] `inception/domain-design/decisions.md` ADR-006

App không có xác thực và phân quyền: không có tài khoản, không có server. Thiết kế bảo mật tập trung vào bốn việc: kiểm tra đầu vào không tin cậy, không để lộ secret, không log dữ liệu nhạy cảm, và giữ bề mặt phụ thuộc nhỏ.

## D-S1 — Validator cấu hình (NFR11.3)

`LevelConfigValidator.validate(String raw) → ValidationResult { config?, errors[], warnings[] }` là hàm thuần, không throw.

1. `utf8.encode(raw).length > 65536` thì lỗi `too_large`.
2. Dùng `jsonDecode` trong `try`. Lỗi thì `parse_error`.
3. Kiểm tra kiểu từng bước, không ép kiểu. Ví dụ `target_score is int`. Số thực hoặc chuỗi đều là lỗi.
   - `version` là int ≥ 1.
   - `levels` là map có đúng 6 khóa thuộc tập gem.
   - Mỗi gem có `order` 1..6 không trùng, `name` là string, `sub_levels` có đúng 6 khóa thuộc tập sub.
   - Mỗi sub có `order` 1..6 không trùng trong gem, `target_score` là int trong 1..10.000.000.
4. Chỉ cần một lỗi là trả về `config = null`, và caller dùng `DefaultLevelConfig`.
5. Không tăng dần: chỉ thêm vào `warnings`.
6. Trường lạ bị bỏ qua.

## D-S2 — Validator URL (NFR11.4)

`ImageUrlPolicy.isAllowed(String? s) → bool`:

```
if s == null || s.trim().isEmpty → false
u = Uri.tryParse(s.trim()); if u == null → false
u.scheme == 'https' && u.userInfo.isEmpty && (!u.hasPort || u.port == 443) && u.fragment.isEmpty
host = u.host.toLowerCase()
host == 'firebasestorage.googleapis.com' || (host.endsWith('.firebasestorage.app') && host.length > '.firebasestorage.app'.length)
decoded = Uri.decodeFull(u.path); !decoded.split('/').contains('..')
```

- Kiểm tra `..` chạy trên path **sau khi** giải mã phần trăm, nên `%2e%2e` cũng bị loại (góp ý R-13).
- Không ghim bucket (Q2 của NFR Requirements, rủi ro chấp nhận, chủ sở hữu U4).
- Áp dụng cho cả nguồn `remote` lẫn `cached`.

## D-S3 — Secret và file cấu hình (NFR11.1, NFR11.2)

- Không có `FirebaseOptions` trong Dart. `Firebase.initializeApp()` không truyền tham số, Firebase đọc từ file cấu hình gốc của nền tảng.
- `google-services.json` chỉ nằm ở `android/app/`, `GoogleService-Info.plist` chỉ ở `ios/Runner/`.
- Kiểm tra trước khi xong U1: grep `AIza|apiKey|api_key` trong `lib/` phải cho 0 kết quả.

## D-S4 — Dữ liệu cục bộ bị sửa tay (NFR11.5)

Parser của `progress` đọc theo thứ tự:
1. `currentLevelIndex`: không phải int hoặc ngoài 1..36 thì thay bằng 1.
2. `completedLevels`: chỉ giữ các int trong 1..36.
3. `highestLevelReached`: không phải int hoặc ngoài 1..36 thì thay bằng 1, sau đó lấy `max(highest, current)`.
4. `tutorial_completed`: không phải bool thì thay bằng false.

Mỗi lần thay giá trị đều log `warn` một dòng cho key đó.

## D-S5 — Log an toàn (NFR11.6)

`GjLog` không bao giờ nhận toàn bộ JSON cấu hình. `LevelConfigService` chỉ log `version`, số gem, số level và mã lỗi đầu tiên (ví dụ `invalid target_score at amethyst.shaping`). Không log `FirebaseOptions` hay nội dung file cấu hình.

## D-S6 — Phụ thuộc (NFR4.1)

Chỉ thêm `firebase_core` và `firebase_remote_config` với ràng buộc `^`. Fake viết tay đặt trong `test/fakes/`.

## Assumptions & Open Questions

None.
