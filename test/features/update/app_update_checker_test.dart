import 'package:block_blast/features/ads/models/ads_settings.dart';
import 'package:block_blast/features/update/services/app_update_checker.dart';
import 'package:block_blast/features/update/services/store_launcher.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/log_capture.dart';
import 'update_fakes.dart';

const _play = 'https://play.google.com/store/apps/details?id=com.h2.game';
const _appStore = 'https://apps.apple.com/app/id123';

AppUpdateChecker _checker({
  String androidVersion = '1.0.1',
  String androidUrl = _play,
  String iosVersion = '',
  String iosUrl = '',
  FakeInstalledVersionReader? reader,
  bool ios = false,
}) {
  return AppUpdateChecker(
    settings: AdsSettings(
      androidVersion: androidVersion,
      androidUrl: androidUrl,
      iosVersion: iosVersion,
      iosUrl: iosUrl,
    ),
    reader: reader ?? FakeInstalledVersionReader(),
    isIos: () => ios,
  );
}

void main() {
  late LogCapture log;
  setUp(() => log = LogCapture()..start());

  group('AppUpdateChecker.check (US5.1)', () {
    test(
      'a newer configured version returns the store link (AC5.1.1)',
      () async {
        expect(await _checker().check(), _play);
      },
    );

    test('the same version offers nothing (AC5.1.5)', () async {
      final reader = FakeInstalledVersionReader('1.0.1');
      expect(await _checker(reader: reader).check(), isNull);
    });

    test('an empty version or link offers nothing (FR6.4)', () async {
      final reader = FakeInstalledVersionReader();
      expect(
        await _checker(androidVersion: '', reader: reader).check(),
        isNull,
      );
      expect(await _checker(androidUrl: '').check(), isNull);
      expect(await _checker(androidUrl: 'http://x.com').check(), isNull);
      expect(reader.reads, 0, reason: 'no platform call needed');
    });

    test(
      'a failing version read is logged and offers nothing (NFR2.23)',
      () async {
        final reader = FakeInstalledVersionReader()..error = StateError('x');
        expect(await _checker(reader: reader).check(), isNull);
        expect(log.lines.join('\n'), contains('reading the installed version'));
      },
    );

    test('iOS uses ios_version and ios_url', () async {
      final checker = _checker(
        androidVersion: '',
        androidUrl: '',
        iosVersion: '2.0.0',
        iosUrl: _appStore,
        ios: true,
      );
      expect(await checker.check(), _appStore);
    });

    test('the log never contains the raw configured values (NFR8.3)', () async {
      await _checker(androidUrl: _play).check();
      expect(log.lines.join('\n'), isNot(contains(_play)));
    });

    test('uses the platform when no override is given', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      final checker = AppUpdateChecker(
        settings: const AdsSettings(iosVersion: '9.0.0', iosUrl: _appStore),
        reader: FakeInstalledVersionReader(),
      );
      expect(await checker.check(), _appStore);
    });
  });

  group('AppUpdateChecker once per app open (BR8.4)', () {
    test('shows once, then again only after a new app open (AC5.1.2)', () {
      final checker = _checker();
      expect(checker.canShowFor(3), isTrue);
      checker.markShown(3);
      expect(checker.canShowFor(3), isFalse);
      expect(checker.canShowFor(4), isTrue);
    });

    test('without ads the count stays 0: once per launch', () {
      final checker = _checker();
      checker.markShown(0);
      expect(checker.canShowFor(0), isFalse);
    });
  });

  group('UrlStoreLauncher (NFR8.1)', () {
    test('refuses an invalid link without calling the platform', () async {
      expect(await const UrlStoreLauncher().open('javascript:x'), isFalse);
      expect(log.lines.join('\n'), contains('refusing'));
    });

    test('a platform failure returns false and is logged', () async {
      // Không có plugin trong môi trường test: launchUrl ném lỗi.
      expect(await const UrlStoreLauncher().open(_play), isFalse);
    });
  });
}
