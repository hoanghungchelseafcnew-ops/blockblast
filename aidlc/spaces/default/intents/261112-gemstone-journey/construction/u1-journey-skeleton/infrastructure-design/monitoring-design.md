# Monitoring Design — U1 `u1-journey-skeleton`

## Sources

- [nfrd] `construction/u1-journey-skeleton/nfr-design/observability-design.md` (D-O1..D-O4)
- [nfr] `nfr-requirements/observability-requirements.md`
- [Q1] `infrastructure-design-questions.md` (một Firebase project)

U1 không có backend metrics, Crashlytics hay Analytics (Analytics thuộc U5). Giám sát ở U1 gồm hai nguồn: log `debugPrint` khi chạy debug hoặc profile, và trang Remote Config trên Firebase console.

## Metrics & KPIs

| Metric | Source | Threshold | Why it matters |
|--------|--------|-----------|----------------|
| `bootstrap done in <ms>` | Log `[GJ][Bootstrap][info]` | ≤ 3500ms cho phần Firebase | Kiểm NFR5.2 |
| `config_source` | Log `[GJ][LevelConfig][info]` | `remote` khi online sau lần fetch đầu tiên | Phát hiện việc quên publish `level_config` |
| Số dòng `warn`/`error` lúc khởi động | Log | 0 khi online với cấu hình hợp lệ | Kiểm NFR6.10 |
| Frame time khi kéo khối | Flutter DevTools (profile mode) | Không có chuỗi > 3 frame liên tiếp vượt 16ms | Kiểm NFR5.1 |

## Alerts

| Alert | Condition | Severity | Routes to |
|-------|-----------|----------|-----------|
| — | Không có hệ thống alert ở U1 | — | Người dùng tự xem log khi kiểm chứng. U5 bổ sung nhờ Analytics |

## SLIs / SLOs

| SLI | SLO target | Measurement window |
|-----|-----------|--------------------|
| Không áp dụng ở U1 (chưa thu thập số liệu từ thiết bị) | — | — |

## Logs & Tracing

- Cách xem log: `flutter run` hoặc `flutter logs` trên thiết bị hay emulator. Lọc theo tiền tố `[GJ]`.
- Không có tracing. Bản release không in log.
- Dashboard: không có ở U1.

## Assumptions & Open Questions

None.
