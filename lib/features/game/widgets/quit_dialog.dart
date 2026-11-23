import 'package:flutter/material.dart';

import '../../../core/theme/app_typography.dart';
import '../../../core/theme/gem_theme.dart';

/// Hỏi "Quit this level?" (FR11.2, AC2.5.1) hoặc "Quit?" ở chế độ endless.
/// Trả true khi người chơi chọn QUIT, false khi chọn CANCEL hoặc đóng dialog.
Future<bool> showQuitDialog(
  BuildContext context,
  GemPalette palette, {
  QuitMode mode = QuitMode.level,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (_) => QuitDialog(palette: palette, mode: mode),
  );
  return result ?? false;
}

enum QuitMode { level, endless }

/// Dialog xác nhận thoát giữa ván. CANCEL có focus mặc định. QUIT dùng màu
/// nút của gem đang chơi.
class QuitDialog extends StatelessWidget {
  const QuitDialog({
    super.key,
    required this.palette,
    this.mode = QuitMode.level,
  });

  static const Size _minButtonSize = Size(112, 48);

  final GemPalette palette;
  final QuitMode mode;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      key: const Key('quit-dialog'),
      backgroundColor: const Color(0xFF1C1C2E),
      title: Text(
        mode == QuitMode.endless ? 'Quit?' : 'Quit this level?',
        key: const Key('quit-dialog-title'),
        // Cùng họ font Montserrat với hai nút để dialog đồng nhất.
        style: AppTypography.title(),
      ),
      content: mode == QuitMode.endless
          ? Text(
              'Your score will be saved.',
              key: const Key('quit-dialog-message'),
              style: AppTypography.body(),
            )
          : Text(
              'Your progress will be saved.',
              key: const Key('quit-dialog-message'),
              style: AppTypography.body(),
            ),
      actions: [
        TextButton(
          key: const Key('quit-cancel-button'),
          autofocus: true,
          style: TextButton.styleFrom(minimumSize: _minButtonSize),
          onPressed: () => Navigator.of(context).pop(false),
          child: Text('CANCEL', style: AppTypography.body()),
        ),
        ElevatedButton(
          key: const Key('quit-confirm-button'),
          style: ElevatedButton.styleFrom(
            minimumSize: _minButtonSize,
            backgroundColor: palette.buttonFill,
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(
            'QUIT',
            style: AppTypography.body(color: palette.onPrimary),
          ),
        ),
      ],
    );
  }
}
