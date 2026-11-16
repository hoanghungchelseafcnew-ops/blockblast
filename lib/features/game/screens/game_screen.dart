import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

import '../logic/board_logic.dart';
import '../logic/block_generator.dart';
import '../models/block_model.dart';
import '../models/cell_model.dart';
import '../widgets/game_board.dart';
import '../widgets/block_palette.dart';
import '../../../core/constants/game_constants.dart';
import '../../../core/theme/theme_manager.dart';
import '../../../core/audio/audio_controller.dart';
import '../../../core/constants/colors.dart';
import '../../../core/widgets/animated_background.dart';

enum GameMode { classic, timeAttack }

class GameScreen extends StatefulWidget {
  final GameMode mode;
  const GameScreen({super.key, this.mode = GameMode.classic});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool isGameOver = false;
  late List<List<CellModel>> board;
  late List<BlockModel> blocks;
  BlockModel? activeBlock;
  Offset? lastDragPosition;
  final GlobalKey _boardKey = GlobalKey();
  int score = 0;
  int highScore = 0;
  bool isRevived = false;
  int comboStreak = 0;
  double cellSize = 0;
  Timer? _timer;
  int _timeLeft = 120;
  
  final ScreenshotController screenshotController = ScreenshotController();
  bool isTutorialActive = false;
  int tutorialStep = 0;
  String? comboText;

