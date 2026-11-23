import 'package:block_blast/app.dart';
import 'package:block_blast/app_composition.dart';
import 'package:block_blast/core/firebase/firebase_gateway.dart';
import 'package:block_blast/features/home/screens/home_screen.dart';
import 'package:block_blast/features/journey/services/app_bootstrap.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes/fake_progress_store.dart';
import 'fakes/fake_remote_config_client.dart';

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

  group('configureSystemUi (NFR8, AC8.6.1)', () {
    test('locks the app to portrait up', () async {
      final calls = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
            calls.add(call);
            return null;
          });
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, null),
      );

      await configureSystemUi();

      final call = calls.singleWhere(
        (c) => c.method == 'SystemChrome.setPreferredOrientations',
      );
      expect(call.arguments, ['DeviceOrientation.portraitUp']);
    });
  });

  group('buildRootApp', () {
    testWidgets('is BlockBlastApp with no theme provider above it (FR12.2)', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final root = buildRootApp(
        createAppBootstrap(
          gateway: FirebaseGateway(initializer: () async {}),
          remoteConfigFactory: () => FakeRemoteConfigClient(),
          progressStore: FakeProgressStore(),
        ),
      );
      expect(root, isA<BlockBlastApp>());
      await tester.pumpWidget(root);
      expect(find.byType(BlockBlastApp), findsOneWidget);
    });

    testWidgets('goes from Splash to Home when Firebase fails (offline)', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
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
