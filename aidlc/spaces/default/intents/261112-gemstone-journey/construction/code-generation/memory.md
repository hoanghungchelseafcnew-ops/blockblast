<!-- INVARIANT: examples are single-line HTML comments so a fresh template parses to total=0 (MEMORY_EMPTY). Do NOT un-comment or split across lines. t100 guards this. -->
> This file is kept up to date automatically while the stage runs. Add observations at the review step, not by editing here directly.

## Interpretations
<!-- example: 2026-05-29T10:14:32Z — chose REST over GraphQL; the consuming team only needs CRUD, revisit if subscriptions land -->

## Deviations
- 2026-11-17T08:55:00Z — u1: thêm ProgressRepository.abandonLoad() ngoài plan để hạn chót bootstrap không làm ghi đè tiến trình thật bằng level 1; adapter nền tảng (DeviceGameFeedback, PlatformScoreShareService) chưa có test nên có thể dưới 80% coverage, đã ghi vào code-summary.md.
- 2026-11-18T13:05:00Z — u1: review của kiến trúc sư bị tắt (`review none`) theo yêu cầu người dùng vì subagent trong phiên Kiro không có công cụ đọc/ghi file; checkpoint skeleton vẫn được kiểm chứng thật bằng lệnh đã duyệt.
- 2026-11-18T13:05:00Z — u1: Flutter SDK bản Windows không chạy được trong WSL (script CRLF, exit 127); đã cài Flutter Linux 3.41.5 (khớp bản Windows của người dùng) tại ~/flutter, symlink vào ~/.local/bin. Bản 3.50.0 làm `flutter analyze` đỏ vì `material.dart` bị deprecated, nên phải khóa đúng 3.41.5.
- 2026-11-18T14:10:00Z — u2: developer subagent trả NO-TOOLS; người dùng chọn để orchestrator tự viết code U2 theo kế hoạch đã duyệt. AC2.1.2 (grep `high_score_time` = 0 trong lib/) mâu thuẫn với E3 (phải xóa key đó): tên key được ghép từ hai phần trong `ProgressRepository.legacyKeys`, có chú thích. `theme_index`/`last_login_date` chưa gỡ vì ThemeManager và Daily Gift vẫn dùng tới U4.
- 2026-11-18T16:30:00Z — u4: người dùng từ chối gỡ `google_fonts`, chọn chỉ thêm `cached_network_image`; font vẫn đóng gói offline. `audio_controller.dart` 66.7% (chỉ bị format; U3 viết lại). `cached_network_image` không export BaseCacheManager nên AC7.2.3 kiểm qua seam NetworkImageFactory. File test mới thường lỗi ở lần load đầu trên ổ /mnt/d, chạy lại thì xanh.
<!-- example: 2026-05-29T10:14:32Z — skipped the optional caching layer the stage prose suggested; the dataset is small enough that it adds risk -->

## Tradeoffs
<!-- example: 2026-05-29T10:14:32Z — picked TDD over BDD this run; the team is unit-first and the domain is well-understood -->

## Open questions
<!-- example: 2026-05-29T10:14:32Z — confirm the retention window with compliance before the next stage hardens the schema -->
