/// Âm thanh của game (FR13.1). `asset` tính từ thư mục `assets/`, theo cách
/// `audioplayers` đọc `AssetSource`.
///
/// Mọi file là WAV gốc, tổng hợp bằng code, không dùng mẫu âm của bên thứ ba.
/// Đặt khối có ba biến thể; ăn dòng và combo có ba mức theo số dòng và bậc.
enum Sfx {
  place('sounds/place.wav'),
  place2('sounds/place2.wav'),
  place3('sounds/place3.wav'),
  clear('sounds/clear.wav'),
  clear2('sounds/clear2.wav'),
  clear3('sounds/clear3.wav'),
  combo('sounds/combo.wav'),
  combo2('sounds/combo2.wav'),
  combo3('sounds/combo3.wav'),
  bomb('sounds/bomb.wav'),
  gameOver('sounds/gameover.wav'),
  victory('sounds/victory.wav'),
  unlock('sounds/unlock.wav');

  const Sfx(this.asset);

  final String asset;
}
