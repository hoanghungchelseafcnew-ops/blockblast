import 'package:block_blast/app.dart';
import 'package:block_blast/core/firebase/firebase_gateway.dart';
import 'package:block_blast/core/theme/theme_manager.dart';
import 'package:block_blast/features/home/screens/home_screen.dart';
import 'package:block_blast/features/journey/services/app_bootstrap.dart';
import 'package:block_blast/features/journey/services/progress_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes/fake_clock.dart';
import 'fakes/fake_progress_store.dart';
import 'fakes/fake_remote_config_client.dart';

void main() {
  testWidgets('BlockBlastApp starts on Splash and then shows the Home screen',
      (WidgetTester tester) async {
    // Bỏ qua hộp thoại Daily Gift bằng cách đặt ngày đăng nhập là hôm nay.
    final today = DateTime.now().toIso8601String().split('T')[0];
    SharedPreferences.setMockInitialValues({'last_login_date': today});
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final bootstrap = AppBootstrap(
      gateway: FirebaseGateway(initializer: () async {}),
      remoteConfigFactory: () => FakeRemoteConfigClient(),
      progress: ProgressRepository(FakeProgressStore()),
      clock: FakeClock(),
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeManager()),
        ],
        child: BlockBlastApp(bootstrap: bootstrap),
      ),
    );
    expect(find.byKey(const Key('splash-logo')), findsOneWidget);

    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 250));
    }

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('PLAY'), findsOneWidget);
    expect(find.text('CLASSIC MODE'), findsNothing);
  });
}
