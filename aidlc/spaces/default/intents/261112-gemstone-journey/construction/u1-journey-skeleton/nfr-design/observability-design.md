# Observability Design — U1 `u1-journey-skeleton`

## Sources

- [nfr] `nfr-requirements/observability-requirements.md` (NFR6.10–NFR6.13), `security-requirements.md` (NFR11.6)
- [Q2] `nfr-design-questions.md`

U1 không có metrics backend, tracing hay alerting: không có Crashlytics, và Analytics để U5 làm. Nguồn quan sát duy nhất là log `debugPrint`, đi qua một điểm vào chung.

## D-O1 — `GjLog`

```
GjLog.info(component, message) / warn(...) / error(..., [Object? err])
→ debugPrint('[GJ][$component][$level] $message${err != null ? ': $err' : ''}')
```

- `GjLog` có một `sink` có thể thay thế. Test thay `sink` bằng list để đếm số dòng (NFR6.10).
- Mặc định `sink = debugPrint`, nên bản release Flutter không in log.
- Tên component cố định: `Firebase`, `LevelConfig`, `Bootstrap`, `Progress`, `Journey`, `Game`.

## D-O2 — Hai dòng tổng kết mỗi lần khởi động (NFR6.12, NFR6.13)

1. `[GJ][LevelConfig][info] config_source=<remote|cached|default>`
2. `[GJ][Bootstrap][info] bootstrap done in <ms>ms (firebase=<ok|failed|timeout>, fetch=<ok|timeout|skipped>)`

## D-O3 — Một dòng cho mỗi nguyên nhân fallback (NFR6.10)

| Nguyên nhân | Component | Level |
|-------------|-----------|-------|
| Firebase init lỗi hoặc timeout | Firebase | error / warn |
| Fetch timeout hoặc lỗi | LevelConfig | warn |
| JSON không hợp lệ (mã lỗi đầu tiên) | LevelConfig | error |
| Mốc không tăng dần (một dòng gộp) | LevelConfig | warn |
| URL bị loại (một dòng cho mỗi level) | LevelConfig | warn |
| Ghi lỗi hoặc dirty retry | Progress | warn |
| Key hỏng (một dòng cho mỗi key) | Progress | warn |
| Vào chế độ chỉ-đọc | Progress | warn |
| Lần ghi đầu tiên bị bỏ qua trong chế độ chỉ-đọc (các lần sau im lặng, Q2) | Progress | warn |
| Resolving hết hạn 3s | Game | warn |

Số dòng kỳ vọng theo kịch bản giữ nguyên như bảng trong `observability-requirements.md`. Unit test kiểm tra bảng đó qua `sink`.

## D-O4 — Không log dữ liệu nhạy cảm (NFR11.6)

Xem D-S5. Message không bao giờ chứa JSON thô hay `FirebaseOptions`.

## SLI/SLO

Không áp dụng ở U1, vì chưa có thu thập số liệu. U5 sẽ bổ sung khi có Analytics.

## Assumptions & Open Questions

None.
