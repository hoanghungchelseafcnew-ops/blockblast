// Mô phỏng người chơi tự động để cân điểm mốc và tìm lỗi tiềm ẩn.
//
// Không chạy trong `flutter test` thường. Chạy riêng:
//   SIM=1 flutter test test/simulation/difficulty_simulation_test.dart --timeout=none
// Biến môi trường tùy chọn: SIM_N (số ván mỗi mức, mặc định 30),
// SIM_CAP (số nước tối đa mỗi ván, mặc định 250), SIM_OUT (file JSON kết quả).
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:block_blast/features/game/engine/board_engine.dart';
import 'package:block_blast/features/game/logic/tray_generator.dart';
import 'package:block_blast/features/game/logic/tray_models.dart';
import 'package:block_blast/features/game/logic/tray_solver.dart';
import 'package:block_blast/features/game/models/block_model.dart';
import 'package:block_blast/features/game/models/cell_model.dart';
import 'package:flutter_test/flutter_test.dart';

final _env = Platform.environment;
final int _gamesPerLevel = int.tryParse(_env['SIM_N'] ?? '') ?? 30;
final int _moveCap = int.tryParse(_env['SIM_CAP'] ?? '') ?? 250;
final String _outPath = _env['SIM_OUT'] ?? '/tmp/sim_report.json';

const _levelsToSimulate = [1, 4, 8, 12, 16, 20, 24, 28, 32, 36];

enum _Skill { casual, average, expert }

// ---------------------------------------------------------------------------
// Mô hình bảng bằng bitmask (độc lập với engine, chỉ để bot suy nghĩ)
// ---------------------------------------------------------------------------

({List<int> rows, int cleared})? _place(
  List<int> rows,
  List<int> mask,
  int w,
  int r,
  int c,
) {
  final h = mask.length;
  if (r < 0 || c < 0 || r + h > 8 || c + w > 8) return null;
  for (var i = 0; i < h; i++) {
    if ((rows[r + i] & (mask[i] << c)) != 0) return null;
  }
  final placed = List<int>.of(rows);
  for (var i = 0; i < h; i++) {
    placed[r + i] |= mask[i] << c;
  }
  var fullRows = 0;
  var columns = 0xFF;
  var cleared = 0;
  for (var i = 0; i < 8; i++) {
    if (placed[i] == 0xFF) {
      fullRows |= 1 << i;
      cleared++;
    }
    columns &= placed[i];
  }
  cleared += TraySolver.popCount(columns);
  if (cleared == 0) return (rows: placed, cleared: 0);
  final out = List<int>.filled(8, 0);
  for (var i = 0; i < 8; i++) {
    out[i] = (fullRows & (1 << i)) != 0 ? 0 : placed[i] & ~columns & 0xFF;
  }
  return (rows: out, cleared: cleared);
}

bool _filled(List<int> rows, int r, int c) =>
    r < 0 || r > 7 || c < 0 || c > 7 || (rows[r] & (1 << c)) != 0;

double _eval(List<int> rows, int cleared) {
  var holes = 0.0;
  var filled = 0;
  for (var r = 0; r < 8; r++) {
    for (var c = 0; c < 8; c++) {
      if ((rows[r] & (1 << c)) != 0) {
        filled++;
        continue;
      }
      var blocked = 0;
      if (_filled(rows, r - 1, c)) blocked++;
      if (_filled(rows, r + 1, c)) blocked++;
      if (_filled(rows, r, c - 1)) blocked++;
      if (_filled(rows, r, c + 1)) blocked++;
      if (blocked == 4) {
        holes += 2;
      } else if (blocked == 3) {
        holes += 1;
      }
    }
  }
  return cleared * 55.0 - holes * 9.0 - filled * 0.6;
}

class _Cand {
  _Cand(this.index, this.row, this.col, this.rows, this.cleared, this.value);
  final int index; // vị trí của khối trong khay
  final int row;
  final int col;
  final List<int> rows;
  final int cleared;
  final double value;
}

List<_Cand> _candidates(List<int> rows, List<BlockModel> tray, int index) {
  final block = tray[index];
  final mask = TraySolver.shapeMask(block.shape);
  final out = <_Cand>[];
  for (var r = 0; r + block.rows <= 8; r++) {
    for (var c = 0; c + block.cols <= 8; c++) {
      final p = _place(rows, mask, block.cols, r, c);
      if (p == null) continue;
      out.add(_Cand(index, r, c, p.rows, p.cleared, _eval(p.rows, p.cleared)));
    }
  }
  return out;
}

