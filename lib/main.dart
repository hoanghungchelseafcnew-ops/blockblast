import 'package:flutter/material.dart';

import 'app_composition.dart';
import 'core/audio/audio_controller.dart';

/// Điểm vào: chỉ khởi tạo binding, âm thanh và chạy cây widget gốc.
/// Phần dựng service nằm ở `app_composition.dart` để test được.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AudioController.init();
  runApp(buildRootApp(createAppBootstrap()));
}
