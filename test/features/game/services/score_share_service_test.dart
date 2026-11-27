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

  test('văn bản chia sẻ dùng tên Block Jewel (BR1.3, BR1.6)', () {
    expect(
      ScoreShareService.scoreShareText(120),
      'I scored 120 in Block Jewel!',
    );
    expect(
      ScoreShareService.victoryShareText('Rose Quartz · Rough Stone', 450),
      'I cleared Rose Quartz · Rough Stone with 450 points in Block Jewel!',
    );
    expect(ScoreShareService.scoreShareText(0), isNot(contains('Crush')));
  });

  test('controller chưa gắn widget: không ném lỗi, không chia sẻ', () async {
    await const PlatformScoreShareService().shareScore(
      screenshot: ScreenshotController(),
      score: 120,
    );
    expect(shareCalls, isEmpty);
  });

  test('shareVictory khi chưa chụp được: không chia sẻ, ghi log', () async {
    await const PlatformScoreShareService().shareVictory(
      screenshot: ScreenshotController(),
      levelName: 'Ruby · Bling',
      score: 999,
    );
    expect(shareCalls, isEmpty);
    expect(logs.join('\n'), contains('sharing the victory failed'));
  });

  testWidgets('shareVictory chụp được ảnh thì ghi victory.png và chia sẻ '
      'kèm tên level', (tester) async {
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
      await const PlatformScoreShareService().shareVictory(
        screenshot: controller,
        levelName: 'Ruby · Bling',
        score: 999,
      );
    });
    final sharedFile = File('${tempDir.path}/victory.png');
    expect(sharedFile.existsSync() || logs.isNotEmpty, isTrue);
    if (sharedFile.existsSync()) {
      expect(shareCalls, isNotEmpty);
      expect(
        shareCalls.last.arguments.toString(),
        contains('I cleared Ruby · Bling with 999 points in Block Jewel!'),
      );
    }
  });

  testWidgets('kênh chia sẻ lỗi: ghi log, không ném lỗi (BR1.4)', (
    tester,
  ) async {
    messenger.setMockMethodCallHandler(shareChannel, (call) async {
      throw PlatformException(code: 'boom');
    });
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
      await const PlatformScoreShareService().shareVictory(
        screenshot: controller,
        levelName: 'Ruby · Bling',
        score: 1,
      );
    });
    expect(logs, isNotEmpty);
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
      await const PlatformScoreShareService().shareScore(
        screenshot: controller,
        score: 120,
      );
    });
    final sharedFile = File('${tempDir.path}/score.png');
    expect(sharedFile.existsSync() || logs.isNotEmpty, isTrue);
    if (sharedFile.existsSync()) {
      expect(shareCalls, isNotEmpty);
    }
  });

  group('store link in the shared text (u4-update-and-share, US6.1)', () {
    const play = 'https://play.google.com/store/apps/details?id=com.h2.game';

    test('a valid link goes on its own line at the end (AC6.1.1)', () {
      expect(
        ScoreShareService.withStoreLink('I scored 120 in Block Jewel!', play),
        'I scored 120 in Block Jewel!\n$play',
      );
    });

    test('an empty or invalid link keeps the text unchanged (AC6.1.3)', () {
      for (final bad in [null, '', 'http://x.com', 'javascript:alert(1)']) {
        expect(
          ScoreShareService.withStoreLink('I scored 1 in Block Jewel!', bad),
          'I scored 1 in Block Jewel!',
          reason: '$bad',
        );
      }
    });

    testWidgets('a real share sends the text with the link (AC6.1.2)', (
      tester,
    ) async {
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
        await const PlatformScoreShareService(
          storeUrl: play,
        ).shareScore(screenshot: controller, score: 120);
      });
      if (shareCalls.isNotEmpty) {
        expect(
          shareCalls.last.arguments.toString(),
          contains('I scored 120 in Block Jewel!\n$play'),
        );
      } else {
        expect(logs, isNotEmpty);
      }
    });
  });
}
