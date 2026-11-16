import 'package:block_blast/app.dart';
import 'package:block_blast/core/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('BlockBlastApp starts and shows the home screen',
      (WidgetTester tester) async {
    // Bỏ qua hộp thoại Daily Gift bằng cách đặt ngày đăng nhập là hôm nay.
    final today = DateTime.now().toIso8601String().split('T')[0];
    SharedPreferences.setMockInitialValues({'last_login_date': today});

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeManager()),
        ],
        child: const BlockBlastApp(),
      ),
    );
    await tester.pump(const Duration(seconds: 2));

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('CLASSIC MODE'), findsOneWidget);
  });
}
