import 'dart:async';
import 'dart:io' show Platform;

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart' as gma;

import '../../../core/log/gj_log.dart';

/// Trạng thái đồng ý (entities.md `ConsentStatus.state`).
enum ConsentState { notProcessed, required, granted, denied, notApplicable }

/// Kết quả mà cổng đồng ý của nền tảng trả về sau khi hỏi người dùng.
class ConsentResult {
  const ConsentResult({required this.state, required this.personalizedAllowed});

  final ConsentState state;
  final bool personalizedAllowed;
}

/// Cổng tới SDK đồng ý. Abstract để test dùng fake (NFR3.1).
abstract class ConsentGateway {
  /// Hỏi người dùng nếu cần (EU/EEA, xin phép theo dõi trên iOS) và trả kết
  /// quả. Có thể ném lỗi; [ConsentService] bắt lỗi đó.
  Future<ConsentResult> gather();
}

/// Xử lý đồng ý của người dùng trước mọi quảng cáo (BR3.1 đến BR3.4).
///
/// Chạy một lần mỗi phiên, ở nền, không chặn màn Splash (BR1.4).
class ConsentService {
  ConsentService(this._gateway);

  static const String _log = 'Consent';

  final ConsentGateway _gateway;
  Future<void>? _running;

  ConsentState _state = ConsentState.notProcessed;
  bool _personalizedAllowed = false;

  ConsentState get state => _state;

  /// Quảng cáo chỉ được yêu cầu khi đồng ý đã được xử lý (BR3.1).
  bool get isProcessed =>
      _state != ConsentState.notProcessed && _state != ConsentState.required;

  /// Chỉ đúng khi đã đồng ý hoặc không cần đồng ý (BR3.2, BR3.3).
  bool get personalizedAllowed => _personalizedAllowed;

  /// Hỏi đồng ý nếu chưa hỏi. Gọi nhiều lần chỉ chạy một lần.
  Future<void> ensure() => _running ??= _gather();

  Future<void> _gather() async {
    _state = ConsentState.required;
    try {
      final result = await _gateway.gather();
      _apply(result);
    } catch (e) {
      // Lỗi SDK: vẫn cho hiện quảng cáo nhưng không cá nhân hóa, an toàn
      // hơn là cá nhân hóa khi không biết người dùng đã chọn gì.
      GjLog.warn(_log, 'consent flow failed, using non-personalized ads', e);
      _apply(
        const ConsentResult(
          state: ConsentState.denied,
          personalizedAllowed: false,
        ),
      );
    }
    GjLog.info(_log, 'consent=${_state.name}');
  }

  void _apply(ConsentResult result) {
    var state = result.state;
    if (state == ConsentState.notProcessed || state == ConsentState.required) {
      // Cổng không được trả trạng thái chưa xong; coi như từ chối.
      state = ConsentState.denied;
    }
    _state = state;
    _personalizedAllowed =
        result.personalizedAllowed &&
        (state == ConsentState.granted || state == ConsentState.notApplicable);
  }
}

/// Cổng thật: UMP của `google_mobile_ads` cho EU/EEA và ATT trên iOS
/// (tech-stack-decisions.md).
class PlatformConsentGateway implements ConsentGateway {
  const PlatformConsentGateway();

  @override
  Future<ConsentResult> gather() async {
    final umpStatus = await _gatherUmp();
    final trackingAllowed = await _requestTracking();

    if (umpStatus == gma.ConsentStatus.notRequired) {
      return ConsentResult(
        state: trackingAllowed
            ? ConsentState.notApplicable
            : ConsentState.denied,
        personalizedAllowed: trackingAllowed,
      );
    }
    final canRequest = await gma.ConsentInformation.instance.canRequestAds();
    final granted = umpStatus == gma.ConsentStatus.obtained && canRequest;
    return ConsentResult(
      state: granted && trackingAllowed
          ? ConsentState.granted
          : ConsentState.denied,
      personalizedAllowed: granted && trackingAllowed,
    );
  }

  Future<gma.ConsentStatus> _gatherUmp() async {
    final updated = Completer<void>();
    gma.ConsentInformation.instance.requestConsentInfoUpdate(
      gma.ConsentRequestParameters(),
      () => updated.complete(),
      (error) => updated.completeError(StateError('consent info update')),
    );
    await updated.future;

    final dismissed = Completer<void>();
    gma.ConsentForm.loadAndShowConsentFormIfRequired((formError) {
      if (formError != null) {
        GjLog.warn('Consent', 'consent form failed');
      }
      dismissed.complete();
    });
    await dismissed.future;
    return gma.ConsentInformation.instance.getConsentStatus();
  }

  /// Xin phép theo dõi trên iOS. Nền tảng khác không cần nên trả true.
  Future<bool> _requestTracking() async {
    if (!Platform.isIOS) return true;
    var status = await AppTrackingTransparency.trackingAuthorizationStatus;
    if (status == TrackingStatus.notDetermined) {
      status = await AppTrackingTransparency.requestTrackingAuthorization();
    }
    return status == TrackingStatus.authorized ||
        status == TrackingStatus.notSupported;
  }
}
