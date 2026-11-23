import 'package:flutter/material.dart';

import 'app_composition.dart';

/// Điểm vào: chỉ khởi tạo binding, hướng màn hình và chạy cây widget gốc.
/// Phần dựng service (kể cả âm thanh) nằm ở `app_composition.dart` và
/// `AppBootstrap` để test được.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureSystemUi();
  runApp(buildRootApp(createAppBootstrap()));
}
