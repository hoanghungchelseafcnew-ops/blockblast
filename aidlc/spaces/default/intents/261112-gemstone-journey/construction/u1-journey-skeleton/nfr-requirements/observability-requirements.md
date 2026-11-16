# Observability Requirements — U1 `u1-journey-skeleton`

## Sources

- [req] `inception/requirements-analysis/requirements.md` NFR6, NFR10
- [contract] `inception/contract-design/contract-summary.md` E1 (`config_source`)
- [fd] `construction/u1-journey-skeleton/functional-design/rules.md` BR1.7, BR7.2
- [Q3] `nfr-requirements-questions.md`

U1 chưa có Analytics (U5) và không thêm Crashlytics (NFR4, Q3). Quan sát ở U1 chỉ qua **log `debugPrint`**, xem được khi chạy debug hoặc profile (`flutter run`, `flutter logs`). Bản release không hiện log.

| ID | Yêu cầu | Mục tiêu đo được | Cách kiểm |
|----|---------|------------------|-----------|
| NFR6.10 | Mọi đường fallback đều để lại log | Mỗi **nguyên nhân** fallback có đúng một dòng log `warn` hoặc `error`. Các nguyên nhân là: Firebase init lỗi hoặc timeout, fetch timeout, JSON không hợp lệ, URL bị loại (một dòng cho mỗi level), ghi lỗi, dirty retry, prefs hỏng (một dòng cho mỗi key), load lỗi. Hai dòng tổng kết NFR6.12 và NFR6.13 luôn có thêm, ở mức `info` | Review code: mọi `catch` có log (DoD-4). Unit test đếm log theo kịch bản bên dưới |
| NFR6.11 | Log có định dạng thống nhất | `[GJ][<component>][<level>] <message>`, với level ∈ {info, warn, error}. Ví dụ: `[GJ][LevelConfig][info] config_source=remote` | Review code |
| NFR6.12 | Nguồn cấu hình được ghi lại khi khởi động | Đúng một dòng `config_source=<remote\|cached\|default>` mỗi lần mở app (BR1.7) | Người dùng xem `flutter logs` ở ca kiểm chứng 2 và 3 |
| NFR6.13 | Bootstrap có log thời gian | Một dòng `bootstrap done in <ms>ms (firebase=<ok\|failed\|timeout>, fetch=<ok\|timeout\|skipped>)` | Người dùng xem log khi đo NFR5.2 |

Không log dữ liệu nhạy cảm: xem NFR11.6 trong `security-requirements.md`.

### Số dòng log kỳ vọng ở bootstrap (cho unit test)

| Kịch bản | warn/error | info |
|----------|-----------|------|
| Online, cấu hình remote hợp lệ | 0 | 2 (`config_source=remote`, `bootstrap done`) |
| Offline lần đầu (fetch timeout) | 1 (fetch timeout) | 2 (`config_source=default`, `bootstrap done`) |
| Thiếu file cấu hình Firebase | 1 (init lỗi) | 2 |
| JSON remote không hợp lệ | 1 (JSON không hợp lệ) | 2 |
| JSON hợp lệ nhưng có 2 URL sai | 2 (mỗi URL một dòng) | 2 |

### Nguồn của các yêu cầu dẫn xuất

NFR6.10–NFR6.13 không có NFR inception riêng về observability. Chúng được dẫn xuất từ DoD-4 (không nuốt lỗi), từ FD BR1.7 (log `config_source`), và từ contract E1. Chúng được xếp dưới NFR6 vì phục vụ việc chẩn đoán các đường dự phòng offline và lỗi.

Gom log qua một hàm duy nhất (ví dụ `GjLog.info/warn/error`) để U5 sau này có thể chuyển một phần log thành event mà không phải sửa nhiều chỗ.

## Assumptions & Open Questions

None.
