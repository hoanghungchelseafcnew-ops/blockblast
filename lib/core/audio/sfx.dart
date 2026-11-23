/// Sáu âm thanh của game (FR13.1). `asset` tính từ thư mục `assets/`, theo
/// cách `audioplayers` đọc `AssetSource`.
enum Sfx {
  place('sounds/place.wav'),
  clear('sounds/clear.wav'),
  combo('sounds/combo.wav'),
  gameOver('sounds/gameover.wav'),
  victory('sounds/victory.wav'),
  unlock('sounds/unlock.wav');

  const Sfx(this.asset);

  final String asset;
}
