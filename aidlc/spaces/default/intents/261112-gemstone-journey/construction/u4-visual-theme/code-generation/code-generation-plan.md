# Kế hoạch Code Generation — U4 `u4-visual-theme`

## Sources

- [units] `inception/units-generation/unit-of-work.md` (U4: component, ranh giới, chủ sở hữu duy nhất của `GemTheme`, phụ trách coverage code cũ) và `unit-of-work-story-map.md` (U4: US5.4 → US7.1 → US7.2 → US7.3 → US7.4 → US5.2 → US8.6)
- [contract] `inception/contract-design/contract-summary.md`: C3 (`Level.assetPath`, `Level.backgroundUrl`), C6 (`GemTheme.forGem`, `GemPalette`, `buttonFill` của Amethyst là `#7A4FB0`), E3 (gỡ `theme_index`, `last_login_date`)
- [req] `inception/requirements-analysis/requirements.md`: FR5.1..FR5.4, FR10.1..FR10.3, FR12.1, FR12.2, NFR2, NFR4..NFR9
- [stories] `inception/user-stories/stories.md`: AC5.2.1, AC5.3.1, AC5.4.1, AC5.4.2, AC7.1.1, AC7.2.1..AC7.2.3, AC7.3.1, AC7.4.1, AC8.3.1, AC8.6.1, AC8.6.2
- [mock] `inception/refined-mockups/mockups.md` (M-0 Splash, M-1 Home, M-1s Settings, M-2 Game) và `design-system-mapping.md` (typography, gem tokens, nền, component mapping)
- [u1u2] Code hiện có: `ThemeManager`, `AnimatedBackground`, `HomeScreen`, `SplashScreen`, `GameScreen`, `BoardCell`, `DraggableBlock`, `AppTheme`, `ProgressRepository.legacyKeys`
- [prac] `aidlc/spaces/default/memory/team.md`: test-after, coverage ≥ 80%, logic nằm trong controller/service, UI chỉ tiếng Anh

U4 không có artifact functional design, NFR hay infrastructure riêng. Kế hoạch dựa trực tiếp vào contract, requirements, story và refined mockups ở trên.

## Testing Contract

```json
{
  "version": 1,
  "methodology": "test-after",
  "source": "team",
  "ordering": "Implement each testable layer first, then write and run that layer's tests before moving on.",
  "scope": "feature",
  "test_strategy": "standard",
  "project_type": "brownfield",
  "applicable_notes": [
    {
      "layer": "org",
      "text": "We treat tests as a first-class deliverable in every Bolt. The specific\nmethodology (TDD, BDD, ATDD, or classic test-after) is affirmed at\npractices-discovery and recorded in `team.md` under this heading with explicit\n`Methodology` and `Ordering` fields; Code Generation resolves those fields\nindependently from coverage, tooling, and scope notes.\n\nWhen no posture has been affirmed, our default per scope is:\n- **Methodology**: test-after\n- **Ordering**: implement each applicable testable layer, then write and run\n  that layer's tests.\n- `mvp`, `enterprise`, `feature`, `infra`, `classic` add an 80% line-coverage\n  floor and CI execution before merge.\n- `bugfix`, `security-patch` add a targeted regression for the specific\n  bug/vulnerability and require the existing suite to remain green.\n- `express` uses the Minimal strategy: requirement-driven unit tests (one per\n  requirement, with a happy-path floor per component); existing tests remain\n  green.\n- `poc`, `refactor`, `workshop` add no extra new-test floor and require the\n  existing suite to remain green.\n\nThe active `Test Strategy` still applies in every scope and determines test\nvolume/types. Scope floors are additive; they never reduce or replace the\nselected strategy.\n\nBuild and Test verifies defined coverage floors and affirmed quality targets;\nthey may not be weakened to make a step pass.\n\nAffirm a stricter posture in `team.md` if the team commits to one."
    },
    {
      "layer": "team",
      "text": "- **Methodology**: test-after\n- **Ordering**: Implement each testable layer first, then write and run that layer's tests before moving on.\n- Coverage dòng tối thiểu **80% trên toàn bộ codebase**, không chỉ code mới.\n- Ưu tiên unit test cho logic thuần (level, điểm, tiến trình, parse config, fallback) và cho controller/service. Có widget test cho các màn mới.\n- Sửa `test/widget_test.dart` đang hỏng trước khi đo coverage.\n- Lệnh kiểm tra: `flutter analyze` và `flutter test --coverage`. Chúng tôi tự chạy trên máy khác: AI chỉ sinh code và test, người dùng chạy rồi báo kết quả."
    }
  ],
  "obligations": {
    "strategy": "standard",
    "strategy_volume": [
      "Five to eight tests per component.",
      "Unit tests plus integration tests for key boundaries.",
      "Add E2E, performance, or security tests when requirements demand them."
    ],
    "scope_floor": [
      "Meet an 80% line-coverage floor.",
      "Run the selected tests in CI before merge."
    ],
    "combination_rule": "Apply every selected-strategy obligation and every scope-floor obligation; neither replaces the other, and a targeted scope regression may add the narrowest necessary test type beyond the strategy default."
  },
  "plan_profile": {
    "methodology": "test-after",
    "runner_step": "Verify the existing test runner/configuration and record the exact unit-scoped command.",
    "runner_ready_before_first_test": true,
    "testable_layers": [
      "Data model / database behavior",
      "Repository / data access",
      "Business logic",
      "API / endpoint",
      "Frontend behavior"
    ],
    "steps": [
      "Project structure and production configuration skeleton.",
      "Verify the existing test runner/configuration and record the exact unit-scoped command.",
      "Data model / database behavior - implement.",
      "Data model / database behavior - write and run its tests after implementation.",
      "Repository / data access - implement.",
      "Repository / data access - write and run its tests after implementation.",
      "Business logic - implement.",
      "Business logic - write and run its tests after implementation.",
      "API / endpoint - implement.",
      "API / endpoint - write and run its tests after implementation.",
      "Frontend behavior - implement.",
      "Frontend behavior - write and run its tests after implementation.",
      "Environment/build configuration.",
      "Documentation and traceability."
    ]
  },
  "input_sha256": "sha256:7c22d5c726aa5305a3a73c47f3a56bb1a901b8f03029821c99785bf7cec61247",
  "contract_sha256": "sha256:d81565c11dbedf270cc7200b7c0ca8faef2aa320bae14964295a97fbafa1c9ad"
}
```

