**Collaborator:** aidlc-developer-agent

> Conductor viết thay, đóng vai developer agent (agent con không có công cụ file; người dùng đã đồng ý). Chỉ dựa trên bản nháp của lead và codekb, không xem đóng góp của agent khác.

## Contribution

- **Đặt tên:** theo chuẩn Dart. File `snake_case.dart`, class `PascalCase`, member `camelCase`, member private có tiền tố `_`. Code hiện tại tuân thủ.
- **Tổ chức file:** feature-first (`lib/features/<feature>/{controllers,logic,models,screens,widgets}`), phần dùng chung ở `lib/core/*` và `lib/shared/widgets`. Requirements NFR-01 yêu cầu giữ cấu trúc này và thêm feature mới vào `lib/features/`.
- **Ranh giới lớp:** hiện tại screen chứa logic (`_GameScreenState`). Đề xuất quy ước mới: logic và state đặt trong controller hoặc service (ChangeNotifier qua `provider`), screen chỉ render. Firebase và SharedPreferences phải được bọc sau service hoặc repository.
- **Xử lý lỗi:** code hiện tại nuốt lỗi (`catch (e) {}` trong `AudioController`). Quy ước construction yêu cầu không để lỗi im lặng: log lỗi qua `debugPrint` hoặc Analytics, rồi fallback.
- **Ngôn ngữ chuỗi UI:** chỉ tiếng Anh, theo quyết định D-13.

## Positions

- AGREE: giữ `flutter_lints` cùng `dart format`, không đặt quy tắc tùy chỉnh trừ khi người dùng muốn.
- OBJECT: không nên tiếp tục pattern logic trong widget cho tính năng mới. Đề xuất bắt buộc tách controller. Việc này cần người dùng xác nhận vì làm thay đổi quy ước hiện có.
