# Code Summary — U1 `u1-journey-skeleton`

## Trạng thái

- AI **không chạy được `flutter`**: toàn bộ code và test dưới đây chưa được biên dịch hay chạy. Người dùng chạy CP-2 và CP-3 (lệnh ở cuối file) và báo kết quả. Có thể còn lỗi biên dịch hoặc test đỏ nhỏ cần sửa vòng sau.
- Step 1 và 2 (đổi package, Firebase init, sửa `widget_test.dart`) đã xong từ trước và được xác minh lại: `applicationId`/`namespace` = `com.h2.game.block_blast`, bundle iOS = `com.h2.game.blockBlast`, plugin `google-services` đã khai báo, `google-services.json` và `GoogleService-Info.plist` có mặt, không có API key trong `lib/`.
- Step 3..22 đã làm đủ. Plan đã tick đến Step 21; Step 22 là file này cùng `traceability.json` và `source-manifest.json`.

## Files tạo mới

**Engine ván chơi** (`lib/features/game/engine/`): `turn_result.dart`, `turn_resolver.dart` (tính điểm, hàm thuần), `board_engine.dart` (bảng, khay, preview, hết nước đi, REVIVE), `board_geometry.dart` (đổi tọa độ chạm thành ô, công thức giữ nguyên).
**Dịch vụ game** (`lib/features/game/services/`): `game_feedback.dart` (interface âm thanh/rung, `NoopGameFeedback`, `DeviceGameFeedback`), `score_share_service.dart` (SHARE qua interface).
**Cấu hình** (`lib/core/config/`): `level_config.dart` (`GemConfig`, `SubLevelConfig`, `LevelConfig`, `ConfigSource`), `image_url_policy.dart`, `level_config_validator.dart`, `remote_config_client.dart`, `level_config_service.dart`. `lib/core/firebase/`: `default_level_config.dart` (hằng const), `firebase_remote_config_client.dart`. `lib/core/utils/clock.dart`.
**Hành trình** (`lib/features/journey/`): `models/{level,player_progress,journey_outcome}.dart`; `services/{level_catalog,progress_store,progress_repository,app_bootstrap,progress_lifecycle_observer}.dart`; `controllers/{journey_controller,level_game_controller}.dart`.
**UI**: `lib/features/splash/screens/splash_screen.dart`.
**Test** (186 test): `test/core/config/*` (validator, URL policy, default config, service, adapter Remote Config), `test/features/game/engine/*`, `test/features/journey/*`, `test/ui/*`, `test/fakes/*` (`FakeRemoteConfigClient`, `FakeClock`, `FakeProgressStore`, `LogCapture`), `test/fixtures/level_config_valid.json`.

## Files sửa tại chỗ

`lib/main.dart` (bootstrap thay cho `FirebaseGateway().init()`), `lib/app.dart` (Splash làm màn đầu), `lib/features/home/screens/home_screen.dart` (bỏ hai thẻ chế độ và high score, thêm nhãn level và PLAY, observer `paused`), `lib/features/game/screens/game_screen.dart` (chỉ render, dùng `LevelGameController`, gỡ Time Attack), `lib/features/game/logic/board_logic.dart` (thêm tham số `delay` cho animation, mặc định 180ms), `test/widget_test.dart`.

## Quyết định chính

- `BoardEngine` giữ bảng và khay, `TurnResolver.resolve` là hàm thuần O(64). `LevelGameController` chỉ gọi `notifyListeners()` sau khi đã tính xong mỗi lượt (D-P1).
- Thắng được kiểm tra ngay sau khi tính điểm, trước animation: `status = resolving`, rồi `Future.wait([animation, Future.any([onLevelWon, timer 3s])])` (BR5.3, BR5.9). Kiểm tra hết nước đi chỉ chạy khi không thắng.
- `LevelStatus` có đủ 5 giá trị; `switch` trong UI liệt kê đủ case, không có `default` (contract C2).
- `ProgressRepository`: một hàng đợi FIFO mở sau `load()`; ghi lỗi thì dirty và bộ đếm 3 lần; `flushDirty` bỏ qua bộ đếm; `load` lỗi hai lần thì chỉ đọc (log một dòng khi vào, một dòng ở lần ghi bị bỏ qua đầu tiên). `ProgressStore` là lớp bọc thay thế được.
- `AppBootstrap.run()` không bao giờ throw và không vượt hạn chót 3,5s. `Clock` được tiêm; ngân sách fetch = min(2s, hạn chót − 0,5s − đã trôi qua).
- `ImageUrlPolicy` bọc `Uri.decodeFull` trong `try/catch(Object)`: `%zz` trả `false`, không throw. Mọi log chỉ có `levelId`, lý do và `err.runtimeType`; không URL đầy đủ, không `err.toString()`, không JSON thô.
- Tách thêm `GameFeedback` và `ScoreShareService` để controller và widget test không cần plugin nền tảng. `ThemeManager` và Daily Gift giữ nguyên đến U4.

