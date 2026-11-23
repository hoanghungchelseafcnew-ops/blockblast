import 'package:block_blast/core/config/image_url_policy.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/log_capture.dart';

void main() {
  group('ImageUrlPolicy', () {
    test('accepts firebasestorage.googleapis.com over https', () {
      expect(
        ImageUrlPolicy.isAllowed(
          'https://firebasestorage.googleapis.com/v0/b/b/o/bg%2F1.jpg?alt=media',
        ),
        isTrue,
      );
    });

    test('accepts <label>.firebasestorage.app and explicit port 443', () {
      expect(
        ImageUrlPolicy.isAllowed(
          'https://demo.firebasestorage.app/v0/b/x/o/1.jpg',
        ),
        isTrue,
      );
      expect(
        ImageUrlPolicy.isAllowed(
          'https://firebasestorage.googleapis.com:443/v0/b/x/o/1.jpg',
        ),
        isTrue,
      );
    });

    test('rejects empty, blank and null input as "empty"', () {
      expect(ImageUrlPolicy.isAllowed(null), isFalse);
      expect(ImageUrlPolicy.isAllowed(''), isFalse);
      expect(ImageUrlPolicy.rejectionReason('   '), 'empty');
    });

    test('rejects the wrong scheme', () {
      expect(
        ImageUrlPolicy.rejectionReason(
          'http://firebasestorage.googleapis.com/v0/b/x/o/1.jpg',
        ),
        'scheme',
      );
    });

    test('rejects userinfo, unusual ports and fragments', () {
      expect(
        ImageUrlPolicy.rejectionReason(
          'https://user:pw@firebasestorage.googleapis.com/a.jpg',
        ),
        'userinfo',
      );
      expect(
        ImageUrlPolicy.rejectionReason(
          'https://firebasestorage.googleapis.com:8443/a.jpg',
        ),
        'port',
      );
      expect(
        ImageUrlPolicy.rejectionReason(
          'https://firebasestorage.googleapis.com/a.jpg#frag',
        ),
        'fragment',
      );
    });

    test('rejects look-alike and unrelated hosts', () {
      for (final url in [
        'https://evilfirebasestorage.app/a.jpg',
        'https://firebasestorage.app/a.jpg',
        'https://firebasestorage.googleapis.com.evil.com/a.jpg',
        'https://example.com/a.jpg',
      ]) {
        expect(ImageUrlPolicy.rejectionReason(url), 'host', reason: url);
      }
    });

    test('never accepts a path that still decodes to a ".." segment', () {
      // Uri.parse có thể tự chuẩn hóa dot-segment; bất biến cần giữ là:
      // nếu URL được chấp nhận thì path đã giải mã không còn đoạn "..".
      for (final url in [
        'https://firebasestorage.googleapis.com/v0/%2e%2e/secret.jpg',
        'https://firebasestorage.googleapis.com/a/../b',
        'https://firebasestorage.googleapis.com/a/%2E%2E/b',
      ]) {
        if (ImageUrlPolicy.isAllowed(url)) {
          final decoded = Uri.decodeFull(Uri.parse(url).path);
          expect(decoded.split('/').contains('..'), isFalse, reason: url);
        }
      }
    });

    test('a malformed percent sequence returns false without throwing', () {
      final log = LogCapture()..start();
      late bool allowed;
      expect(
        () => allowed = ImageUrlPolicy.isAllowed(
          'https://firebasestorage.googleapis.com/bad%zzpath.jpg',
        ),
        returnsNormally,
      );
      expect(allowed, isFalse);
      expect(log.leaksUrlOrRawJson, isFalse);
    });
  });
}
