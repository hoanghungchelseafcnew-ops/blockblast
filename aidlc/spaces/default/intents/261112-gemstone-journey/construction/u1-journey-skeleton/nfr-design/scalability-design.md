# Scalability Design — U1 `u1-journey-skeleton`

## Sources

- [nfr] `nfr-requirements/scalability-requirements.md` (NFR6.5–NFR6.7)
- [contract] `inception/contract-design/contract-summary.md` E1, E3

App client không có server, nên không có horizontal scaling hay load balancing. Thiết kế chỉ cần giữ ba thứ trong giới hạn: lượng gọi tới dịch vụ ngoài, kích thước dữ liệu, và dữ liệu lưu trên máy.

## D-SC1 — Gọi Remote Config ít nhất có thể (NFR6.5)

- `fetchAndActivate` chỉ được gọi trong `AppBootstrap`, một lần mỗi lần mở app.
- `minimumFetchInterval = 12h`. Trong khoảng này, SDK trả về bản cache mà không gọi mạng. Kết quả là mỗi thiết bị gọi mạng tối đa 2 lần trong 24 giờ.
- Không có nút "reload config" và không fetch lại khi chuyển level.

## D-SC2 — Giới hạn kích thước (NFR6.6, NFR6.7)

- JSON cấu hình ≤ 65.536 byte (D-S1).
- `LevelCatalog` cố định 36 phần tử.
- Key `progress` lưu dạng JSON gọn: `completedLevels` tối đa 36 số nguyên, nên luôn dưới 1KB.

## Assumptions & Open Questions

- [assumption] Quota Remote Config ở gói miễn phí đủ dùng (kế thừa từ NFR Requirements). Cần kiểm tra trước khi phát hành.
