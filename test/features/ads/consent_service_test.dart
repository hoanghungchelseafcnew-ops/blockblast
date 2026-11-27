import 'dart:async';

import 'package:block_blast/core/log/gj_log.dart';
import 'package:block_blast/features/ads/services/consent_service.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ads_fakes.dart';

void main() {
  late List<String> logs;
  late GjLogSink previousSink;

  setUp(() {
    logs = <String>[];
    previousSink = GjLog.sink;
    GjLog.sink = logs.add;
  });

  tearDown(() => GjLog.sink = previousSink);

  group('ConsentService', () {
    test('is not processed before the flow runs (BR3.1)', () {
      final consent = ConsentService(FakeConsentGateway());
      expect(consent.state, ConsentState.notProcessed);
      expect(consent.isProcessed, isFalse);
      expect(consent.personalizedAllowed, isFalse);
    });

    test('stays not processed while the dialog is open (BR3.1)', () async {
      final gateway = FakeConsentGateway()
        ..pending = Completer<ConsentResult>();
      final consent = ConsentService(gateway);
      unawaited(consent.ensure());
      await Future<void>.delayed(Duration.zero);
      expect(consent.state, ConsentState.required);
      expect(consent.isProcessed, isFalse);
    });

    test('granted allows personalized ads (BR3.3)', () async {
      final consent = ConsentService(
        FakeConsentGateway(
          result: const ConsentResult(
            state: ConsentState.granted,
            personalizedAllowed: true,
          ),
        ),
      );
      await consent.ensure();
      expect(consent.isProcessed, isTrue);
      expect(consent.personalizedAllowed, isTrue);
    });

    test('denied keeps ads but non-personalized (BR3.2)', () async {
      final consent = ConsentService(
        FakeConsentGateway(
          result: const ConsentResult(
            state: ConsentState.denied,
            personalizedAllowed: true,
          ),
        ),
      );
      await consent.ensure();
      expect(consent.state, ConsentState.denied);
      expect(consent.isProcessed, isTrue);
      expect(consent.personalizedAllowed, isFalse);
    });

    test('not applicable behaves like granted (BR3.3)', () async {
      final consent = ConsentService(
        FakeConsentGateway(
          result: const ConsentResult(
            state: ConsentState.notApplicable,
            personalizedAllowed: true,
          ),
        ),
      );
      await consent.ensure();
      expect(consent.personalizedAllowed, isTrue);
    });

    test('an SDK error falls back to non-personalized and is logged', () async {
      final consent = ConsentService(
        FakeConsentGateway(error: StateError('ump down')),
      );
      await consent.ensure();
      expect(consent.state, ConsentState.denied);
      expect(consent.isProcessed, isTrue);
      expect(consent.personalizedAllowed, isFalse);
      expect(logs.first, contains('consent flow failed'));
    });

    test(
      'a gateway that reports an unfinished state is treated as denied',
      () async {
        final consent = ConsentService(
          FakeConsentGateway(
            result: const ConsentResult(
              state: ConsentState.required,
              personalizedAllowed: true,
            ),
          ),
        );
        await consent.ensure();
        expect(consent.state, ConsentState.denied);
        expect(consent.personalizedAllowed, isFalse);
      },
    );

    test('asks only once per session', () async {
      final gateway = FakeConsentGateway();
      final consent = ConsentService(gateway);
      await Future.wait([consent.ensure(), consent.ensure()]);
      await consent.ensure();
      expect(gateway.calls, 1);
    });
  });
}
