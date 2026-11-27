import 'dart:async';

import 'package:flutter/widgets.dart';

import 'ad_mediator.dart';

/// Báo cho [AdsService] mỗi lần ứng dụng quay lại trước màn hình từ nền
/// (BR5.1). Chỉ tính khi ứng dụng thật sự đã vào nền (`paused`), không tính
/// lúc chỉ mất focus tạm thời (`inactive`). Việc loại trừ lần quay lại do
/// quảng cáo hay hộp thoại hệ thống nằm ở [AdsService] (BR5.3).
class AdLifecycleObserver with WidgetsBindingObserver {
  AdLifecycleObserver(this._ads);

  final AdsService _ads;
  bool _wentToBackground = false;

  void attach() => WidgetsBinding.instance.addObserver(this);

  void detach() => WidgetsBinding.instance.removeObserver(this);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        _wentToBackground = true;
      case AppLifecycleState.resumed:
        if (!_wentToBackground) return;
        _wentToBackground = false;
        unawaited(_ads.onAppResumed());
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        break;
    }
  }
}