Ghi chú áp dụng hợp đồng: AI tự chạy `flutter analyze` và `flutter test` bằng Flutter Linux 3.41.5 trong WSL. Sau mỗi lần như vậy, người dùng chạy `flutter pub get` trên Windows trước khi build, vì Flutter Linux ghi đè `.dart_tool/package_config.json`. Không có CI, nên "Run in CI before merge" được đáp ứng bằng lệnh kiểm chứng `flutter analyze && flutter test --coverage` ở checkpoint của unit. Lớp "API / endpoint" không áp dụng. Lớp "Data model" là bảng màu đá quý. Lớp "Repository" là việc nạp ảnh nền (asset, mạng, cache).

## Quy ước

- Brownfield: sửa file tại chỗ, không tạo bản sao `_modified`.
- `GemTheme` là nguồn màu duy nhất cho UI theo đá quý (C6). Khối và ô trên bảng giữ màu ngẫu nhiên của `BlockGenerator` (design-system-mapping [Q5]).
- Mọi `catch` đều log (`GjLog`) và có fallback (DoD-4). Log không chứa URL đầy đủ.
- Chuỗi UI chỉ tiếng Anh. Nút có vùng chạm ≥ 48dp (DoD-3).
- Dependency mới duy nhất là `cached_network_image` (NFR4). `google_fonts` bị gỡ vì font được đóng gói trực tiếp (xem Step 1).
- Không đổi logic ván chơi (ranh giới U4).

## Các bước

### Giai đoạn A — Chuẩn bị

- [x] **Step 1 — Cấu trúc dự án và cấu hình sản phẩm.**
  - Tải font từ repo chính thức Google Fonts (giấy phép OFL) vào `assets/fonts/`:
    - `curl -fL -o assets/fonts/Righteous-Regular.ttf https://github.com/google/fonts/raw/main/ofl/righteous/Righteous-Regular.ttf`
    - `curl -fL -o assets/fonts/Montserrat-Variable.ttf "https://github.com/google/fonts/raw/main/ofl/montserrat/Montserrat%5Bwght%5D.ttf"`
    - `curl -fL -o assets/fonts/OFL-Righteous.txt https://github.com/google/fonts/raw/main/ofl/righteous/OFL.txt` và `curl -fL -o assets/fonts/OFL-Montserrat.txt https://github.com/google/fonts/raw/main/ofl/montserrat/OFL.txt` (giữ giấy phép cạnh file font)
  - `pubspec.yaml`:
    - Thêm `cached_network_image`.
    - Gỡ `google_fonts`.
    - Khai báo font family `Righteous` và `Montserrat`.
    - Khai báo asset `assets/design/Level1/` … `assets/design/Level6/` (Flutter không khai báo thư mục con theo kiểu đệ quy). `assets/fonts/` không cần khai báo dạng asset.
  - Truy vết: AC8.3.1, NFR2, NFR4, NFR6, design-system-mapping (Typography).
