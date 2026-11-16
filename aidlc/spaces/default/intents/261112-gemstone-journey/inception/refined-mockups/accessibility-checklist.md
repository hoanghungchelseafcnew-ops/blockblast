# Accessibility Checklist — Gemstone Journey (WCAG 2.1 AA, mobile)

## Sources

- [req] `inception/requirements-analysis/requirements.md` NFR9
- [stories] `inception/user-stories/stories.md` US8.6, US3.4
- [ds] `design-system-mapping.md` (tỉ lệ tương phản đã tính)
- [mock] `mockups.md`, [spec] `interaction-spec.md`

## Checklist

| # | Tiêu chí | Màn | Cách kiểm tra | Trạng thái thiết kế |
|---|----------|-----|---------------|---------------------|
| A1 | Vùng chạm ≥ 48×48dp cho mọi nút (⚙, ←, PLAY, CONTINUE, CANCEL/QUIT, PLAY AGAIN, SHARE, BACK TO MENU, Switch) | tất cả | Widget test dùng `tester.getSize(...)` | ✅ Đã thiết kế |
| A2 | Chữ thường ≥ 4.5:1 | tất cả | Checklist dùng công thức WCAG | ✅ Chữ trắng trên lớp phủ tối và trên `#1C1C2E` |
| A3 | Nhãn nút trên `gemPrimary` ≥ 4.5:1, hoặc ≥ 3:1 nếu là chữ lớn (≥ 18.66px bold) | PLAY, CONTINUE, PLAY AGAIN | Bảng `onGemPrimary` | ✅ Rose Quartz 10.9, Blue Topaz 9.0, Emerald 8.5, Sapphire 7.2, Ruby 4.8, Amethyst 4.1 (chữ lớn 20 w700, đạt ≥ 3:1) |
| A4 | Thành phần UI ≥ 3:1 (thanh tiến độ) | M-2 | Viền trắng 1.5dp so với nền tối | ✅ (fill Sapphire và Ruby trên track tối chỉ 2.0–3.0:1, nên cần viền trắng) |
| A5 | Trạng thái không chỉ thể hiện bằng màu | M-2, M-4..M-5a | Có nhãn % dạng chữ, chữ "Unlocked!", "Completed!" | ✅ |
| A6 | Semantics cho screen reader (TalkBack/VoiceOver) | M-1, M-2 header, M-2a, M-3, M-4..M-5a | Kiểm tra `Semantics` trong widget test | ✅ Đã chỉ định nhãn |
| A7 | Focus mặc định hợp lý | M-2a (CANCEL), M-4/M-5 (CONTINUE), M-5a (BACK TO MENU), M-3 (PLAY AGAIN) | Review code | ✅ |
| A8 | Nút Back của hệ thống luôn có hành vi rõ ràng | M-2, M-2a | Thử tay trên Android | ✅ PopScope |
| A9 | Reduced motion: tắt confetti và xoay khi `disableAnimations` bật | M-4..M-5a | Widget test với `MediaQueryData(disableAnimations: true)` | ✅ |
| A10 | Kết quả truyền đạt được khi tắt âm thanh | M-4..M-5a, M-3 | Mọi kết quả đều có chữ | ✅ |
| A11 | Hiệu ứng nhấp nháy ≤ 3 lần/giây (glow pulse 1.2s, sparkle) | M-4..M-5a | Review thông số animation | ✅ |
| A12 | Chữ co giãn được: không vỡ layout với textScaleFactor 1.3 | M-1, M-2, M-3, M-4 | Widget test với `textScaler` 1.3 | ⚠️ Header M-2 cần cho tên level dài ("Blue Topaz · Polishing") xuống dòng hoặc thu nhỏ |
| A13 | Hướng màn hình khóa dọc | tất cả | `SystemChrome.setPreferredOrientations` | ✅ (NFR8) |
| A14 | Ngôn ngữ UI chỉ tiếng Anh | tất cả | Review chuỗi | ✅ (NFR7) |

## Assumptions & Open Questions

- [assumption] A12: ngưỡng textScaleFactor 1.3 do design đề xuất, requirements không có con số này.
