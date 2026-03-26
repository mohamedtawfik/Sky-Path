import 'dart:math';
import 'package:flutter/material.dart';
import '../providers/game_provider.dart';
import '../services/analytics_service.dart';
import '../utils/theme.dart';
import '../game/levels_data.dart';
import 'level_select_screen.dart';

class HomeScreen extends StatefulWidget {
  final GameProvider gameProvider;

  const HomeScreen({super.key, required this.gameProvider});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final AnalyticsService _analytics = AnalyticsService();
  late AnimationController _bgController;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _analytics.logScreenView('home');

    _bgController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: 0, end: -15).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );

    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _bgController.dispose();
    _bounceController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        child: Stack(
          children: [
            // Moving stars background
            AnimatedBuilder(
              animation: _bgController,
              builder: (context, _) => CustomPaint(
                size: MediaQuery.of(context).size,
                painter: _StarFieldPainter(_bgController.value),
              ),
            ),

            // Main content
            SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),

                    // Character bouncing
                    AnimatedBuilder(
                      animation: _bounceController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _bounceAnimation.value),
                          child: child,
                        );
                      },
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF00F5D4), Color(0xFF7B2FF7)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.accent.withValues(alpha: 0.4),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            '🚀',
                            style: TextStyle(fontSize: 52),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Title
                    ShaderMask(
                      shaderCallback: (bounds) =>
                          AppTheme.accentGradient.createShader(bounds),
                      child: const Text(
                        'SKY PATH',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 8,
                          height: 1,
                        ),
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      'REACH THE SKY',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.accent.withValues(alpha: 0.6),
                        letterSpacing: 12,
                      ),
                    ),

                    const Spacer(flex: 2),

                    // Stats row
                    AnimatedBuilder(
                      animation: _floatController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _floatAnimation.value),
                          child: child,
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: ListenableBuilder(
                          listenable: widget.gameProvider,
                          builder: (context, _) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildStatBadge(
                                  '⭐',
                                  '${widget.gameProvider.totalStars}',
                                  'Stars',
                                ),
                                const SizedBox(width: 24),
                                _buildStatBadge(
                                  '🪙',
                                  '${widget.gameProvider.totalCoins}',
                                  'Coins',
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Play button
                    _buildPlayButton(),

                    const SizedBox(height: 16),

                    // Settings button row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSmallButton(
                          icon: Icons.settings_rounded,
                          onTap: () => _showSettings(context),
                        ),
                        const SizedBox(width: 16),
                        _buildSmallButton(
                          icon: Icons.leaderboard_rounded,
                          onTap: () => _showStats(context),
                        ),
                        const SizedBox(width: 16),
                        _buildSmallButton(
                          icon: Icons.info_outline_rounded,
                          onTap: () => _showAbout(context),
                        ),
                      ],
                    ),

                    const Spacer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBadge(String emoji, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: AppTheme.glassDecoration,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: AppTheme.textSecondary.withValues(alpha: 0.7),
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlayButton() {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                LevelSelectScreen(gameProvider: widget.gameProvider),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      },
      child: Container(
        width: 220,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: AppTheme.accentGradient,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppTheme.accent.withValues(alpha: 0.4),
              blurRadius: 25,
              spreadRadius: 2,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_arrow_rounded, size: 28, color: AppTheme.primaryDark),
            SizedBox(width: 8),
            Text(
              'PLAY',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppTheme.primaryDark,
                letterSpacing: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.08),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        child: Center(
          child: Icon(icon, color: AppTheme.textSecondary, size: 22),
        ),
      ),
    );
  }

  void _showStats(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppTheme.primaryMedium,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Game Statistics',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              _buildStatRow('🌟', 'Total Stars Earned', '${widget.gameProvider.totalStars}'),
              const SizedBox(height: 12),
              _buildStatRow('🪙', 'Total Coins Collected', '${widget.gameProvider.totalCoins}'),
              const SizedBox(height: 12),
              _buildStatRow('🏔️', 'Levels Completed', '${LevelsData.levels.where((l) => widget.gameProvider.isLevelCompleted(l.id)).length}'),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('GOT IT', style: TextStyle(color: AppTheme.primaryDark, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String emoji, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.glassDecoration,
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.accent,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.primaryMedium,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Settings',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            ListenableBuilder(
              listenable: widget.gameProvider,
              builder: (context, _) {
                return Column(
                  children: [
                    _buildSettingToggle(
                      'Sound Effects',
                      Icons.volume_up_rounded,
                      widget.gameProvider.soundEnabled,
                      (v) => widget.gameProvider.setSoundEnabled(v),
                    ),
                    const SizedBox(height: 12),
                    _buildSettingToggle(
                      'Music',
                      Icons.music_note_rounded,
                      widget.gameProvider.musicEnabled,
                      (v) => widget.gameProvider.setMusicEnabled(v),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  widget.gameProvider.restorePurchases();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Restoring purchases...'),
                      backgroundColor: AppTheme.primaryLight,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
                child: const Text(
                  'Restore Purchases',
                  style: TextStyle(
                    color: AppTheme.accent,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingToggle(
    String label,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: AppTheme.glassDecoration,
      child: Row(
        children: [
          Icon(icon, color: AppTheme.accent, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppTheme.accent,
            activeTrackColor: AppTheme.accent.withValues(alpha: 0.3),
            inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
          ),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppTheme.primaryMedium,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppTheme.accentGradient,
                ),
                child: const Center(
                  child: Icon(Icons.rocket_launch_rounded,
                      size: 30, color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Sky Path',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Version 1.0.0',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Jump through exciting levels, collect stars,\nand reach the sky in premium worlds!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary.withValues(alpha: 0.9),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Made with ❤️ by TifaSoft',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textMuted.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StarFieldPainter extends CustomPainter {
  final double animationValue;
  final Random _random = Random(123);

  _StarFieldPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 50; i++) {
      double baseX = _random.nextDouble() * size.width;
      double baseY = _random.nextDouble() * size.height;
      double radius = _random.nextDouble() * 2 + 0.5;
      double speed = _random.nextDouble() * 0.5 + 0.5;

      double y = (baseY + animationValue * size.height * speed) % size.height;
      double twinkle =
          (sin((animationValue * 2 * pi * 3) + i * 1.3) + 1) / 2;

      paint.color =
          Colors.white.withValues(alpha: twinkle * 0.6 + 0.1);

      canvas.drawCircle(Offset(baseX, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
