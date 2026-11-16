# Team Practices

## Way of Working

Chúng tôi là một developer duy nhất và **không dùng git**. Mọi thay đổi, kể cả code do AI sinh ra, được ghi trực tiếp vào thư mục dự án. Không có nhánh, worktree hay merge. Chúng tôi chấp nhận rủi ro không rollback được bằng lịch sử phiên bản. Đây là lệch có chủ ý khỏi mặc định trunk-based và squash-merge của org, do quy mô dự án một người.

## Walking Skeleton

Chúng tôi **luôn** làm walking skeleton trước: một bản tối giản chạy xuyên suốt toàn bộ luồng (bấm PLAY, chơi 1 level với mốc điểm từ Remote Config hoặc fallback, thắng thì sang level kế tiếp, tiến trình được lưu), để kiểm chứng các phần ghép được với nhau trước khi hoàn thiện từng tính năng.

## Testing Posture

- **Methodology**: test-after
- **Ordering**: Implement each testable layer first, then write and run that layer's tests before moving on.
- Coverage dòng tối thiểu **80% trên toàn bộ codebase**, không chỉ code mới.
- Ưu tiên unit test cho logic thuần (level, điểm, tiến trình, parse config, fallback) và cho controller/service. Có widget test cho các màn mới.
- Sửa `test/widget_test.dart` đang hỏng trước khi đo coverage.
- Lệnh kiểm tra: `flutter analyze` và `flutter test --coverage`. Chúng tôi tự chạy trên máy khác: AI chỉ sinh code và test, người dùng chạy rồi báo kết quả.

## Deployment

Build thủ công (`flutter build appbundle` / `flutter build ipa`) và upload tay lên Google Play Console và App Store Connect. Không có CI/CD và không có môi trường staging tự động. Phát hành production do developer tự quyết định.

## Code Style

- `flutter_lints` (`analysis_options.yaml`) cùng `dart format`. Đặt tên theo chuẩn Dart.
- Kiến trúc feature-first (`lib/features/<feature>/{controllers,logic,models,screens,widgets}`, `lib/core/*`, `lib/shared/widgets`).
- **Code mới bắt buộc tách logic và state sang controller/service** (ChangeNotifier qua `provider`). Screen chỉ render. Firebase và SharedPreferences được bọc sau service hoặc repository.
- Chuỗi hiển thị trên UI chỉ dùng tiếng Anh.
