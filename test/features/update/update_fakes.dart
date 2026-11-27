import 'package:block_blast/features/update/services/installed_version_reader.dart';
import 'package:block_blast/features/update/services/store_launcher.dart';

/// Phiên bản đang cài giả: trả [version] hoặc ném [error].
class FakeInstalledVersionReader extends InstalledVersionReader {
  FakeInstalledVersionReader([this.version = '1.0.0']);

  String version;
  Object? error;
  int reads = 0;

  @override
  Future<String> read() async {
    reads++;
    final failure = error;
    if (failure != null) throw failure;
    return version;
  }
}

/// Trình mở cửa hàng giả: ghi lại đường dẫn đã mở.
class FakeStoreLauncher extends StoreLauncher {
  FakeStoreLauncher({this.result = true});

  bool result;
  final List<String> opened = <String>[];

  @override
  Future<bool> open(String url) async {
    opened.add(url);
    return result;
  }
}
