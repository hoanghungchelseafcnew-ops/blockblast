import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Các file Dart trong lib/, trừ [except].
List<File> _libFiles({Set<String> except = const {}}) {
  return Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .where((f) => !except.contains(f.path.replaceAll(r'\', '/')))
      .toList();
}

List<String> _offenders(RegExp pattern, List<File> files) => [
  for (final f in files)
    if (pattern.hasMatch(f.readAsStringSync())) f.path,
];

/// FR10.2, FR12.2: theme chọn tay, Daily Gift và nền hạt chuyển động đã bị gỡ.
void main() {
  test('lib/ has no theme selection left (FR12.2, AC5.4.2)', () {
    final pattern = RegExp(r'ThemeManager|AppThemeType|theme_manager\.dart');
    expect(_offenders(pattern, _libFiles()), isEmpty);
  });

  test('lib/ has no Daily Gift left (FR10.2, AC5.2.1)', () {
    // Định danh code và chuỗi UI cũ; chú thích nhắc tới FR10.2 thì không tính.
    final pattern = RegExp(
      r"_checkDailyReward|_showRewardDialog|'DAILY GIFT!'|Daily Reward|'CLAIM'",
    );
    expect(_offenders(pattern, _libFiles()), isEmpty);
  });

  test('legacy prefs keys appear only in the repository that deletes them', () {
    final pattern = RegExp(r'theme_index|last_login_date');
    final files = _libFiles(
      except: {'lib/features/journey/services/progress_repository.dart'},
    );
    expect(_offenders(pattern, files), isEmpty);
  });

  test('the particle background is gone (design-system-mapping, Nền)', () {
    expect(
      File('lib/core/widgets/animated_background.dart').existsSync(),
      isFalse,
    );
    expect(_offenders(RegExp(r'AnimatedBackground'), _libFiles()), isEmpty);
  });
}
