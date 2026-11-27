import 'package:flutter/material.dart';

import '../../../core/theme/app_typography.dart';
import '../../../core/theme/gem_theme.dart';
import '../../../shared/widgets/gem_primary_button.dart';

/// Popup báo có bản mới (u4-update-and-share, frontend-components.md).
///
/// UPDATE đóng popup rồi gọi [onUpdate]. LATER, back hoặc chạm ra ngoài chỉ
/// đóng popup (BR8.6). Mọi chuỗi đều tiếng Anh (NFR4).
Future<void> showUpdatePopup(
  BuildContext context, {
  required GemPalette palette,
  required VoidCallback onUpdate,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) => UpdatePopup(
      palette: palette,
      onLater: () => Navigator.of(dialogContext).pop(),
      onUpdate: () {
        Navigator.of(dialogContext).pop();
        onUpdate();
      },
    ),
  );
}

class UpdatePopup extends StatelessWidget {
  const UpdatePopup({
    super.key,
    required this.palette,
    required this.onLater,
    required this.onUpdate,
  });

  final GemPalette palette;
  final VoidCallback onLater;
  final VoidCallback onUpdate;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      key: const Key('update-popup'),
      backgroundColor: const Color(0xFF1C1C2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text('Update available', style: AppTypography.title()),
      content: Text(
        'A new version of Block Jewel is ready. '
        'Update now for the latest fixes and features.',
        style: AppTypography.body(size: 16),
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        TextButton(
          key: const Key('update-popup-later'),
          style: TextButton.styleFrom(minimumSize: const Size(96, 48)),
          onPressed: onLater,
          child: const Text('LATER', style: TextStyle(color: Colors.white70)),
        ),
        GemPrimaryButton(
          key: const Key('update-popup-update'),
          label: 'UPDATE',
          palette: palette,
          width: 140,
          onPressed: onUpdate,
        ),
      ],
    );
  }
}