## Deviations so với plan

1. **`ProgressRepository.abandonLoad()`** (không có trong plan). Khi hạn chót bootstrap cắt `load()` đang dở, repository chuyển sang chỉ-đọc với giá trị mặc định, để không ghi đè tiến trình thật chưa đọc được bằng level 1. Hệ quả: lần mở app đó người chơi thấy level 1 và tiến trình không bị ghi cho tới lần mở sau. Chỉ xảy ra khi đọc SharedPreferences quá 0,5s.
2. `BoardLogic.applyClearAnimated` nhận thêm tham số `delay` (mặc định 180ms) để test chạy nhanh. Hành vi mặc định không đổi.
3. Ghi trước `load()` (ngoài luồng bình thường): cache được `load()` ghi đè bằng dữ liệu đọc được; lần ghi xếp hàng vẫn chạy sau `load()`. Không có call site nào gọi ghi trước `load()`.
4. Hai bước sao lưu zip trong `unit-of-work.md` bị bỏ theo người dùng (đã dùng git).

## Coverage và khoảng trống cần người dùng xem

Mục tiêu: dòng ≥ 80% cho mọi file tạo mới hoặc sửa. Chưa đo được. Dự kiến đạt cho logic, controller, service, model và màn hình. **Có thể dưới 80%** ở các adapter chạm plugin nền tảng, vì test không tạo được `AudioPlayer`, `share_plus` hay `ScreenshotController` thật:

- `lib/features/game/services/game_feedback.dart`: `DeviceGameFeedback` (rung, `AudioController`).
- `lib/features/game/services/score_share_service.dart`: `PlatformScoreShareService`.
- `lib/core/firebase/firebase_gateway.dart`: một dòng `Firebase.initializeApp()` mặc định.
- `lib/features/game/logic/board_logic.dart`: file cũ; đã có test cho mọi hàm đang dùng, nên cần xem `lcov` để chắc chắn.

**Lượt này (attempt mới):** đã thêm test dùng `MethodChannel` giả (không chạm plugin thật): `test/features/game/services/game_feedback_test.dart` (kênh `xyz.luan/audioplayers`, `SystemChannels.platform` cho rung) và `test/features/game/services/score_share_service_test.dart` (kênh `path_provider` và `dev.fluttercommunity.plus/share`, `Screenshot` widget). Chưa chạy được; người dùng cần xem `lcov` ở CP-3. Rủi ro: tên kênh/phương thức của plugin có thể khác theo phiên bản, khi đó test chia sẻ chỉ kiểm tra nhánh log lỗi. Phương án dự phòng nếu `lcov` vẫn thiếu: thêm test dùng `MethodChannel` giả cho `audioplayers` và `share_plus`, hoặc đưa hai adapter ra file riêng và quyết định ngoại lệ ở Build & Test. Ngưỡng 80% không bị hạ.

## Ghi chú nền tảng

- **iOS**: `ios/Runner/GoogleService-Info.plist` có trong thư mục nhưng **chưa được tham chiếu trong `Runner.xcodeproj`** (0 lần xuất hiện trong `project.pbxproj`). Cần mở `ios/Runner.xcworkspace` trong Xcode, kéo file vào nhóm Runner, tích "Copy items if needed" và target Runner. Chưa làm thì Firebase iOS lỗi và app rơi vào chế độ offline với config mặc định. Không chặn U1 (tiêu chí tính theo Android).
- Không có `FirebaseOptions` và không có API key trong `lib/` (test `time_attack_removed_test.dart` kiểm tra bằng grep).
- Khuyến nghị trước phát hành: giới hạn API key Android theo package và SHA-1, iOS theo bundle (chưa làm ở U1, theo Q2=B).

## Ghi chú vận hành (review infra R-01, R-02)

Một Firebase project dùng chung cho debug và release, nên mọi thay đổi `level_config` ảnh hưởng người chơi thật.

