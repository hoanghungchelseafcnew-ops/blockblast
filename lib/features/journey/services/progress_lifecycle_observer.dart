import 'dart:async';

import 'package:flutter/widgets.dart';

import 'progress_repository.dart';

/// Khi app vào nền (`paused`), ghi lại mọi key còn dirty (WF7, BR3.3).
///
/// U5 tự thêm observer vòng đời riêng cho `SessionTracker`; U1 không để hook
/// đặc biệt nào.
class ProgressLifecycleObserver with WidgetsBindingObserver {
  ProgressLifecycleObserver(this._repository);

  final ProgressRepository _repository;

  void attach() => WidgetsBinding.instance.addObserver(this);

  void detach() => WidgetsBinding.instance.removeObserver(this);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      unawaited(_repository.flushDirty());
    }
  }
}
