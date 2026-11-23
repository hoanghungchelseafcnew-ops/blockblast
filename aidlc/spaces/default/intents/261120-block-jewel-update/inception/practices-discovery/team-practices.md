## Way of Working

Một developer duy nhất, có dùng git để giữ lịch sử phiên bản (đã xác nhận ở phỏng vấn, thay cho ghi chú cũ "không dùng git"). Quy ước nhánh và merge theo mặc định của org (trunk-based, nhánh ngắn hạn); AI sinh code và người dùng tự commit.

## Walking Skeleton

Luôn làm một bản mỏng chạy xuyên suốt trước (PLAY, chơi 1 level với mốc điểm từ Remote Config hoặc fallback, thắng thì sang level kế, tiến trình được lưu), rồi mới hoàn thiện từng tính năng. Với đợt này, bản mỏng là: đổi tên game, bỏ splash native, đổi thuật toán khối, thêm chia sẻ khi thắng, chạy được ở mức 1 level.

## Testing Posture

- **Methodology**: test-after
- **Ordering**: Implement each testable layer first, then write and run that layer's tests before moving on.
- Coverage dòng tối thiểu 80% trên toàn bộ codebase.
- Ưu tiên unit test cho logic thuần và controller/service; widget test cho màn mới.
- `test/widget_test.dart` phải pass trước khi đo coverage.
- Lệnh kiểm tra: `flutter analyze` và `flutter test --coverage`, do người dùng chạy rồi báo kết quả; AI chỉ sinh code và test.

## Deployment

Build thủ công (`flutter build appbundle` / `flutter build ipa`) và upload tay lên Google Play Console và App Store Connect. Không có CI/CD, không có staging tự động. Phát hành production do developer tự quyết định.

## Code Style

- `flutter_lints` (`analysis_options.yaml`) và `dart format`; đặt tên theo chuẩn Dart.
- Kiến trúc feature-first (`lib/features/<feature>/{controllers,logic,models,screens,widgets}`, `lib/core/*`, `lib/shared/widgets`).
- Code mới tách logic và state sang controller/service (ChangeNotifier qua `provider`); screen chỉ render; Firebase và SharedPreferences nằm sau service hoặc repository.
- Chuỗi hiển thị trên UI chỉ dùng tiếng Anh.