**Checklist publish Remote Config**
1. Soạn JSON mới trong một file riêng, dán vào trình soạn thảo JSON của parameter `level_config`.
2. Kiểm tra: `version` ≥ 1; đúng 6 gem × 6 sub; `order` không trùng; `target_score` là số nguyên trong 1..10.000.000; không thêm `background_url` ngoài host cho phép.
3. Dùng điều kiện hoặc chỉ publish khi đã kiểm trên một máy thử (debug build đọc cùng project).
4. Sau publish, mở app (cache 12 giờ) và xem log `config_source=remote`. Nếu thấy `config_source=default` kèm một dòng lỗi thì JSON bị loại toàn bộ.

**Rollback Remote Config**: trong Firebase Console vào lịch sử phiên bản của Remote Config và khôi phục bản trước, rồi publish. Máy đã fetch bản xấu sẽ nhận bản mới sau tối đa 12 giờ (`minimumFetchInterval`); bản xấu không hợp lệ thì app đã tự dùng cấu hình mặc định.

**Tăng version code khi quay lại sau khi lên store**: Google Play và App Store không nhận cùng version code hai lần. Muốn phát hành lại bản sửa hoặc bản cũ, tăng số sau dấu `+` trong `pubspec.yaml` (`version: 1.0.0+N`) trước `flutter build appbundle` / `flutter build ipa`.

## Lệnh người dùng chạy

- CP-2: `flutter analyze` rồi `flutter test test/features/game/engine/`
- CP-3: `flutter analyze && flutter test --coverage`, rồi xem `coverage/lcov.info` theo từng file (`lcov --list coverage/lcov.info`).
- Theo nhóm: `flutter test test/core/config/`, `flutter test test/features/journey/`, `flutter test test/ui/`.
- Kiểm tra end-to-end bằng tay (DoD): offline thì level 1 target 500; online thì target từ Remote Config; thắng level 1, CONTINUE sang level 2, tắt app và mở lại vẫn ở level 2.

## Sửa sau lần chạy verify đầu tiên (Flutter 3.35.6 trong WSL)

Lần chạy đầu của `flutter analyze && flutter test --coverage` báo 1 lỗi analyze và 15 test đỏ. Đã sửa:

- **Lỗi app:** `ImageUrlPolicy` để lọt `%zz`, vì `Uri.tryParse` tự đổi thành `%25zz` nên `Uri.decodeFull` không ném lỗi. Đã thêm kiểm tra trên chuỗi gốc: mọi `%` phải đi kèm đúng 2 chữ số hex, sai thì trả `invalid_encoding`.
- **Lỗi test:**
  - Fake `FirebaseRemoteConfig` khai báo `settings` nullable, sai kiểu override. Đã đổi tên thành `appliedSettings`.
  - Test combo đặt khối thứ hai mà không gọi `applyClear()`, trái với hợp đồng của `BoardEngine.place`.
  - Hai test "thua không đụng tiến trình" coi việc ghi `tutorial_completed` ở lần đặt đầu là vi phạm, trong khi BR3.4 cho phép ghi. Đã thu hẹp lại thành "không ghi key `progress`".
  - `pumpGameScreen` chỉ pump một frame nên route không bao giờ chuyển xong. Đã thêm một `pump()`.
  - Ba widget test kết thúc khi timer của `flutter_animate` còn treo. Đã pump thêm 1 giây ở cuối.
- **Lint (bắt buộc vì `flutter analyze` mặc định fatal cả info):** đổi `withOpacity` thành `withValues(alpha:)` và bỏ hai `default` không bao giờ chạy tới trong 7 file cũ. Các file này đã được thêm vào `source-manifest.json`. Ngoài ra: `activeColor` đổi thành `activeThumbColor` ở Home, thêm ngoặc nhọn trong `board_logic.dart`, bỏ import thừa và helper `_settle` không dùng.
- `pubspec.lock` được resolve lại bằng Flutter 3.35.6: chỉ thêm các gói firebase, khớp với `pubspec.yaml`.

Kết quả: `flutter analyze` không còn issue nào, `flutter test --coverage` 191/191 test xanh.

**Coverage dòng dưới 80% ở file U1 (DoD-2):** `lib/core/utils/clock.dart` 2/4, `lib/core/firebase/default_level_config.dart` 4/6, `lib/core/config/level_config.dart` 5/7, `lib/core/firebase/firebase_gateway.dart` 6/8. Tổng các file đã nạp là 94,2%. Có 9 file trong `lib/` không được test nào nạp, trong đó có `main.dart` và `game_controller.dart` (code chết, xem review R-02). Ngưỡng 80% không bị hạ.

