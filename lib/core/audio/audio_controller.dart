import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import '../../features/journey/services/progress_repository.dart';
import '../log/gj_log.dart';
import 'sfx.dart';

/// Phát một file âm thanh ngắn. Bọc plugin để test thay bằng bản giả.
abstract class SfxPlayer {
  Future<void> play(String asset);
  Future<void> stop();
}

/// Triển khai thật bằng `audioplayers`. Dùng một nhóm player xoay vòng để các
/// âm (đặt khối, ăn dòng, combo, bom) phát chồng lên nhau thay vì cắt nhau.
/// Player chỉ được tạo ở lần phát đầu tiên, nên dựng app không gọi plugin
/// nền tảng.
class AudioplayersSfxPlayer implements SfxPlayer {
  AudioplayersSfxPlayer({this.poolSize = 4});

  final int poolSize;
  final List<AudioPlayer> _players = <AudioPlayer>[];
  int _next = 0;

  AudioPlayer get _ready {
    if (_players.length < poolSize) {
      final player = AudioPlayer();
      unawaited(player.setPlayerMode(PlayerMode.lowLatency));
      _players.add(player);
      return player;
    }
    final player = _players[_next];
    _next = (_next + 1) % _players.length;
    return player;
  }

  @override
  Future<void> play(String asset) => _ready.play(AssetSource(asset));

  @override
  Future<void> stop() async {
    for (final player in _players) {
      await player.stop();
    }
  }
}

/// Âm thanh của game (FR13). Trạng thái tắt âm thanh lưu ở key `sound_muted`
/// qua [ProgressRepository] (FR13.2). Khi tắt, không có lệnh phát nào tới
/// player (AC5.3.3). Lỗi phát được log, không bị nuốt (FR13.3).
class AudioController extends ChangeNotifier {
  AudioController({required ProgressRepository progress, SfxPlayer? player})
    : _progress = progress,
      _player = player ?? AudioplayersSfxPlayer();

  final ProgressRepository _progress;
  final SfxPlayer _player;

  bool get isMuted => _progress.soundMuted;

  /// Bật hoặc tắt âm thanh và lưu lại. Tắt thì dừng âm thanh đang phát.
  Future<void> setMuted(bool muted) async {
    if (muted == isMuted) return;
    final save = _progress.setSoundMuted(muted);
    notifyListeners();
    if (muted) await stopSfx();
    await save;
  }

  /// Phát [sfx], trừ khi đang tắt âm thanh. Không bao giờ ném lỗi.
  Future<void> play(Sfx sfx) async {
    if (isMuted) return;
    try {
      await _player.play(sfx.asset);
    } catch (e) {
      GjLog.warn('Audio', 'play failed: ${sfx.name}', e);
    }
  }

  /// Dừng âm thanh đang phát (khi rời màn Victory). Không bao giờ ném lỗi.
  Future<void> stopSfx() async {
    try {
      await _player.stop();
    } catch (e) {
      GjLog.warn('Audio', 'stop failed', e);
    }
  }
}
