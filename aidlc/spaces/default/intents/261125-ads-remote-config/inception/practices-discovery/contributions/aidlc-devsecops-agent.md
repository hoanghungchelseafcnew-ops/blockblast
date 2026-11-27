**Collaborator:** aidlc-devsecops-agent

## Contribution

Ghi chú: file này do conductor viết theo góc nhìn bảo mật vì trợ lý chuyên trách không có công cụ ghi file trong phiên này, nên nó không độc lập với bản nháp của người dẫn.

Quan sát:

- Lint: `flutter_lints ^5.0.0` qua `analysis_options.yaml`. Không có công cụ quét tĩnh bảo mật, quét bí mật hay quét phụ thuộc, và không có CI để chạy chúng.
- Bí mật: `android/.gitignore` đã bỏ qua `key.properties` và `**/*.jks`. Tuy nhiên `android/app/google-services.json` và `ios/Runner/GoogleService-Info.plist` đang được theo dõi trong git. Các tệp này chứa khóa API phía client của Firebase, thường được chấp nhận là công khai nhưng nên được hạn chế theo ứng dụng trong Firebase và Google Cloud.
- Quảng cáo sẽ thêm ID ứng dụng và ad unit ID của AdMob, Unity, AppLovin. Các ID này là định danh công khai nhưng nên nằm ở một chỗ cấu hình. Khóa bí mật (nếu có, ví dụ SDK key của AppLovin) không nên đưa vào mã nguồn.
- Phụ thuộc: sẽ thêm ba SDK quảng cáo, mở rộng bề mặt chuỗi cung ứng. `pubspec.lock` đã có để ghim phiên bản, và nên xem lại khi nâng cấp.

## Positions

- AGREE: không cần thêm công cụ quét mới cho đội một người, miễn là khóa ký ứng dụng vẫn bị bỏ qua khỏi git.
- OBJECT: không nên đưa khóa bí mật của mạng quảng cáo vào Remote Config, vì Remote Config trả giá trị cho mọi ứng dụng cài đặt.