## Xử lý review lần 2

- **R-04 (BR5.7):** `revive()` xóa vùng 3×3, sau đó kiểm tra lại `hasMoves`. Nếu khay vẫn không đặt được khối nào, ván vào lại `lost` (không còn REVIVE) và phát `gameOver` lần nữa. Có test hồi quy: khay chỉ còn hai khối 1×4.
- **R-01 (C4):** đã thêm `lib/core/analytics/analytics_service.dart` gồm interface `AnalyticsService` (6 hàm theo C4, đều trả `Future<void>` và không throw) và `NoopAnalyticsService`, có test kèm theo. U1 chưa gọi analytics từ `LevelGameController`. U5 sẽ nối bản Firebase vào.
- **R-03 (C2):** chữ ký thực tế lệch so với C2 như sau:
  - `start(Level)` thay cho `start()`: level được truyền vào, không đọc ngầm.
  - `requestBack()` trả `bool` thay cho `quit()`: màn hình chỉ `pop` khi được phép (BR5.4/BR5.8).
  - `updatePreview(row, col)` thay cho `onDragUpdate(Offset)`: việc đổi tọa độ chạm sang ô thuộc widget (`BoardGeometry`), controller chỉ nhận ô.
  
  Hành vi và các trạng thái giữ đúng như C2.
- **R-05 (coverage DoD-2):** đã thêm test cho `SystemClock`, cho initializer Firebase mặc định khi không có platform (trả `failed`, không throw), cho `DefaultLevelConfig.parse` khi JSON nhúng bị hỏng (fail fast bằng `StateError`), và widget test 3 theme cho `BoardCell`, `DraggableBlock`, `ParticleExplosion`. `GemIds`, `SubIds`, `DefaultLevelConfig` đổi thành `abstract final class` để bỏ các constructor rỗng không bao giờ chạy. Không dùng `coverage:ignore`.
  - Kết quả: mọi file U1 trong `lib/` đạt ≥ 80%, **trừ `lib/main.dart`** (0%, không có test nào nạp). Tổng các file đã nạp đạt 96,8% (1344/1388).
  - `main.dart` là composition root, chỉ gọi `runApp` với các service thật. Đã thử smoke test gọi `main()` nhưng Splash bị kẹt vì platform channel trong môi trường test. Đề xuất: tách phần dựng service ra một hàm có test, hoặc kiểm chứng bằng chạy tay end-to-end. Người dùng quyết định ở checkpoint.
  - `remote_config_client.dart` chỉ chứa interface, không có dòng thực thi.
- **R-02:** `lib/features/game/controllers/game_controller.dart` là file 0 byte, không được import ở đâu. Chưa xóa, chờ người dùng đồng ý.

Kết quả verify: `flutter analyze` không còn issue, `flutter test --coverage` 209/209 test xanh.

## Request Changes 2026-11-17: Step 25–27

- **Step 25 (R-02):** đã xóa `lib/features/game/controllers/game_controller.dart`. File này rỗng (0 byte) và không có nơi nào import. Manifest vẫn giữ đường dẫn này, coi như một lần xóa.
- **Step 26 (DoD-2):** tách phần dựng service và cây Provider ra `lib/app_composition.dart`, gồm `createAppBootstrap()` (lúc dựng không có I/O, các tham số chỉ để test thay thế) và `buildRootApp()`. `main()` chỉ còn 3 dòng: `ensureInitialized`, `AudioController.init`, `runApp`. Test `test/app_composition_test.dart` kiểm tra bốn việc: dựng service thật mà không chạm tới Firebase, thay được từng phụ thuộc, `ThemeManager` nằm phía trên `BlockBlastApp`, và khi Firebase lỗi thì app đi từ Splash tới Home ở chế độ offline.
- **Step 27:** `flutter analyze` báo "No issues found!". `flutter test --coverage` cho 213/213 test xanh. Coverage dòng tính trên các file đã nạp là 97,1% (1357/1398). Mọi file U1 trong `lib/` đạt ≥ 80%, trừ hai file:
  - `lib/main.dart`: 3 dòng, không test nào nạp, vì đây là điểm vào gọi `runApp` trên binding thật. Logic thật của nó đã được test qua `app_composition.dart`.
  - `lib/core/config/remote_config_client.dart`: chỉ có interface, không có dòng thực thi nào.
