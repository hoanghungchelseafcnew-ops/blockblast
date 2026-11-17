import 'package:block_blast/app.dart';
import 'package:block_blast/app_composition.dart';
import 'package:block_blast/core/firebase/firebase_gateway.dart';
import 'package:block_blast/core/theme/theme_manager.dart';
import 'package:block_blast/features/home/screens/home_screen.dart';
import 'package:block_blast/features/journey/services/app_bootstrap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes/fake_progress_store.dart';
import 'fakes/fake_remote_config_client.dart';

void _skipDailyGift() {
  final today = DateTime.now().toIso8601String().split('T')[0];
  SharedPreferences.setMockInitialValues({'last_login_date': today});
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('createAppBootstrap', () {
    test('builds the real services without touching Firebase or storage', () {
      // Construction must not do I/O: Firebase is not available here, so any
      // eager call would throw.
      expect(createAppBootstrap(), isA<AppBootstrap>());
    });

    test('accepts replacements for every external dependency', () {
      final bootstrap = createAppBootstrap(
        gateway: FirebaseGateway(initializer: () async {}),
        remoteConfigFactory: () => FakeRemoteConfigClient(),
        progressStore: FakeProgressStore(),
      );
      expect(bootstrap, isA<AppBootstrap>());
    });
  });

  group('buildRootApp', () {
    testWidgets('provides ThemeManager above BlockBlastApp', (tester) async {
      _skipDailyGift();
      await tester.pumpWidget(
        buildRootApp(
          createAppBootstrap(
            gateway: FirebaseGateway(initializer: () async {}),
            remoteConfigFactory: () => FakeRemoteConfigClient(),
            progressStore: FakeProgressStore(),
          ),
        ),
      );
      final app = find.byType(BlockBlastApp);
      expect(app, findsOneWidget);
      expect(
        Provider.of<ThemeManager>(tester.element(app), listen: false),
        isA<ThemeManager>(),
      );
    });

    testWidgets('goes from Splash to Home when Firebase fails (offline)', (
      tester,
    ) async {
      _skipDailyGift();
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        buildRootApp(
          createAppBootstrap(
            gateway: FirebaseGateway(
              initializer: () async => throw StateError('no firebase'),
            ),
            remoteConfigFactory: () => FakeRemoteConfigClient(),
            progressStore: FakeProgressStore(),
          ),
        ),
      );
      for (var i = 0; i < 12; i++) {
        await tester.pump(const Duration(milliseconds: 400));
        if (find.byType(HomeScreen).evaluate().isNotEmpty) break;
      }
      expect(find.byType(HomeScreen), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
    });
  });
}