- [x] **Step 2 — Xác minh test runner.** Chạy `flutter pub get` rồi `flutter test` trên code hiện tại để có mốc xanh trước khi sửa. Lệnh được ghi trong `unit-test-instructions.md`.

### Giai đoạn B — Data model: bảng màu đá quý

- [x] **Step 3 — `GemTheme` và `GemPalette` — implement.**
  - `lib/core/theme/gem_theme.dart`:
    - `GemPalette { primary, secondary, onPrimary, buttonFill }`.
    - `GemTheme.forGem(gemId)` theo bảng FR12.1. `buttonFill` bằng `primary`, riêng Amethyst là `#7A4FB0` (C6).
    - Gem id không biết thì dùng bảng của Rose Quartz và log cảnh báo.
    - `backgroundGradient(palette)`: `secondary` → `#0F0C29` (design-system-mapping, Nền).
  - `lib/core/theme/contrast.dart`: hàm thuần `contrastRatio(Color a, Color b)` theo công thức WCAG 2.x, dùng cho test và checklist.
  - `lib/core/theme/app_typography.dart`: các token `display`, `headline`, `title`, `body`, `caption` dùng font đã đóng gói. Montserrat là variable font, nên mỗi style đặt `fontWeight` kèm `FontVariation('wght', …)`.
  - `AppTheme` dùng `AppTypography` thay cho `GoogleFonts`.
  - Truy vết: FR12.1, C6, AC5.4.1, AC5.4.2, AC8.6.2.
- [x] **Step 4 — Data model: test.** `test/core/theme/gem_theme_test.dart`:
  - Đúng mã màu của cả 6 gem.
  - `buttonFill` của Amethyst là `#7A4FB0`.
  - Gem id lạ dùng bảng Rose Quartz và có log.
  - `contrastRatio` khớp các giá trị đã biết (đen/trắng = 21:1, cùng màu = 1:1).
  - Checklist WCAG AA cho cả 6 bảng màu (AC8.6.2):
    - `onPrimary` trên `buttonFill` ≥ 4.5:1.
    - Viền trắng của thanh tiến độ trên nền tối ≥ 3:1.
    - Nhãn chữ trắng trên gradient nền ≥ 4.5:1.
  - `AppTypography` dùng đúng family và trục `wght`.

### Giai đoạn C — Repository: nạp ảnh nền

- [x] **Step 5 — `BackgroundImageService` — implement.**
  - `lib/features/journey/services/background_image_service.dart`:
    - `assetFor(level)` trả `AssetImage(level.assetPath)`.
    - `networkFor(level)` trả `ImageProvider?` từ `level.backgroundUrl` qua một `NetworkImageFactory` tiêm vào được. Mặc định là `CachedNetworkImageProvider`, lưu cache trên đĩa (FR5.4, AC7.2.1). URL null thì trả null; URL đã được `ImageUrlPolicy` kiểm từ U1.
    - `precache(context, level)`: precache asset và ảnh mạng (nếu có) của một level. Lỗi chỉ log `levelId` và `err.runtimeType`, không ném ra (FR5.4, AC7.3.1).
  - Không dùng `firebase_storage` (AC7.2.1).
  - Truy vết: FR5.1, FR5.2, FR5.4, AC7.2.1..AC7.2.3, AC7.3.1, AC7.4.1, C3.
- [x] **Step 6 — Repository: test.** `test/features/journey/background_image_service_test.dart`:
  - Asset path đúng cho Blue Topaz · Polishing (`assets/design/Level3/5.jpg`, AC7.1.1).
  - Không có URL thì không có provider mạng.
  - Có URL thì factory được gọi đúng một lần với URL đó. Gọi lần hai cho cùng level dùng lại provider đã có, không gọi factory lần nữa (AC7.2.3: cache được dùng lại, không có lệnh tải mới).
  - Precache lỗi thì chỉ log, không ném lỗi, và log không chứa URL.
  - Mỗi asset của 36 level đều tồn tại trên đĩa (AC8.3.1).

### Giai đoạn D — Business logic

