import 'package:block_blast/core/config/level_config.dart';
import 'package:block_blast/core/theme/app_theme.dart';
import 'package:block_blast/core/theme/app_typography.dart';
import 'package:block_blast/core/theme/contrast.dart';
import 'package:block_blast/core/theme/gem_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/log_capture.dart';

void main() {
  late LogCapture log;

  setUp(() {
    log = LogCapture()..start();
  });

  group('GemTheme.forGem (FR12.1, C6)', () {
    const expected = <String, List<int>>{
      'rose_quartz': [0xFFFFB6C1, 0xFFFF69B4],
      'amethyst': [0xFF9966CC, 0xFF8B008B],
      'blue_topaz': [0xFF4FC3F7, 0xFF0288D1],
      'emerald': [0xFF50C878, 0xFF228B22],
      'sapphire': [0xFF0F52BA, 0xFF000080],
      'ruby': [0xFFE0115F, 0xFF8B0000],
    };

    test('every gem has the primary and secondary colours of FR12.1', () {
      for (final entry in expected.entries) {
        final palette = GemTheme.forGem(entry.key);
        expect(palette.primary, Color(entry.value[0]), reason: entry.key);
        expect(palette.secondary, Color(entry.value[1]), reason: entry.key);
      }
      expect(log.lines, isEmpty);
    });

    test('covers exactly the six gems of the journey', () {
      expect(GemTheme.gemIds.toList(), GemIds.all);
    });

    test('Amethyst uses #7A4FB0 for buttons, others use their primary', () {
      expect(GemTheme.forGem('amethyst').buttonFill, const Color(0xFF7A4FB0));
      for (final id in GemIds.all.where((g) => g != 'amethyst')) {
        final p = GemTheme.forGem(id);
        expect(p.buttonFill, p.primary, reason: id);
      }
    });

    test('an unknown gem falls back to Rose Quartz with a warning', () {
      final palette = GemTheme.forGem('opal');
      expect(palette.primary, const Color(0xFFFFB6C1));
      expect(log.where('unknown gem id'), hasLength(1));
    });

    test('the background gradient ends on #0F0C29', () {
      final colors = GemTheme.backgroundGradient(GemTheme.forGem('emerald'));
      expect(colors, hasLength(2));
      expect(colors.last, GemTheme.backgroundEnd);
      expect(colors.first, isNot(GemTheme.backgroundEnd));
    });
  });

  group('contrastRatio (WCAG 2.x)', () {
    test('black on white is 21:1 and a colour on itself is 1:1', () {
      expect(contrastRatio(Colors.black, Colors.white), closeTo(21, 0.01));
      expect(contrastRatio(Colors.red, Colors.red), closeTo(1, 0.0001));
    });

    test('is symmetric', () {
      const a = Color(0xFF0F52BA);
      const b = Color(0xFFFFFFFF);
      expect(contrastRatio(a, b), closeTo(contrastRatio(b, a), 1e-9));
    });

    test('matches the Sapphire value of the design system (7.15:1)', () {
      expect(
        contrastRatio(const Color(0xFF0F52BA), Colors.white),
        closeTo(7.15, 0.05),
      );
    });
  });

  group('WCAG AA checklist for the six gems (AC8.6.2, NFR9)', () {
    for (final id in GemIds.all) {
      test(id, () {
        final p = GemTheme.forGem(id);
        final gradient = GemTheme.backgroundGradient(p);
        expect(
          contrastRatio(p.onPrimary, p.buttonFill),
          greaterThanOrEqualTo(4.5),
          reason: 'button label on button fill',
        );
        for (final stop in gradient) {
          expect(
            contrastRatio(Colors.white, stop),
            greaterThanOrEqualTo(4.5),
            reason: 'white text on the background',
          );
          expect(
            contrastRatio(Colors.white, stop),
            greaterThanOrEqualTo(3),
            reason: 'progress bar border (UI component)',
          );
        }
      });
    }
  });

  group('AppTypography', () {
    test('display and headline use the bundled Righteous font', () {
      expect(AppTypography.display().fontFamily, 'Righteous');
      expect(AppTypography.headline().fontFamily, 'Righteous');
      expect(AppTypography.display(size: 60).fontSize, 60);
    });

    test('Montserrat styles set the wght axis to the font weight', () {
      final styles = <TextStyle, int>{
        AppTypography.title(): 700,
        AppTypography.body(): 600,
        AppTypography.caption(): 500,
      };
      styles.forEach((style, weight) {
        expect(style.fontFamily, 'Montserrat');
        expect(style.fontWeight!.value, weight);
        expect(style.fontVariations!.single.axis, 'wght');
        expect(style.fontVariations!.single.value, weight.toDouble());
      });
    });

    test('the app theme uses the bundled fonts', () {
      final theme = AppTheme.darkTheme;
      expect(theme.textTheme.headlineLarge!.fontFamily, 'Righteous');
      expect(theme.textTheme.bodyMedium!.fontFamily, 'Montserrat');
    });
  });
}