  @override
  void initState() {
    super.initState();
    board = BoardLogic.createEmptyBoard();
    blocks = BlockGenerator.generateThree();
    _loadHighScore();
    _checkTutorial();
    if (widget.mode == GameMode.timeAttack) _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isGameOver) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _triggerGameOver();
        }
      });
    });
  }

  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    String key = widget.mode == GameMode.timeAttack ? 'high_score_time' : 'high_score';
    setState(() => highScore = prefs.getInt(key) ?? 0);
  }

  Future<void> _checkAndSaveHighScore() async {
    if (score > highScore) {
      highScore = score;
      final prefs = await SharedPreferences.getInstance();
      String key = widget.mode == GameMode.timeAttack ? 'high_score_time' : 'high_score';
      await prefs.setInt(key, highScore);
    }
  }

  Future<void> _checkTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool('tutorial_completed') ?? false)) {
      setState(() => isTutorialActive = true);
    }
  }

  Future<void> _completeTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tutorial_completed', true);
    setState(() => isTutorialActive = false);
  }

  Future<void> _shareScore() async {
    final image = await screenshotController.capture();
    if (image != null) {
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/score.png';
      await File(path).writeAsBytes(image);
      await Share.shareXFiles([XFile(path)], text: 'I scored $score in Block Crush! 🎮✨');
    }
  }

  void updatePreview(Offset globalPosition) {
    if (activeBlock == null) return;
    lastDragPosition = globalPosition;
    
    final RenderBox boardBox = _boardKey.currentContext!.findRenderObject() as RenderBox;
    final Offset local = boardBox.globalToLocal(globalPosition);
    
    const double padding = GameConstants.boardPadding + 10.0;
    final double availableWidth = boardBox.size.width - (padding * 2);
    cellSize = availableWidth / GameConstants.boardSize;

    double gridX = local.dx - padding;
    double gridY = local.dy - padding;

    int startCol = ((gridX - (activeBlock!.cols * cellSize) / 2) / cellSize).round();
    int startRow = ((gridY - (activeBlock!.rows * cellSize) / 2) / cellSize).round();

    _clearPreview();
    
    if (startRow >= 0 && startCol >= 0 && 
        startRow <= GameConstants.boardSize - activeBlock!.rows &&
        startCol <= GameConstants.boardSize - activeBlock!.cols) {
      if (BoardLogic.canPlaceBlock(board, activeBlock!, startRow, startCol)) {
        for (int r = 0; r < activeBlock!.rows; r++) {
          for (int c = 0; c < activeBlock!.cols; c++) {
            if (activeBlock!.shape[r][c] == 1) {
              board[startRow + r][startCol + c].preview = true;
              board[startRow + r][startCol + c].previewColor = activeBlock!.color.withOpacity(0.5);
            }
          }
        }
      }
    }
    setState(() {});
  }

  void _clearPreview() {
    for (var row in board) {
      for (var cell in row) {
        cell.preview = false;
        cell.previewColor = null;
      }
    }
  }

  Future<void> placeBlock() async {
    if (activeBlock == null || lastDragPosition == null) {
      _clearPreview();
      setState(() => activeBlock = null);
      return;
    }

    final RenderBox boardBox = _boardKey.currentContext!.findRenderObject() as RenderBox;
    final Offset local = boardBox.globalToLocal(lastDragPosition!);
    
    const double padding = GameConstants.boardPadding + 10.0;
    final double availableWidth = boardBox.size.width - (padding * 2);
    cellSize = availableWidth / GameConstants.boardSize;

    double gridX = local.dx - padding;
    double gridY = local.dy - padding;

    int startCol = ((gridX - (activeBlock!.cols * cellSize) / 2) / cellSize).round();
    int startRow = ((gridY - (activeBlock!.rows * cellSize) / 2) / cellSize).round();

    if (startRow >= 0 && startCol >= 0 && 
        startRow <= GameConstants.boardSize - activeBlock!.rows &&
        startCol <= GameConstants.boardSize - activeBlock!.cols &&
        BoardLogic.canPlaceBlock(board, activeBlock!, startRow, startCol)) {
      
      HapticFeedback.heavyImpact();
      AudioController.playPlace();
      
      int cellsPlaced = 0;
      for (var r in activeBlock!.shape) for (var c in r) if (c == 1) cellsPlaced++;

      setState(() {
        BoardLogic.placeBlock(board, activeBlock!, startRow, startCol);
        blocks.remove(activeBlock);
        score += cellsPlaced * 10;
        if (widget.mode == GameMode.timeAttack) _timeLeft += 2;
      });

      final cleared = BoardLogic.clearCompletedLines(board);
      if (cleared > 0) {
        AudioController.playClear();
        comboStreak++;
        if (comboStreak > 1) {
          AudioController.playCombo();
          _showComboAnimation();
        }
        int bonus = (cleared * 100) * comboStreak;
        setState(() {
          score += bonus;
          if (widget.mode == GameMode.timeAttack) _timeLeft += cleared * 5;
        });
        await BoardLogic.applyClearAnimated(board);
      } else {
        setState(() => comboStreak = 0);
      }

      if (blocks.isEmpty) setState(() => blocks = BlockGenerator.generateThree());
      if (isTutorialActive) _completeTutorial();
    }
    
    if (!BoardLogic.canPlaceAnyBlock(board, blocks)) _triggerGameOver();
    _clearPreview();
    setState(() { activeBlock = null; lastDragPosition = null; });
  }

  void _showComboAnimation() {
    setState(() => comboText = comboStreak > 2 ? 'INCREDIBLE!' : 'COMBO x$comboStreak');
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => comboText = null);
    });
  }

  void _triggerGameOver() {
    AudioController.playGameOver();
    _checkAndSaveHighScore();
    setState(() => isGameOver = true);
  }

  void _revive() {
    setState(() {
      isGameOver = false;
      isRevived = true;
      int mid = GameConstants.boardSize ~/ 2;
      for (int r = mid - 1; r <= mid + 1; r++) {
        for (int c = mid - 1; c <= mid + 1; c++) {
          if (r >= 0 && r < GameConstants.boardSize && c >= 0 && c < GameConstants.boardSize) {
            board[r][c].filled = false;
          }
        }
      }
    });
  }

  String _formatTime(int s) => '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final themeBgGradient = context.watch<ThemeManager>().backgroundGradient;

    return Screenshot(
      controller: screenshotController,
      child: Scaffold(
        body: Stack(
          children: [
            AnimatedBackground(colors: themeBgGradient),
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  if (comboText != null)
                    Text(comboText!, style: const TextStyle(color: Colors.yellowAccent, fontSize: 32, fontWeight: FontWeight.bold))
                        .animate().scale(duration: 300.ms, curve: Curves.elasticOut).shake(),
                  const Spacer(),
                  RepaintBoundary(
                    child: Container(key: _boardKey, child: GameBoard(board: board)),
                  ),
                  const Spacer(),
                  RepaintBoundary(
                    child: _buildPalette(),
                  ),
                ],
              ),
            ),
            if (isGameOver) _buildGameOverOverlay(),
            if (isTutorialActive) IgnorePointer(child: _buildTutorial()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
          Column(children: [const Text('SCORE', style: TextStyle(color: Colors.white54)), Text('$score', style: const TextStyle(color: Colors.white, fontSize: 28))]),
          Column(children: [Text(widget.mode == GameMode.timeAttack ? 'TIME' : 'BEST', style: const TextStyle(color: Colors.white54)), Text(widget.mode == GameMode.timeAttack ? _formatTime(_timeLeft) : '$highScore', style: const TextStyle(color: Colors.white, fontSize: 24))]),
        ],
      ),
    );
  }

  Widget _buildPalette() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: BlockPalette(
        blocks: blocks,
        onDragStart: (b) => setState(() => activeBlock = b),
        onDragUpdate: updatePreview,
        onDragEnd: placeBlock,
      ),
    );
  }

  Widget _buildGameOverOverlay() {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Container(
        color: Colors.black.withOpacity(0.7),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events, color: Colors.yellowAccent, size: 80).animate().scale(duration: 600.ms),
              const Text('GAME OVER', style: TextStyle(color: Colors.white, fontSize: 44, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text('FINAL SCORE: $score', style: const TextStyle(color: Colors.white70, fontSize: 24)),
              const SizedBox(height: 40),
              _buildOverlayButton('SHARE SCORE', Icons.share, Colors.blueAccent, _shareScore),
              const SizedBox(height: 12),
              _buildOverlayButton('PLAY AGAIN', Icons.replay, AppColors.primary, () {
                setState(() {
                  board = BoardLogic.createEmptyBoard();
                  score = 0;
                  isGameOver = false;
                  isRevived = false;
                  blocks = BlockGenerator.generateThree();
                  if (widget.mode == GameMode.timeAttack) _timeLeft = 120;
                });
              }),
              if (!isRevived) ...[
                const SizedBox(height: 12),
                _buildOverlayButton('REVIVE (FREE)', Icons.flash_on, Colors.greenAccent, _revive),
              ],
              const SizedBox(height: 12),
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('BACK TO MENU', style: TextStyle(color: Colors.white54))),
            ],
          ).animate().fade().scale(),
        ),
      ),
    );
  }

  Widget _buildOverlayButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: 220,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(backgroundColor: color, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(label, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildTutorial() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.touch_app, color: Colors.cyanAccent, size: 50).animate(onPlay: (c) => c.repeat()).slideY(begin: 0.2, end: 0),
            const SizedBox(height: 12),
            const Text('DRAG BLOCKS TO THE BOARD!', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const Text('Fill rows or columns to clear them!', style: TextStyle(color: Colors.white70)),
          ],
        ),
      ).animate().fade().scale(),
    );
  }
}
