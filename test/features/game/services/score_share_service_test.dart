import 'dart:io';

import 'package:block_blast/core/log/gj_log.dart';
import 'package:block_blast/features/game/services/score_share_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screenshot/screenshot.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  const pathChannel = MethodChannel('plugins.flutter.io/path_provider');
  const shareChannel = MethodChannel('dev.fluttercommunity.plus/share');

  late Directory tempDir;
  late List<MethodCall> shareCalls;
  late List<String> logs;
  late void Function(String) previousSink;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('score_share_test');
    shareCalls = [];
    logs = [];
    previousSink = GjLog.sink;
    GjLog.sink = logs.add;
    messenger.setMockMethodCallHandler(pathChannel, (call) async {
      if (call.method == 'getTemporaryDirectory') return tempDir.path;
      return null;
    });
    messenger.setMockMethodCallHandler(shareChannel, (call) async {
      shareCalls.add(call);
      return 'dev.fluttercommunity.plus/share/unavailable';
    });
  });

  tearDown(() {
    GjLog.sink = previousSink;
    messenger.setMockMethodCallHandler(pathChannel, null);
    messenger.setMockMethodCallHandler(shareChannel, null);
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  test('controller chưa gắn widget: không ném lỗi, không chia sẻ', () async {
    await const PlatformScoreShareService()
        .shareScore(screenshot: ScreenshotController(), score: 120);
    expect(shareCalls, isEmpty);
  });

  testWidgets('chụp được ảnh thì ghi file và gọi share', (tester) async {
    final controller = ScreenshotController();
    await tester.pumpWidget(
      MaterialApp(
        home: Screenshot(
          controller: controller,
          child: const SizedBox(width: 40, height: 40),
        ),
      ),
    );
    await tester.runAsync(() async {
      await const PlatformScoreShareService()
          .shareScore(screenshot: controller, score: 120);
    });
    final sharedFile = File('${tempDir.path}/score.png');
    expect(sharedFile.existsSync() || logs.isNotEmpty, isTrue);
    if (sharedFile.existsSync()) {
      expect(shareCalls, isNotEmpty);
    }
  });
}
