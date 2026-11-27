**Collaborator:** aidlc-developer-agent

## Contribution

Ghi chú: file này do conductor viết theo góc nhìn developer vì trợ lý chuyên trách không có công cụ ghi file trong phiên này, nên nó không độc lập với bản nháp của người dẫn.

Quy ước code quan sát được:

- Kiến trúc feature-first: `lib/features/<feature>/{controllers,logic,models,screens,widgets,services,engine}`, `lib/core/*`, `lib/shared/widgets`.
- State bằng `provider` với `ChangeNotifier`. Screen chỉ render, logic nằm ở controller và service.
- Firebase và SharedPreferences nằm sau interface (`RemoteConfigClient`, `AnalyticsService`, `ProgressStore`) có bản `Noop` hoặc fake, tiêm qua constructor và dựng ở `app_composition.dart`.
- Doc comment `///` bằng tiếng Việt, tham chiếu mã yêu cầu. Chuỗi hiển thị trên UI bằng tiếng Anh.
- Đặt tên theo chuẩn Dart, định dạng bằng `dart format`.

Điểm cần lưu ý: có ba tệp 1 dòng còn sót (`game_button.dart`, `score_panel.dart`, `game_helpers.dart`), và tên game xuất hiện ở nhiều nơi thay vì một hằng số.

## Positions

- AGREE: quy tắc "code mới tách logic và state sang controller hoặc service, screen chỉ render" khớp với mã hiện có.
- AGREE: dịch vụ quảng cáo nên theo mẫu interface cộng bản `Noop` hoặc fake.
