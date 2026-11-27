# Thiết kế hiệu năng: u4-update-and-share

Nguồn: `performance-requirements.md`, `tech-stack-decisions.md`, `functional-spec.md`, `contract-summary.md` (hợp đồng 3) và `nfr-design-questions.md`. Không chứa mã triển khai.

| ID | Thiết kế |
|----|----------|
| NFR1.2 | `HomeScreen` gọi kiểm tra phiên bản sau khung hình đầu, không chờ kết quả trước khi cho bấm PLAY. Popup chỉ mở nếu Home vẫn là màn trên cùng khi kết quả về |
| NFR6.2 | `AppUpdateChecker` nhận `AdsSettings` đã đọc ở bootstrap qua constructor, không gọi Remote Config. `ScoreShareService` nhận đường dẫn của nền tảng theo cùng cách |
| NFR2.23 | Đọc phiên bản đang cài và mở đường dẫn đều bọc bắt lỗi; lỗi đọc thì coi như không có bản mới, lỗi mở thì đóng popup |
| BR8.4 | Theo Q1, `AdsService` cho biết số lần mở hiện tại (`appOpenCount`). Phần cập nhật nhớ số đó lúc popup hiện và chỉ hiện lại khi số tăng. Với `NoopAdsService` (số luôn là 0), popup hiện tối đa một lần mỗi lần khởi động. Lần quay lại sau khi mở cửa hàng được báo cho `AdsService.suppressNextResume`, nên không tính là lần mở mới |
| BR8.5 | `AdsService` cho biết luồng đồng ý đã xong chưa qua `bannerChanges` đã có ở `u3-banner`; kiểm tra phiên bản chờ tín hiệu đó khi quảng cáo đang chạy và đồng ý chưa xong |

## Assumptions & Open Questions

None.