- [x] **Step 7 — Gỡ theme cũ và Daily Gift, khóa portrait — implement.**
  - Xóa `lib/core/theme/theme_manager.dart` (`ThemeManager`, `AppThemeType`). `BoardCell` và `DraggableBlock` giữ kiểu vẽ "neon" hiện tại, không còn phụ thuộc theme. `app_composition.dart` bỏ provider `ThemeManager` (FR12.2, AC5.4.2).
  - Xóa `lib/core/widgets/animated_background.dart` (hạt chuyển động bị bỏ theo design-system-mapping, Nền). Đây cũng là code cũ mà U4 phụ trách coverage.
  - `ProgressRepository.legacyKeys` thêm `theme_index` và `last_login_date` (E3, AC5.2.1). U2 đã ghi chú để chờ U4 làm việc này.
  - Gỡ `_checkDailyReward` và `_showRewardDialog` khỏi `HomeScreen` (FR10.2, AC5.2.1).
  - Thêm `configureSystemUi()` trong `app_composition.dart`: gọi `SystemChrome.setPreferredOrientations([portraitUp])`. `main()` gọi hàm này. Thêm `android:screenOrientation="portrait"` vào `AndroidManifest.xml`. `ios/Runner/Info.plist` chỉ giữ hướng portrait cho iPhone (NFR8, AC8.6.1).
  - Truy vết: FR10.2, FR12.2, E3, NFR8, AC5.2.1, AC5.4.2, AC8.6.1.
- [x] **Step 8 — Business logic: test.**
  - Sửa `test/features/journey/progress_repository_test.dart`: gỡ cả 4 key cũ; xóa test đang khẳng định `theme_index`/`last_login_date` được giữ lại.
  - `test/app_composition_test.dart`: không còn provider `ThemeManager`; `configureSystemUi()` gửi lệnh portrait qua `SystemChannels.platform` (bắt bằng mock method call handler).
  - Grep tĩnh trong test: `lib/` không còn `ThemeManager`, `AppThemeType`, `theme_index`, `last_login_date`, `_checkDailyReward`, `DAILY GIFT` (AC5.2.1, AC5.4.2).

### Giai đoạn E — Frontend

- [x] **Step 9 — Frontend: nền, nút, thanh tiến độ, các màn — implement.**
  - `lib/shared/widgets/level_background.dart` — `LevelBackground(level, {blurred})`:
    - Hiện asset ngay. Nếu ảnh mạng tải xong thì cross-fade 300ms sang ảnh mạng. Ảnh mạng lỗi thì giữ asset (FR5.2, AC7.2.2).
    - Khi `blurred`: blur sigma 12 cộng lớp phủ đen 50% (FR5.3, design-system-mapping).
    - Asset cũng lỗi thì dùng gradient của gem.
  - `lib/shared/widgets/gem_primary_button.dart` — `GemPrimaryButton`: nền `buttonFill`, chữ `onPrimary`, bo góc 20, cao ≥ 56dp.
  - `lib/shared/widgets/level_progress_bar.dart` — `LevelProgressBar`: fill `primary`, track `#FFFFFF1F`, viền trắng 1.5dp, nhãn % dạng chữ.
  - `SplashScreen` theo M-0: logo, "BLOCK CRUSH", "◆ Gemstone Journey ◆", chỉ báo đang tải, nền `#0F0C29`. Thời gian chờ của bootstrap giữ nguyên.
  - `HomeScreen` theo M-1 State A/B:
    - `LevelBackground` của level hiện tại (blur) cùng gradient gem.
    - Icon gem 2D placeholder (`Icons.diamond` tô màu `primary`, 96dp).
    - Nhãn `"<Gem> · <Sub>"` và "Level N of 36".
    - PLAY là `GemPrimaryButton` 280×64.
    - Settings chỉ còn Sound Effects (M-1s, AC5.3.1).
    - Sau khi rời màn chơi, Home vẽ lại theo gem mới.
  - `GameScreen` theo M-2:
    - `LevelBackground(blurred: true)` thay cho `AnimatedBackground`.
    - Header dùng `LevelProgressBar`.
    - CONTINUE, PLAY AGAIN và nút QUIT trong dialog dùng màu gem.
    - Precache ảnh của level N+1 khi bắt đầu một round (AC7.3.1).
  - Truy vết: FR5.2, FR5.3, FR10.1, FR10.3, FR12.1, AC5.3.1, AC5.4.1, AC7.1.1, AC7.2.2, AC7.3.1, AC7.4.1, AC8.6.2, NFR9.
