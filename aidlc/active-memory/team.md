<!-- AI-DLC keeps this copy in step with aidlc/spaces/default/memory/team.md. Edit that file; this copy is replaced. -->
# Team-Level Rules

> This team's affirmed practices and corrections. Loaded after `org.md` as
> strict-additive guidance; contradictions with broader policy are rejected.
> Populated by the practices-discovery affirmation gate. Edit at the gate,
> not directly.

## Way of Working

Một developer duy nhất, có dùng git để giữ lịch sử phiên bản. Quy ước nhánh và merge theo mặc định của tổ chức (trunk-based, nhánh ngắn hạn gộp vào `main`). AI sinh code và người dùng tự commit.

## Walking Skeleton

Luôn làm một bản mỏng chạy xuyên suốt trước, rồi mới hoàn thiện từng tính năng. Với đợt quảng cáo và Remote Config này, bản mỏng gồm đọc cấu hình từ Firebase cộng một loại quảng cáo (interstitial sau lần bấm Start) chạy xuyên suốt, rồi mới thêm reward ads, banner, thứ tự mạng, popup cập nhật và link trong nội dung chia sẻ.

## Testing Posture

- **Methodology**: test-after
- **Ordering**: Implement each testable layer first, then write and run that layer's tests before moving on.
- Độ phủ dòng tối thiểu 80% trên toàn bộ codebase.
- Ưu tiên unit test cho logic thuần và controller hoặc service, widget test cho màn mới.
- `test/widget_test.dart` phải pass trước khi đo độ phủ.
- Mã dùng SDK quảng cáo nằm sau interface có bản giả để test, theo mẫu `RemoteConfigClient` và `AnalyticsService`.
- Lệnh kiểm tra: `flutter analyze` và `flutter test --coverage`, do người dùng chạy rồi báo kết quả. AI chỉ sinh code và test.

## Guard Policy

<!-- Affirmed by the team. Mode: strict, relaxed, or off. Strict here holds for every intent and cannot be changed from chat. A section under the retired Change Control heading, written by an earlier release, is still read. -->

## Deployment

Build thủ công (`flutter build appbundle` và `flutter build ipa`) và upload tay lên Google Play Console và App Store Connect. Không có CI/CD, không có staging tự động. Phát hành production do developer tự quyết định.

## Code Style

- `flutter_lints` (`analysis_options.yaml`) và `dart format`, đặt tên theo chuẩn Dart.
- Kiến trúc feature-first (`lib/features/<feature>/{controllers,logic,models,screens,widgets}`, `lib/core/*`, `lib/shared/widgets`).
- Code mới tách logic và state sang controller hoặc service (ChangeNotifier qua `provider`), screen chỉ render. Firebase và SharedPreferences nằm sau service hoặc repository.
- Chuỗi hiển thị trên UI chỉ dùng tiếng Anh.
## Forbidden

<!-- Team-specific forbidden patterns -->

## Mandated

<!-- Team-specific mandates -->

## Corrections

<!-- Self-learning loop appends here. -->
