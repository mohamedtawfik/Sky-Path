import 'dart:math';
import 'package:flutter/material.dart';
import 'package:jumper_game/l10n/app_localizations.dart';
import '../providers/game_provider.dart';
import '../game/levels_data.dart';
import '../models/level.dart';
import '../services/analytics_service.dart';
import '../utils/theme.dart';
import 'game_screen.dart';

class LevelSelectScreen extends StatefulWidget {
  final GameProvider gameProvider;

  const LevelSelectScreen({super.key, required this.gameProvider});

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen>
    with TickerProviderStateMixin {
  final AnalyticsService _analytics = AnalyticsService();
  late AnimationController _bgController;
  late AnimationController _entryController;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _analytics.logScreenView('level_select');
    _bgController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    _entryController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();

    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _bgController.dispose();
    _entryController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        child: Stack(
          children: [
            // Animated background
            AnimatedBuilder(
              animation: _bgController,
              builder: (context, _) => CustomPaint(
                size: MediaQuery.of(context).size,
                painter: _LevelBgPainter(_bgController.value),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.08),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.15),
                              ),
                            ),
                            child: const Center(
                              child: Icon(Icons.arrow_back_rounded,
                                  color: Colors.white, size: 22),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            l10n.level.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: Localizations.localeOf(context).languageCode == 'ar' ? 0 : 3,
                            ),
                          ),
                        ),
                        // Stars counter
                        ListenableBuilder(
                          listenable: widget.gameProvider,
                          builder: (context, _) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.15),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('⭐',
                                      style: TextStyle(fontSize: 16)),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${widget.gameProvider.totalStars}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Level grid
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _entryController,
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: _entryController,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.1),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: _entryController,
                              curve: Curves.easeOutCubic,
                            )),
                            child: child,
                          ),
                        );
                      },
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        itemCount: LevelsData.levels.length,
                        itemBuilder: (context, index) {
                          return _buildLevelCard(
                              LevelsData.levels[index], index);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelCard(GameLevel level, int index) {
    final l10n = AppLocalizations.of(context)!;
    final isUnlocked = widget.gameProvider.isLevelUnlocked(level.id);
    final isCompleted = widget.gameProvider.isLevelCompleted(level.id);
    final stars = widget.gameProvider.getLevelStars(level.id);
    final highScore = widget.gameProvider.getLevelHighScore(level.id);
    final needsPremium = !level.isFree && !widget.gameProvider.isPremium;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GestureDetector(
        onTap: () {
          if (needsPremium) {
            _showPurchaseDialog();
          } else if (isUnlocked) {
            _navigateToGame(level);
          } else {
            _showLockedMessage();
          }
        },
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: isUnlocked
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      level.primaryColor.withValues(alpha: 0.25),
                      level.secondaryColor.withValues(alpha: 0.1),
                    ],
                  )
                : null,
            color: isUnlocked ? null : Colors.white.withValues(alpha: 0.04),
            border: Border.all(
              color: isUnlocked
                  ? level.primaryColor.withValues(alpha: 0.4)
                  : Colors.white.withValues(alpha: 0.08),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Level number badge
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isUnlocked
                      ? LinearGradient(
                          colors: [level.primaryColor, level.secondaryColor],
                        )
                      : null,
                  color: isUnlocked ? null : Colors.white.withValues(alpha: 0.08),
                  boxShadow: isUnlocked
                      ? [
                          BoxShadow(
                            color: level.primaryColor.withValues(alpha: 0.3),
                            blurRadius: 12,
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: needsPremium
                      ? const Icon(Icons.lock_rounded,
                          color: Colors.white70, size: 22)
                      : isUnlocked
                          ? Text(
                              '${level.id}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.lock_rounded,
                              color: Colors.white38, size: 22),
                ),
              ),

              const SizedBox(width: 16),

              // Level info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _getLevelName(context, level),
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: isUnlocked
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.4),
                            ),
                          ),
                        ),
                        if (needsPremium)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: AppTheme.premiumGradient,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              l10n.premiumTag,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getLevelDesc(context, level),
                      style: TextStyle(
                        fontSize: 12,
                        color: isUnlocked
                            ? AppTheme.textSecondary.withValues(alpha: 0.8)
                            : Colors.white.withValues(alpha: 0.25),
                      ),
                    ),
                    if (isCompleted) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          // Stars
                          Row(
                            children: List.generate(3, (i) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 2),
                                child: Icon(
                                  i < stars
                                      ? Icons.star_rounded
                                      : Icons.star_border_rounded,
                                  size: 18,
                                  color: i < stars
                                      ? AppTheme.gold
                                      : Colors.white.withValues(alpha: 0.2),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${l10n.best}: $highScore',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.textMuted.withValues(alpha: 0.7),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Arrow
              if (isUnlocked && !needsPremium)
                Icon(
                  Icons.chevron_right_rounded,
                  color: level.primaryColor.withValues(alpha: 0.7),
                  size: 26,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToGame(GameLevel level) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            GameScreen(
          level: level,
          gameProvider: widget.gameProvider,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _showLockedMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.lockedMessage),
        backgroundColor: AppTheme.primaryLight,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showPurchaseDialog() {
    final l10n = AppLocalizations.of(context)!;
    _analytics.logPurchasePromptShown();
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
              // Premium badge
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppTheme.premiumGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentSecondary.withValues(alpha: 0.4),
                      blurRadius: 25,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.workspace_premium_rounded,
                      size: 42, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.unlockTitle,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.unlockDescription,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary.withValues(alpha: 0.9),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 8),

              // Features list
              _buildFeatureRow('🏔️', l10n.featureAllLevels),
              _buildFeatureRow('🌟', l10n.featurePlatforms),
              _buildFeatureRow('💎', l10n.featureRewards),
              _buildFeatureRow('♾️', l10n.featureOneTime),

              const SizedBox(height: 24),

              // Purchase button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _analytics.logPurchaseStarted();
                    Navigator.pop(context);
                    widget.gameProvider.purchasePremium();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: AppTheme.premiumGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        l10n.unlockNow,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  l10n.later,
                  style: TextStyle(
                    color: AppTheme.textMuted.withValues(alpha: 0.6),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  String _getLevelName(BuildContext context, GameLevel level) {
    final l10n = AppLocalizations.of(context)!;
    switch (level.id) {
      case 1: return l10n.level1Name;
      case 2: return l10n.level2Name;
      case 3: return l10n.level3Name;
      case 4: return l10n.level4Name;
      case 5: return l10n.level5Name;
      case 6: return l10n.level6Name;
      case 7: return l10n.level7Name;
      case 8: return l10n.level8Name;
      case 9: return l10n.level9Name;
      case 10: return l10n.level10Name;
      default: return level.name;
    }
  }

  String _getLevelDesc(BuildContext context, GameLevel level) {
    final l10n = AppLocalizations.of(context)!;
    switch (level.id) {
      case 1: return l10n.level1Desc;
      case 2: return l10n.level2Desc;
      case 3: return l10n.level3Desc;
      case 4: return l10n.level4Desc;
      case 5: return l10n.level5Desc;
      case 6: return l10n.level6Desc;
      case 7: return l10n.level7Desc;
      case 8: return l10n.level8Desc;
      case 9: return l10n.level9Desc;
      case 10: return l10n.level10Desc;
      default: return level.description;
    }
  }
}

class _LevelBgPainter extends CustomPainter {
  final double animationValue;
  final Random _random = Random(77);

  _LevelBgPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Subtle floating orbs
    for (int i = 0; i < 8; i++) {
      double baseX = _random.nextDouble() * size.width;
      double baseY = _random.nextDouble() * size.height;
      double radius = _random.nextDouble() * 60 + 30;

      double offsetX = sin((animationValue * 2 * pi) + i) * 30;
      double offsetY = cos((animationValue * 2 * pi) + i * 0.7) * 20;

      paint.color = (i % 2 == 0
              ? const Color(0xFF00F5D4)
              : const Color(0xFF7B2FF7))
          .withValues(alpha: 0.04);

      canvas.drawCircle(
        Offset(baseX + offsetX, baseY + offsetY),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