double _plan(List<int> rows, List<BlockModel> tray, Set<int> used, int k) {
  if (used.length == tray.length) return _eval(rows, 0);
  var best = -1e9;
  for (var i = 0; i < tray.length; i++) {
    if (used.contains(i)) continue;
    final cands = _candidates(rows, tray, i)
      ..sort((a, b) => b.value.compareTo(a.value));
    for (final cand in cands.take(k)) {
      final next = {...used, i};
      final v = cand.cleared * 55.0 + _plan(cand.rows, tray, next, k);
      if (v > best) best = v;
    }
  }
  // Không còn khối nào đặt được: coi như rất xấu nhưng vẫn hợp lệ.
  return best == -1e9 ? -500 : best;
}

_Cand? _choose(
  BoardEngine engine,
  _Skill skill,
  Random rng,
) {
  final rows = TraySolver.rowsOf(engine.board);
  final tray = engine.tray;
  final all = <_Cand>[];
  for (var i = 0; i < tray.length; i++) {
    all.addAll(_candidates(rows, tray, i));
  }
  if (all.isEmpty) return null;
  switch (skill) {
    case _Skill.casual:
      if (rng.nextDouble() < 0.55) return all[rng.nextInt(all.length)];
      return all.reduce((a, b) => a.value >= b.value ? a : b);
    case _Skill.average:
      return all.reduce((a, b) => a.value >= b.value ? a : b);
    case _Skill.expert:
      _Cand? best;
      var bestValue = -1e18;
      for (var i = 0; i < tray.length; i++) {
        final cands = all.where((c) => c.index == i).toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        for (final cand in cands.take(5)) {
          final v = cand.cleared * 55.0 + _plan(cand.rows, tray, {i}, 4);
          if (v > bestValue) {
            bestValue = v;
            best = cand;
          }
        }
      }
      return best ?? all.first;
  }
}

// ---------------------------------------------------------------------------
// Ghi nhận khi sinh khay
// ---------------------------------------------------------------------------

class _RecordingGenerator extends TrayGenerator {
  _RecordingGenerator(Random random) : super(random: random);

  final tiers = <String, int>{};
  final violations = <String>[];
  var calls = 0;
  var micros = 0;
  var maxMicros = 0;

  @override
  TrayResult prepare(List<List<CellModel>> board, int level) {
    final watch = Stopwatch()..start();
    final result = super.prepare(board, level);
    watch.stop();
    calls++;
    micros += watch.elapsedMicroseconds;
    if (watch.elapsedMicroseconds > maxMicros) {
      maxMicros = watch.elapsedMicroseconds;
    }
    final key = result.gameOver ? 'gameOver' : result.tier!.name;
    tiers[key] = (tiers[key] ?? 0) + 1;

    final empties = board.expand((r) => r).where((c) => !c.filled).length;
    if (result.gameOver && empties >= 3) {
      violations.add('gameOver với $empties ô trống (level $level)');
    }
    if (!result.gameOver && result.tray.length != 3) {
      violations.add('khay có ${result.tray.length} khối (level $level)');
    }
    if (!result.gameOver) {
      final outcome = TraySolver.solve(
        TraySolver.rowsOf(board),
        result.tray,
        strict: result.tier == SolvabilityTier.strict,
        budget: NodeBudget(2000000),
      );
      if (outcome == SolveOutcome.unsolvable) {
        violations.add('khay ${result.tier!.name} không giải được '
            '(level $level)');
      }
    }
    return result;
  }
}

class _Game {
  _Game(this.score, this.moves, this.end, this.traj, this.lines);
  final int score;
  final int moves;
  final String end; // stuck | refill | cap
  final List<int> traj;
  final int lines;
}

Future<_Game> _play(
  int level,
  _Skill skill,
  int seed,
  _RecordingGenerator generator,
  Random rng,
) async {
  final engine = BoardEngine(
    trayGenerator: generator,
    difficultyLevel: level,
    clearDelay: Duration.zero,
  );
  final traj = <int>[0];
  var moves = 0;
  var lines = 0;
  var end = 'cap';
  if (!engine.hasMoves) return _Game(0, 0, 'refill', traj, 0);
  while (moves < _moveCap) {
    final cand = _choose(engine, skill, rng);
    if (cand == null) {
      end = 'stuck';
      break;
    }
    final block = engine.tray[cand.index];
    final result = engine.place(block, cand.row, cand.col);
    if (result == null) {
      throw StateError('bot chose an illegal move');
    }
    lines += result.linesCleared;
    await engine.applyClear();
    moves++;
    traj.add(engine.score);
    final refilled = engine.refillTrayIfEmpty();
    if (!engine.hasMoves) {
      end = refilled ? 'refill' : 'stuck';
      break;
    }
  }
  return _Game(engine.score, moves, end, traj, lines);
}