- [x] **Step 10 — Frontend: widget test.**
  - `test/shared/level_background_test.dart`:
    - Hiện asset khi không có URL.
    - Có lớp blur khi `blurred`.
    - Ảnh mạng lỗi thì vẫn giữ asset.
    - Asset lỗi thì dùng gradient.
  - `test/shared/gem_widgets_test.dart`: `GemPrimaryButton` ≥ 56dp với đúng màu; `LevelProgressBar` có viền, màu `primary` và nhãn %.
  - `test/ui/splash_home_test.dart`:
    - Splash có "BLOCK CRUSH" và "Gemstone Journey".
    - Home có "Level N of 36" và PLAY ≥ 48dp.
    - Không có Daily Gift dù `last_login_date` trống.
    - Settings không có THEME.
    - Ở Emerald, nền và nút dùng màu Emerald (AC5.4.1).
  - `test/ui/game_screen_test.dart`:
    - `LevelBackground` có blur.
    - Thanh tiến độ dùng màu gem.
    - Không còn `AnimatedBackground`.
  - `test/ui/legacy_widgets_test.dart`: `BoardCell` và `DraggableBlock` render không cần `ThemeManager`.
  - Cập nhật `ui_test_helpers.dart` (`withTheme` và các helper mock prefs không còn cần Daily Gift).

### Giai đoạn F — Cấu hình và tài liệu

- [x] **Step 11 — Environment/build configuration.**
  - Rà `pubspec.yaml`, `AndroidManifest.xml` và `Info.plist` đã sửa.
  - Chạy `dart format` cho các file đã sửa và `flutter analyze` sạch.
  - Đo dung lượng `assets/design` bằng `du -sh`. Ghi con số vào `code-summary.md`: NFR5 chỉ khuyến nghị ≤ 10MB, việc nén ảnh do người dùng quyết định.
- [x] **Step 12 — Tài liệu và truy vết.**
  - Chạy `flutter analyze && flutter test --coverage`.
  - Kiểm tra coverage ≥ 80% cho mọi file U4 tạo hoặc sửa (DoD-2), và coverage toàn codebase ≥ 80% (phần code cũ U4 phụ trách).
  - Viết `code-summary.md` (kèm checklist tương phản của 6 gem), `source-manifest.json` và `traceability.json`.

## Ma trận truy vết

| Yêu cầu / AC | Bước |
|--------------|------|
| FR12.1, C6, AC5.4.1 | 3, 4, 9, 10 |
| FR12.2, AC5.4.2 | 7, 8, 10 |
| FR5.1, FR5.2, AC7.1.1, AC7.2.2 | 5, 6, 9, 10 |
| FR5.3 | 9, 10 |
| FR5.4, AC7.2.1, AC7.2.3, AC7.3.1 | 5, 6, 9 |
| AC7.4.1, NFR6 | 1, 5, 9 |
| FR10.1, FR10.3, AC5.3.1 | 9, 10 |
| FR10.2, AC5.2.1, E3 | 7, 8 |
| NFR8, AC8.6.1 | 7, 8 |
| NFR9, AC8.6.2 | 3, 4, 9, 10 |
| NFR2, AC8.3.1 | 1, 6 |
| NFR4 | 1 |

## Assumptions & Open Questions

- [assumption] Ảnh viên đá 2D (`assets/gemstones/<gem>.png`) chưa có. Home dùng `Icons.diamond` tô màu `primary` làm placeholder (mockups, Assumptions).
- [assumption] State C của Home ("Journey Complete", 6 viên đá, "Endless · Best N") thuộc U6, nên U4 không làm.
- [assumption] Máy của AI tải được font từ GitHub. Nếu không tải được, người dùng đặt `Righteous-Regular.ttf` và `Montserrat-Variable.ttf` vào `assets/fonts/` rồi chạy lại.
- [assumption] Montserrat chỉ có bản variable trong repo Google Fonts hiện tại, nên weight được đặt qua trục `wght`. Gỡ `google_fonts` vì package này cần file font tĩnh hoặc phải tải lúc chạy.
- [assumption] Màn Victory đầy đủ thuộc U3. U4 chỉ đổi nút CONTINUE của Victory tạm sang màu gem.
- [assumption] Nếu `CachedNetworkImageProvider` không cho thay cache manager mà không cần thêm dependency, thì AC7.2.3 được kiểm qua seam `NetworkImageFactory` (provider được dùng lại, factory không bị gọi lần hai). Hành vi cache trên đĩa thuộc về thư viện.
