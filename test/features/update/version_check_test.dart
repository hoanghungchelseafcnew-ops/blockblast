import 'package:block_blast/features/ads/models/ads_settings.dart';
import 'package:block_blast/features/update/logic/version_check.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VersionCheck versions (BR8.1, BR8.2)', () {
    test('1.0.0 is older than 1.0.1 (AC5.1.1)', () {
      expect(
        VersionCheck.isNewer(installed: '1.0.0', configured: '1.0.1'),
        isTrue,
      );
    });

    test('equal or higher installed versions are not updates (AC5.1.5)', () {
      expect(
        VersionCheck.isNewer(installed: '1.0.1', configured: '1.0.1'),
        isFalse,
      );
      expect(
        VersionCheck.isNewer(installed: '1.2.0', configured: '1.0.9'),
        isFalse,
      );
    });

    test('missing parts count as 0', () {
      expect(
        VersionCheck.isNewer(installed: '1.0', configured: '1.0.0'),
        isFalse,
      );
      expect(
        VersionCheck.isNewer(installed: '1.0', configured: '1.0.1'),
        isTrue,
      );
    });

    test('compares numbers, not text', () {
      expect(
        VersionCheck.isNewer(installed: '1.0.9', configured: '1.0.10'),
        isTrue,
      );
    });

    test('the build number is ignored', () {
      expect(VersionCheck.parseVersion('1.2.3+45'), [1, 2, 3]);
      expect(
        VersionCheck.isNewer(installed: '1.0.0+9', configured: '1.0.0'),
        isFalse,
      );
    });

    test('malformed versions never offer an update (FR6.4)', () {
      for (final bad in [
        '',
        ' ',
        'abc',
        '1..0',
        '1.0-beta',
        'v1.0',
        '-1',
        '1.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0',
      ]) {
        expect(VersionCheck.parseVersion(bad), isNull, reason: bad);
        expect(
          VersionCheck.isNewer(installed: '1.0.0', configured: bad),
          isFalse,
          reason: bad,
        );
      }
    });
  });

  group('VersionCheck store links (BR8.3, NFR8.1)', () {
    test('accepts https store pages', () {
      expect(
        VersionCheck.isValidStoreUrl(
          'https://play.google.com/store/apps/details?id=com.h2.game.block_blast',
        ),
        isTrue,
      );
      expect(
        VersionCheck.isValidStoreUrl('https://apps.apple.com/app/id1'),
        isTrue,
      );
    });

    test('rejects anything that is not a full https link', () {
      for (final bad in [
        '',
        'http://play.google.com/store',
        'javascript:alert(1)',
        'market://details?id=x',
        'itms-apps://apps.apple.com/app/id1',
        'https://',
        'play.google.com/store',
        'https://exa mple.com',
        'https://example.com/\nhttps://evil.com',
      ]) {
        expect(VersionCheck.isValidStoreUrl(bad), isFalse, reason: bad);
      }
    });

    test('picks the link of the running platform', () {
      const settings = AdsSettings(
        androidUrl: 'https://play.google.com/store/apps/details?id=a',
        iosUrl: 'not a link',
        androidVersion: '1.0.1',
        iosVersion: '2.0.0',
      );
      expect(
        VersionCheck.storeUrlFor(settings, ios: false),
        'https://play.google.com/store/apps/details?id=a',
      );
      expect(VersionCheck.storeUrlFor(settings, ios: true), isNull);
      expect(VersionCheck.configuredVersionFor(settings, ios: false), '1.0.1');
      expect(VersionCheck.configuredVersionFor(settings, ios: true), '2.0.0');
    });
  });
}
