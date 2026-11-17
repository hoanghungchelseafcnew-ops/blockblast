import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/theme/theme_manager.dart';
import '../../../core/audio/audio_controller.dart';
import '../../../core/widgets/animated_background.dart';
import '../../game/screens/game_screen.dart';
import '../../game/services/game_feedback.dart';
import '../../journey/controllers/level_game_controller.dart';
import '../../journey/models/level.dart';
import '../../journey/services/app_bootstrap.dart';
import '../../journey/services/progress_lifecycle_observer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.services,
    this.feedback = const DeviceGameFeedback(),
  });

  /// Dịch vụ dựng ở bootstrap (constructor DI).
  final AppServices services;

  /// Âm thanh và rung cho ván chơi mới.
  final GameFeedback feedback;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ProgressLifecycleObserver _lifecycleObserver;

  @override
  void initState() {
    super.initState();
    // WF7: app vào nền thì ghi lại các key dirty.
    _lifecycleObserver = ProgressLifecycleObserver(widget.services.progress)
      ..attach();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkDailyReward();
    });
  }

  @override
  void dispose() {
    _lifecycleObserver.detach();
    super.dispose();
  }

  Future<void> _checkDailyReward() async {
    final prefs = await SharedPreferences.getInstance();
    final lastLogin = prefs.getString('last_login_date') ?? '';
    final today = DateTime.now().toIso8601String().split('T')[0];

    if (lastLogin != today) {
      await prefs.setString('last_login_date', today);
      _showRewardDialog();
    }
  }

  void _showRewardDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C2E),
        title: const Text('DAILY GIFT!', style: TextStyle(color: Colors.yellowAccent, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.card_giftcard, color: Colors.yellowAccent, size: 64).animate(onPlay: (c) => c.repeat()).scaleXY(end: 1.1),
            const SizedBox(height: 16),
            const Text('You received a Daily Reward!', style: TextStyle(color: Colors.white)),
            const Text('+500 Points added to your streak!', style: TextStyle(color: Colors.white70)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CLAIM', style: TextStyle(color: Colors.cyanAccent)),
          ),
        ],
      ),
    );
  }

  void _openSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C2E),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('SETTINGS', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 20),
              
              StatefulBuilder(
                builder: (context, setStateSB) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      AudioController.isMuted ? Icons.volume_off : Icons.volume_up,
                      color: Colors.white,
                      size: 30,
                    ),
                    title: const Text('Sound Effects', style: TextStyle(fontSize: 18)),
                    trailing: Switch(
                      value: !AudioController.isMuted,
                      activeColor: AppColors.accent,
                      onChanged: (val) {
                        AudioController.toggleMute();
                        setStateSB(() {});
                      },
                    ),
                  );
                }
              ),
              const Divider(color: Colors.white24, height: 30),
              const Text('THEME', style: TextStyle(fontSize: 16, color: Colors.white54)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildThemeOption(ctx, 'Neon', AppThemeType.neon, Colors.purpleAccent),
                  _buildThemeOption(ctx, 'Wood', AppThemeType.wood, Colors.brown),
                  _buildThemeOption(ctx, 'Jewel', AppThemeType.jewel, Colors.cyanAccent),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      }
    );
  }

  Widget _buildThemeOption(BuildContext context, String name, AppThemeType type, Color color) {
    final manager = context.watch<ThemeManager>();
    final isSelected = manager.currentTheme == type;
    
    return GestureDetector(
      onTap: () => manager.setTheme(type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.3) : Colors.white.withOpacity(0.05),
          border: Border.all(color: isSelected ? color : Colors.transparent, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(Icons.brush, color: isSelected ? color : Colors.white54),
            const SizedBox(height: 4),
            Text(name, style: TextStyle(color: isSelected ? Colors.white : Colors.white54)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeBgGradient = context.watch<ThemeManager>().backgroundGradient;
    final level = widget.services.journey.currentLevel;

    return Scaffold(
      body: Stack(
        children: [
          AnimatedBackground(colors: themeBgGradient),
          SafeArea(
            child: Stack(
              children: [
                Positioned(
                  top: 16,
                  right: 16,
                  child: IconButton(
                    icon: const Icon(Icons.settings, color: Colors.white, size: 30),
                    onPressed: () => _openSettings(context),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'BLOCK\nCRUSH',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              fontSize: 60,
                              height: 1.1,
                              shadows: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.8),
                                  blurRadius: 25,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                      ).animate().fade(duration: 800.ms).slideY(begin: -0.2, end: 0, curve: Curves.easeOutBack),
                      const SizedBox(height: 50),
                      _buildLevelCard(level)
                          .animate(delay: 300.ms)
                          .fade()
                          .slideX(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Nhãn level hiện tại và nút PLAY (WF2). Không còn thẻ chế độ (BR6.3).
  Widget _buildLevelCard(Level level) {
    return Column(
      children: [
        Text(
          level.displayName,
          key: const Key('home-level-label'),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          key: const Key('home-play-button'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            minimumSize: const Size(220, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          onPressed: _startGame,
          icon: const Icon(Icons.play_arrow_rounded, size: 28, color: Colors.white),
          label: const Text(
            'PLAY',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ],
    );
  }

  void _startGame() {
    final services = widget.services;
    final level = services.journey.currentLevel;
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => ChangeNotifierProvider<LevelGameController>(
          create: (_) => LevelGameController(
            journey: services.journey,
            progress: services.progress,
            feedback: widget.feedback,
          )..start(level),
          child: const GameScreen(),
        ),
      ),
    ).then((_) {
      // Level hiện tại có thể đã đổi sau ván thắng.
      if (mounted) setState(() {});
    });
  }
}
