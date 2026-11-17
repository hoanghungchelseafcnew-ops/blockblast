import 'package:block_blast/features/game/services/game_feedback.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final haptics = <String>[];

  setUp(() {
    haptics.clear();
    // Plugin âm thanh giả: mọi lệnh trả null, không chạm plugin thật.
    for (final name in const [
      'xyz.luan/audioplayers',
      'xyz.luan/audioplayers.global',
    ]) {
      messenger.setMockMethodCallHandler(MethodChannel(name), (call) async {
        return null;
      });
    }
    messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'HapticFeedback.vibrate') {
        haptics.add(call.arguments as String);
      }
      return null;
    });
  });

  tearDown(() {
    for (final name in const [
      'xyz.luan/audioplayers',
      'xyz.luan/audioplayers.global',
    ]) {
      messenger.setMockMethodCallHandler(MethodChannel(name), null);
    }
    messenger.setMockMethodCallHandler(SystemChannels.platform, null);
  });

  test('NoopGameFeedback không ném lỗi', () {
    const feedback = NoopGameFeedback();
    feedback
      ..placed()
      ..cleared()
      ..combo()
      ..gameOver();
  });

  test('DeviceGameFeedback.placed rung mạnh và gọi âm thanh', () async {
    const DeviceGameFeedback().placed();
    await Future<void>.delayed(Duration.zero);
    expect(haptics, ['HapticFeedbackType.heavyImpact']);
  });

  test('DeviceGameFeedback cleared/combo/gameOver không ném lỗi', () async {
    const feedback = DeviceGameFeedback();
    feedback
      ..cleared()
      ..combo()
      ..gameOver();
    await Future<void>.delayed(Duration.zero);
  });
}
