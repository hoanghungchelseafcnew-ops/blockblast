import 'dart:async';

import 'package:firebase_core/firebase_core.dart';

import '../log/gj_log.dart';

/// Kết quả khởi tạo Firebase.
enum FirebaseStatus { ok, failed, timeout }

/// Bọc `Firebase.initializeApp` với timeout và bắt mọi lỗi (D-R1, BR1.5).
///
/// `init()` không bao giờ throw. Khi không phải `ok`, app chơi offline với
/// cấu hình mặc định trong phiên này.
class FirebaseGateway {
  FirebaseGateway({
    Future<void> Function()? initializer,
    this.timeout = const Duration(milliseconds: 1500),
  }) : _initializer = initializer ?? _defaultInitializer;

  final Future<void> Function() _initializer;
  final Duration timeout;

  static Future<void> _defaultInitializer() async {
    // Không truyền FirebaseOptions: Firebase đọc từ google-services.json /
    // GoogleService-Info.plist (D-S3).
    await Firebase.initializeApp();
  }

  Future<FirebaseStatus> init() async {
    try {
      await _initializer().timeout(timeout);
      return FirebaseStatus.ok;
    } on TimeoutException catch (e) {
      GjLog.warn('Firebase', 'initializeApp timed out', e);
      return FirebaseStatus.timeout;
    } catch (e) {
      // `catch (e)` bắt cả Exception lẫn Error (NFR6.2).
      GjLog.error('Firebase', 'initializeApp failed', e);
      return FirebaseStatus.failed;
    }
  }
}
