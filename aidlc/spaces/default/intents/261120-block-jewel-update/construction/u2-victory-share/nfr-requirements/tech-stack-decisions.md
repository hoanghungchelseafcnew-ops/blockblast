# Tech Stack Decisions: u2-victory-share

Nguồn: technology-stack.md (code KB), requirements.md (NFR3, NFR5).

| ID | Quyết định | Lý do |
|---|---|---|
| NFR3.1 | Unit test cho chuỗi chia sẻ; widget test cho nút SHARE ở 3 biến thể và khi chia sẻ lỗi, dùng `ScoreShareService` giả | quy ước team |
| NFR5.1 | `flutter analyze` sạch, `dart format` | quy ước team |
| NFR5.2 | Dùng lại `screenshot` ^3.0.0, `share_plus` ^10.1.3, `path_provider` ^2.1.5 | đã có trong dự án |