// ---------------------------------------------------------------------------
// Phân tích
// ---------------------------------------------------------------------------

double _quantile(List<num> sorted, double q) {
  if (sorted.isEmpty) return 0;
  final pos = (sorted.length - 1) * q;
  final lo = pos.floor();
  final hi = pos.ceil();
  return sorted[lo] + (sorted[hi] - sorted[lo]) * (pos - lo);
}

int _niceRound(double v) {
  if (v < 1000) return (v / 50).round() * 50;
  if (v < 10000) return (v / 100).round() * 100;
  if (v < 100000) return (v / 500).round() * 500;
  return (v / 5000).round() * 5000;
}

/// Tỉ lệ thắng mong muốn của người chơi "casual" theo level: dễ ở đầu, khó dần.
double _desiredWinRate(int level) => 0.92 - (0.92 - 0.50) * (level - 1) / 35;

void main() {
  test(
    'difficulty simulation',
    () async {
      final report = <String, dynamic>{
        'gamesPerLevel': _gamesPerLevel,
        'moveCap': _moveCap,
      };
      final perLevel = <int, Map<_Skill, List<_Game>>>{};
      final violations = <String>{};
      final tierTotals = <int, Map<String, int>>{};
      final timing = <int, Map<String, num>>{};

      for (final level in _levelsToSimulate) {
        perLevel[level] = {};
        final gen = _RecordingGenerator(Random(level * 7919));
        for (final skill in _Skill.values) {
          final n = skill == _Skill.expert
              ? max(6, _gamesPerLevel ~/ 3)
              : _gamesPerLevel;
          final games = <_Game>[];
          for (var g = 0; g < n; g++) {
            final rng = Random(level * 1000 + g * 31 + skill.index);
            games.add(await _play(level, skill, g, gen, rng));
          }
          perLevel[level]![skill] = games;
        }
        violations.addAll(gen.violations);
        tierTotals[level] = gen.tiers;
        timing[level] = {
          'calls': gen.calls,
          'avgMs': gen.calls == 0 ? 0 : gen.micros / gen.calls / 1000,
          'maxMs': gen.maxMicros / 1000,
        };
        stdout.writeln('level $level done');
      }

      // --- Bảng sống sót / điểm theo level ---
      final lines = StringBuffer();
      lines.writeln('\n=== Kết quả theo level (mỗi mức $_gamesPerLevel ván, '
          'tối đa $_moveCap nước) ===');
      lines.writeln('level | skill   | thua% | điểm TB   | điểm P50  | '
          'điểm P90   | nước TB | điểm/nước');
      for (final level in _levelsToSimulate) {
        for (final skill in _Skill.values) {
          final games = perLevel[level]![skill]!;
          final lost = games.where((g) => g.end != 'cap').length;
          final scores = games.map((g) => g.score).toList()..sort();
          final avgScore = scores.reduce((a, b) => a + b) / scores.length;
          final avgMoves =
              games.map((g) => g.moves).reduce((a, b) => a + b) / games.length;
          lines.writeln(
            '${level.toString().padLeft(5)} | ${skill.name.padRight(7)} | '
            '${(100 * lost / games.length).toStringAsFixed(0).padLeft(4)}% | '
            '${avgScore.toStringAsFixed(0).padLeft(9)} | '
            '${_quantile(scores, 0.5).toStringAsFixed(0).padLeft(9)} | '
            '${_quantile(scores, 0.9).toStringAsFixed(0).padLeft(10)} | '
            '${avgMoves.toStringAsFixed(0).padLeft(7)} | '
            '${(avgScore / max(1, avgMoves)).toStringAsFixed(1).padLeft(8)}',
          );
        }
      }

      // --- Cách thua ---
      lines.writeln('\n=== Cách thua (tổng các ván) ===');
      for (final skill in _Skill.values) {
        var stuck = 0, refill = 0, cap = 0;
        for (final level in _levelsToSimulate) {
          for (final g in perLevel[level]![skill]!) {
            if (g.end == 'stuck') stuck++;
            if (g.end == 'refill') refill++;
            if (g.end == 'cap') cap++;
          }
        }
        lines.writeln('${skill.name}: hết chỗ giữa khay=$stuck, '
            'không có khay mới=$refill, chạm giới hạn nước=$cap');
      }

      // --- Mức bảo đảm của khay ---
      lines.writeln('\n=== Khay theo mức bảo đảm và thời gian chuẩn bị ===');
      for (final level in _levelsToSimulate) {
        final t = tierTotals[level]!;
        final tm = timing[level]!;
        lines.writeln(
          'level $level: $t | TB ${tm['avgMs']!.toStringAsFixed(2)} ms, '
          'max ${tm['maxMs']!.toStringAsFixed(2)} ms',
        );
      }

      // --- Điểm mốc đề xuất ---
      // Mốc sao cho người chơi casual thắng đúng tỉ lệ mong muốn.
      final rawTargets = <int, double>{};
      for (final level in _levelsToSimulate) {
        final scores =
            perLevel[level]![_Skill.casual]!.map((g) => g.score).toList()
              ..sort();
        final p = _desiredWinRate(level);
        rawTargets[level] = _quantile(scores, 1 - p);
      }
      // Nội suy theo log giữa các level đã mô phỏng, rồi ép tăng dần.
      final targets = <int, int>{};
      var previous = 0;
      for (var level = 1; level <= 36; level++) {
        double value;
        final keys = rawTargets.keys.toList()..sort();
        if (rawTargets.containsKey(level)) {
          value = rawTargets[level]!;
        } else {
          final lo = keys.lastWhere((k) => k < level);
          final hi = keys.firstWhere((k) => k > level);
          final a = max(1.0, rawTargets[lo]!);
          final b = max(1.0, rawTargets[hi]!);
          final t = (level - lo) / (hi - lo);
          value = exp(log(a) + (log(b) - log(a)) * t);
        }
        var rounded = _niceRound(max(value, 100));
        if (rounded <= previous) rounded = previous + 50;
        targets[level] = rounded;
        previous = rounded;
      }
      lines.writeln('\n=== Mốc điểm đề xuất (level: điểm) ===');
      for (var gem = 0; gem < 6; gem++) {
        final row = [
          for (var s = 1; s <= 6; s++) targets[gem * 6 + s],
        ];
        lines.writeln('gem ${gem + 1}: $row');
      }

      // --- Tỉ lệ thắng với mốc đề xuất ---
      lines.writeln('\n=== Tỉ lệ thắng với mốc đề xuất (level mô phỏng) ===');
      lines.writeln('level | mốc    | casual | average | expert | nước TB '
          '(average, ván thắng)');
      for (final level in _levelsToSimulate) {
        final target = targets[level]!;
        String winRate(_Skill s) {
          final games = perLevel[level]![s]!;
          final won = games.where((g) => g.score >= target).length;
          return '${(100 * won / games.length).toStringAsFixed(0)}%';
        }

        final wins = perLevel[level]![_Skill.average]!
            .where((g) => g.score >= target)
            .toList();
        var moves = 0.0;
        for (final g in wins) {
          moves += g.traj.indexWhere((s) => s >= target);
        }
        final avgMoves = wins.isEmpty ? 0 : moves / wins.length;
        lines.writeln(
          '${level.toString().padLeft(5)} | ${target.toString().padLeft(6)} | '
          '${winRate(_Skill.casual).padLeft(6)} | '
          '${winRate(_Skill.average).padLeft(7)} | '
          '${winRate(_Skill.expert).padLeft(6)} | '
          '${avgMoves.toStringAsFixed(0)}',
        );
      }

      lines.writeln('\n=== Vi phạm bất biến (lỗi tiềm ẩn) ===');
      if (violations.isEmpty) {
        lines.writeln('Không phát hiện vi phạm.');
      } else {
        for (final v in violations.take(30)) {
          lines.writeln('- $v');
        }
        lines.writeln('Tổng ${violations.length} loại vi phạm.');
      }

      report['targets'] = {
        for (final e in targets.entries) '${e.key}': e.value,
      };
      report['violations'] = violations.toList();
      File(_outPath).writeAsStringSync(
        const JsonEncoder.withIndent('  ').convert(report),
      );
      stdout.writeln(lines.toString());
      File('$_outPath.txt').writeAsStringSync(lines.toString());

      expect(violations, isEmpty);
    },
    skip: _env['SIM'] == '1' ? false : 'Chạy bằng SIM=1 (mô phỏng dài)',
    timeout: Timeout.none,
  );
}
