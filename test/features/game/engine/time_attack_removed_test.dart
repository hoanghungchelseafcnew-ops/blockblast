import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// BR6.3: Time Attack bị gỡ hoàn toàn khỏi lib/.
void main() {
  test('lib/ contains no Time Attack identifiers (BR6.3)', () {
    final pattern = RegExp(
      r'timeattack|time attack|high_score_time|_timeLeft|_startTimer',
      caseSensitive: false,
    );
    final offenders = <String>[];
    final files = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));
    for (final file in files) {
      if (pattern.hasMatch(file.readAsStringSync())) offenders.add(file.path);
    }
    expect(offenders, isEmpty);
  });

  test('lib/ contains no hardcoded Firebase API key (BR6.2)', () {
    final pattern = RegExp(r'AIza|apiKey|api_key');
    final offenders = <String>[];
    final files = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));
    for (final file in files) {
      if (pattern.hasMatch(file.readAsStringSync())) offenders.add(file.path);
    }
    expect(offenders, isEmpty);
  });
}
