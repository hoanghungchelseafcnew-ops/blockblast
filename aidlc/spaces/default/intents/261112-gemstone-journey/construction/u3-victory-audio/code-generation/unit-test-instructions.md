# Hướng dẫn test — U3 `u3-victory-audio`

## Chiến lược

- Test strategy: **standard** (5–8 test mỗi component, unit test cộng integration cho ranh giới chính). Phương pháp: **test-after**. Mỗi lớp được implement trước, rồi viết và chạy test của lớp đó.
- AI chạy các lệnh dưới đây bằng Flutter Linux 3.41.5 trong WSL. Người dùng không build trên Windows trong lúc U3 đang được sinh code. Khi U3 xong, người dùng chạy `flutter pub get` trên Windows rồi mới build.

## Thiết lập test

- Framework: `flutter_test`, cùng `fakeAsync` (có trong `flutter_test` qua `package:fake_async`) cho các hẹn giờ 600ms và 2.5 giây. Không thêm thư viện mock.
- Fake viết tay:
  - `FakeSfxPlayer`: ghi lại asset đã phát và số lần `stop`; có thể ném lỗi.
  - `RecordingFeedback`: mở rộng bản sẵn có với `victory`, `unlock` và `stopSfx`.
  - Dùng lại `FakeProgressStore` và `LogCapture`.
- Reduced motion: bọc widget trong `MediaQuery(data: MediaQueryData(disableAnimations: true))`.
- Cấu trúc thư mục test:
  - `test/core/audio/sfx_test.dart`, `test/core/audio/audio_controller_test.dart` (mới)
  - `test/features/victory/victory_variant_test.dart`, `test/features/victory/victory_overlay_test.dart` (mới)
  - `test/features/game/engine/board_geometry_test.dart` (sửa: khối nâng phía trên ngón tay)
  - `test/features/journey/progress_repository_test.dart`, `level_game_controller_test.dart` (sửa)
  - `test/features/game/services/game_feedback_test.dart` (sửa)
  - `test/ui/game_screen_test.dart`, `test/ui/splash_home_test.dart`, `test/ui/ui_test_helpers.dart` (sửa)

## Lệnh chạy (phạm vi U3)

Lệnh mốc trước khi sửa (đã runnable sau `flutter pub get`):

```bash
flutter test test/features/journey/level_game_controller_test.dart test/ui/game_screen_test.dart
```

Lệnh theo lớp của U3 (chạy từ gốc dự án):

```bash
flutter test test/core/audio/ test/features/victory/victory_variant_test.dart test/features/game/engine/board_geometry_test.dart
flutter test test/features/journey/progress_repository_test.dart
flutter test test/core/audio/audio_controller_test.dart test/features/journey/level_game_controller_test.dart test/features/game/services/game_feedback_test.dart
flutter test test/features/victory/ test/ui/
```

Lệnh kiểm chứng của checkpoint (Construction Verification Command đã duyệt):

```bash
flutter analyze && flutter test --coverage
```

Xem coverage theo file trong `coverage/lcov.info`.

## Mục tiêu coverage

- Mọi file Dart mà U3 **tạo mới hoặc sửa** có coverage dòng **≥ 80%** (DoD-2), gồm cả `lib/core/audio/audio_controller.dart`.
- Coverage dòng toàn codebase ≥ 80%.
- `flutter analyze` không có lỗi hay cảnh báo (DoD-5).
- Không hạ ngưỡng nào để một bước đạt. Nếu một file không đạt, ghi rõ con số và lý do trong `code-summary.md`.

## Danh mục test chính

| Component | Nội dung bắt buộc |
|-----------|-------------------|
| `Sfx` | đủ 6 âm thanh; asset của từng âm thanh tồn tại |
| `VictoryVariant.of` | sub; gemUnlock; journeyComplete; journeyComplete thắng unlockedGemId |
| `BoardGeometry` (nâng khối) | 1×1, 3×3, 1×5: ô từ `cellFor` khớp với vị trí vẽ của khối; khối cách ngón tay 1.5 ô; chạm gần mép dưới vẫn đặt được hàng cuối; ngoài bảng thì trả ô ngoài biên |
| `ProgressRepository` (`sound_muted`) | mặc định false; đọc true; giá trị sai kiểu → false + log; lưu rồi đọc lại; ghi lỗi → dirty; chỉ đọc không ghi |
| `AudioController` | phát đúng asset; mute chặn cả 6 âm thanh; `setMuted` được lưu; lỗi player chỉ log; `stopSfx` |
| `LevelGameController` (Victory) | `victory` khi thắng; `unlock` sau 600ms cho Bling và level 36; CONTINUE hủy unlock + `stopSfx`; CONTINUE một lần; level 36 không có CONTINUE |
| `VictoryOverlay` / `ConfettiLayer` | chữ và nút của W-4, W-5, W-5a; không có CONTINUE ở W-5a; khóa sau lần bấm đầu; reduced motion bỏ confetti; confetti dừng sau 2.5 giây |
| UI tích hợp | biến thể đúng trong màn chơi; CONTINUE sang level kế; BACK TO MENU ở level 36; khối đang kéo nằm phía trên ngón tay và khớp preview; công tắc âm thanh được lưu |

## Mocking và dữ liệu test

- Âm thanh: không phát âm thanh thật trong test. Mọi lần phát đi qua `FakeSfxPlayer`.
- Catalog: `LevelCatalog` từ `DefaultLevelConfig`. Ca Bling dùng level 6, ca level 36 dùng `levelWith(36, 10)`.
- Hẹn giờ: `fakeAsync` cho 600ms và 2.5 giây; `resolveTimeout` tiêm được như U2.
- Không có test nào luôn đúng. Mỗi test kiểm một hành vi cụ thể.
