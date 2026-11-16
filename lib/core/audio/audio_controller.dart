import 'package:audioplayers/audioplayers.dart';

class AudioController {
  static final AudioPlayer _bgmPlayer = AudioPlayer();
  static final AudioPlayer _sfxPlayer = AudioPlayer();
  
  static bool _isMuted = false;

  static bool get isMuted => _isMuted;

  static void toggleMute() {
    _isMuted = !_isMuted;
    if (_isMuted) {
      _bgmPlayer.pause();
    } else {
      _bgmPlayer.resume();
    }
  }

  // Pre-load sounds to avoid delay
  static Future<void> init() async {
    // In a real scenario, we'd preload assets here using AudioCache
    // For now we just set up the audio pool structure
  }

  static Future<void> playPlace() async {
    if (_isMuted) return;
    try {
      await _sfxPlayer.play(AssetSource('sounds/place.wav'));
    } catch (e) {
      // Ignored if asset missing
    }
  }

  static Future<void> playClear() async {
    if (_isMuted) return;
    try {
      await _sfxPlayer.play(AssetSource('sounds/clear.wav'));
    } catch (e) {
      // Ignored if asset missing
    }
  }

  static Future<void> playCombo() async {
    if (_isMuted) return;
    try {
      await _sfxPlayer.play(AssetSource('sounds/combo.wav'));
    } catch (e) {
      // Ignored if asset missing
    }
  }

  static Future<void> playGameOver() async {
    if (_isMuted) return;
    try {
      await _sfxPlayer.play(AssetSource('sounds/gameover.wav'));
    } catch (e) {
      // Ignored if asset missing
    }
  }
}
