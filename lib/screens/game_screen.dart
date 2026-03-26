import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../models/level.dart';
import '../models/player.dart';
import '../models/game_state.dart';
import '../game/game_engine.dart';
import '../providers/game_provider.dart';
import '../services/analytics_service.dart';
import '../services/audio_service.dart';
import '../game/levels_data.dart';
import '../utils/theme.dart';

class GameScreen extends StatefulWidget {
  final GameLevel level;
  final GameProvider gameProvider;

  const GameScreen({
    super.key,
    required this.level,
    required this.gameProvider,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late GameEngine _engine;
  late Ticker _ticker;
  double _tilt = 0;
  Duration _lastTick = Duration.zero;
  bool _isGameReady = false;

  final AnalyticsService _analytics = AnalyticsService();
  final AudioService _audio = AudioService();

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    _analytics.logLevelStart(widget.level.id, widget.level.name);
    _analytics.logScreenView('game_level_${widget.level.id}');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initGame();
    });
  }

  void _initGame() {
    final size = MediaQuery.of(context).size;
    _engine = GameEngine(
      screenWidth: size.width,
      screenHeight: size.height,
    );

    _engine.onStatusChange = (status) {
      if (!mounted) return;
      setState(() {});

      if (status == GameStatus.gameOver) {
        _audio.playGameOverSound();
        _analytics.logGameOver(
          widget.level.id,
          _engine.gameState.score,
          _engine.gameState.maxHeight.toInt(),
        );
        _analytics.logLevelEnd(
          widget.level.id,
          widget.level.name,
          score: _engine.gameState.score,
          stars: 0,
          success: false,
        );
      } else if (status == GameStatus.levelComplete) {
        _audio.playLevelCompleteSound();
        final stars = _engine.getStarsEarned();
        widget.gameProvider.completeLevel(
          widget.level.id,
          _engine.gameState.score,
          stars,
        );
        widget.gameProvider.addCoins(_engine.gameState.coins);
        _analytics.logLevelEnd(
          widget.level.id,
          widget.level.name,
          score: _engine.gameState.score,
          stars: stars,
          success: true,
        );
        _analytics.logCoinsCollected(
            widget.level.id, _engine.gameState.coins);
      }
    };

    _engine.onScoreChange = (score) {
      if (mounted) setState(() {});
    };

    _engine.initLevel(widget.level.id);
    _audio.playBackgroundMusic();

    setState(() {
      _isGameReady = true;
    });

    _ticker.start();
  }

  void _onTick(Duration elapsed) {
    if (_lastTick == Duration.zero) {
      _lastTick = elapsed;
      return;
    }

    double dt = (elapsed - _lastTick).inMicroseconds / 1000000.0;
    _lastTick = elapsed;

    // Clamp dt to prevent large jumps
    dt = dt.clamp(0, 0.033);

    _engine.update(dt, _tilt);
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _ticker.dispose();
    _audio.stopBackgroundMusic();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isGameReady) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
          child: const Center(
            child: CircularProgressIndicator(color: AppTheme.accent),
          ),
        ),
      );
    }

    return Scaffold(
      body: GestureDetector(
        onPanUpdate: (details) {
          _tilt = (details.localPosition.dx / MediaQuery.of(context).size.width - 0.5) * 2;
        },
        onPanEnd: (_) {
          _tilt = 0;
        },
        onTapDown: (details) {
          double half = MediaQuery.of(context).size.width / 2;
          _tilt = details.localPosition.dx < half ? -0.8 : 0.8;
        },
        onTapUp: (_) => _tilt = 0,
        child: Stack(
          children: [
            // Game canvas
            CustomPaint(
              size: MediaQuery.of(context).size,
              painter: _GamePainter(
                engine: _engine,
                level: widget.level,
              ),
            ),

            // HUD overlay
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Pause button
                    _buildHudButton(
                      icon: Icons.pause_rounded,
                      onTap: () {
                        _engine.pause();
                        _ticker.stop();
                        _audio.pauseBackgroundMusic();
                        _showPauseDialog();
                      },
                    ),

                    // Score
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${_engine.gameState.score}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '/ ${widget.level.targetScore}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Lives & coins
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('❤️', style: TextStyle(fontSize: 14)),
                              const SizedBox(width: 4),
                              Text(
                                '${_engine.gameState.lives}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🪙', style: TextStyle(fontSize: 14)),
                              const SizedBox(width: 4),
                              Text(
                                '${_engine.gameState.coins}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Touch zone indicators
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Icon(Icons.chevron_left_rounded,
                      size: 36,
                      color: Colors.white.withValues(alpha: _tilt < -0.1 ? 0.4 : 0.1)),
                  Icon(Icons.chevron_right_rounded,
                      size: 36,
                      color: Colors.white.withValues(alpha: _tilt > 0.1 ? 0.4 : 0.1)),
                ],
              ),
            ),

            // Game Over overlay
            if (_engine.gameState.status == GameStatus.gameOver)
              _buildGameOverOverlay(),

            // Level Complete overlay
            if (_engine.gameState.status == GameStatus.levelComplete)
              _buildLevelCompleteOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildHudButton(
      {required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withValues(alpha: 0.4),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: Center(
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }

  void _showPauseDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: AppTheme.primaryMedium,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'PAUSED',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.level.name,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 32),
              _buildDialogButton(
                label: 'RESUME',
                gradient: AppTheme.accentGradient,
                textColor: AppTheme.primaryDark,
                onTap: () {
                  Navigator.pop(context);
                  _engine.resume();
                  _lastTick = Duration.zero;
                  _ticker.start();
                  _audio.resumeBackgroundMusic();
                },
              ),
              const SizedBox(height: 12),
              _buildDialogButton(
                label: 'RESTART',
                gradient: null,
                textColor: Colors.white,
                borderColor: Colors.white.withValues(alpha: 0.2),
                onTap: () {
                  Navigator.pop(context);
                  _analytics.logLevelRetry(widget.level.id, widget.level.name);
                  _engine.initLevel(widget.level.id);
                  _lastTick = Duration.zero;
                  _ticker.start();
                },
              ),
              const SizedBox(height: 12),
              _buildDialogButton(
                label: 'QUIT',
                gradient: null,
                textColor: AppTheme.danger,
                borderColor: AppTheme.danger.withValues(alpha: 0.3),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameOverOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppTheme.primaryMedium,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppTheme.danger.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '💥',
                style: TextStyle(fontSize: 48),
              ),
              const SizedBox(height: 16),
              const Text(
                'GAME OVER',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.danger,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 20),
              _buildStatRow('Score', '${_engine.gameState.score}'),
              _buildStatRow('Coins', '${_engine.gameState.coins}'),
              _buildStatRow(
                  'Height', '${_engine.gameState.maxHeight.toInt()}m'),
              const SizedBox(height: 28),
              _buildDialogButton(
                label: 'TRY AGAIN',
                gradient: AppTheme.accentGradient,
                textColor: AppTheme.primaryDark,
                onTap: () {
                  _analytics.logLevelRetry(
                      widget.level.id, widget.level.name);
                  _engine.initLevel(widget.level.id);
                  _lastTick = Duration.zero;
                  _ticker.start();
                },
              ),
              const SizedBox(height: 12),
              _buildDialogButton(
                label: 'BACK TO LEVELS',
                gradient: null,
                textColor: Colors.white,
                borderColor: Colors.white.withValues(alpha: 0.2),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelCompleteOverlay() {
    final stars = _engine.getStarsEarned();

    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppTheme.primaryMedium,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppTheme.accent.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '🎉',
                style: TextStyle(fontSize: 48),
              ),
              const SizedBox(height: 16),
              ShaderMask(
                shaderCallback: (bounds) =>
                    AppTheme.accentGradient.createShader(bounds),
                child: const Text(
                  'LEVEL COMPLETE!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 3,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Stars
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) {
                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: i < stars ? 1.0 : 0.3),
                    duration: Duration(milliseconds: 500 + i * 200),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: i < stars ? value : 1.0,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Icon(
                            i < stars
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            size: 44,
                            color: i < stars
                                ? AppTheme.gold
                                : Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),

              const SizedBox(height: 20),
              _buildStatRow('Score', '${_engine.gameState.score}'),
              _buildStatRow('Coins', '${_engine.gameState.coins}'),
              const SizedBox(height: 28),

              // Next level button
              if (widget.level.id < 10)
                _buildDialogButton(
                  label: 'NEXT LEVEL',
                  gradient: AppTheme.accentGradient,
                  textColor: AppTheme.primaryDark,
                  onTap: () {
                    final nextLevelId = widget.level.id + 1;
                    if (widget.gameProvider.isLevelUnlocked(nextLevelId)) {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GameScreen(
                            level:
                                LevelsData.getLevel(nextLevelId),
                            gameProvider: widget.gameProvider,
                          ),
                        ),
                      );
                    } else {
                      Navigator.pop(context);
                    }
                  },
                ),

              if (widget.level.id < 10) const SizedBox(height: 12),

              _buildDialogButton(
                label: 'BACK TO LEVELS',
                gradient: null,
                textColor: Colors.white,
                borderColor: Colors.white.withValues(alpha: 0.2),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary.withValues(alpha: 0.7),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogButton({
    required String label,
    required LinearGradient? gradient,
    required Color textColor,
    Color? borderColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          border: borderColor != null
              ? Border.all(color: borderColor, width: 1)
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: textColor,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Game Painter ───

class _GamePainter extends CustomPainter {
  final GameEngine engine;
  final GameLevel level;
  final Random _random = Random(42);

  _GamePainter({required this.engine, required this.level});

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas, size);
    _drawPlatforms(canvas, size);
    _drawCollectibles(canvas, size);
    _drawPlayer(canvas, size);
  }

  void _drawBackground(Canvas canvas, Size size) {
    // Base gradient
    final bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          level.primaryColor.withValues(alpha: 0.15),
          const Color(0xFF0D1B2A),
          const Color(0xFF0A0E17),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Parallax stars
    final starPaint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 40; i++) {
      double x = _random.nextDouble() * size.width;
      double baseY = _random.nextDouble() * size.height * 3;
      double y = (baseY - engine.cameraY * 0.1) % size.height;
      double radius = _random.nextDouble() * 1.5 + 0.5;

      starPaint.color = Colors.white.withValues(alpha: _random.nextDouble() * 0.5 + 0.2);
      canvas.drawCircle(Offset(x, y), radius, starPaint);
    }
  }

  void _drawPlatforms(Canvas canvas, Size size) {
    for (var platform in engine.platforms) {
      if (!platform.isActive) continue;

      double drawY = platform.y - engine.cameraY;

      // Skip if off screen
      if (drawY < -50 || drawY > size.height + 50) continue;

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(platform.x, drawY, platform.width, platform.height),
        const Radius.circular(8),
      );

      Color platformColor;
      switch (platform.type) {
        case PlatformType.normal:
          platformColor = level.primaryColor;
          break;
        case PlatformType.moving:
          platformColor = const Color(0xFF00BCD4);
          break;
        case PlatformType.breakable:
          platformColor = const Color(0xFFFF7043);
          break;
        case PlatformType.spring:
          platformColor = const Color(0xFF66BB6A);
          break;
        case PlatformType.disappearing:
          platformColor = Colors.white.withValues(alpha: 0.5);
          break;
      }

      // Platform glow
      final glowPaint = Paint()
        ..color = platformColor.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawRRect(rect, glowPaint);

      // Platform body
      final platformPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            platformColor,
            platformColor.withValues(alpha: 0.7),
          ],
        ).createShader(
            Rect.fromLTWH(platform.x, drawY, platform.width, platform.height));
      canvas.drawRRect(rect, platformPaint);

      // Spring indicator
      if (platform.type == PlatformType.spring) {
        final springPaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.8)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(
          Offset(platform.x + platform.width / 2, drawY - 4),
          4,
          springPaint,
        );
      }
    }
  }

  void _drawCollectibles(Canvas canvas, Size size) {
    for (var collectible in engine.collectibles) {
      if (collectible.collected) continue;

      double drawY = collectible.y - engine.cameraY;
      if (drawY < -30 || drawY > size.height + 30) continue;

      final center = Offset(collectible.x + 10, drawY + 10);

      // Glow
      Color glowColor;
      switch (collectible.type) {
        case CollectibleType.coin:
          glowColor = const Color(0xFFFFD700);
          break;
        case CollectibleType.star:
          glowColor = const Color(0xFF00F5D4);
          break;
        case CollectibleType.gem:
          glowColor = const Color(0xFFE040FB);
          break;
      }

      final glowPaint = Paint()
        ..color = glowColor.withValues(alpha: 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawCircle(center, 12, glowPaint);

      // Body
      final bodyPaint = Paint()..color = glowColor;
      canvas.drawCircle(center, 8, bodyPaint);

      // Highlight
      final highlightPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.5);
      canvas.drawCircle(Offset(center.dx - 2, center.dy - 2), 3, highlightPaint);
    }
  }

  void _drawPlayer(Canvas canvas, Size size) {
    double drawY = engine.player.y - engine.cameraY;

    // Trail effect
    final trailPaint = Paint()
      ..color = AppTheme.accent.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
    canvas.drawCircle(
      Offset(
        engine.player.x + engine.player.width / 2,
        drawY + engine.player.height / 2 + 10,
      ),
      20,
      trailPaint,
    );

    // Player body
    final playerRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        engine.player.x,
        drawY,
        engine.player.width,
        engine.player.height,
      ),
      const Radius.circular(12),
    );

    // Player glow
    final playerGlow = Paint()
      ..color = AppTheme.accent.withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawRRect(playerRect, playerGlow);

    // Player gradient body
    final playerPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF00F5D4), Color(0xFF7B2FF7)],
      ).createShader(Rect.fromLTWH(
        engine.player.x,
        drawY,
        engine.player.width,
        engine.player.height,
      ));
    canvas.drawRRect(playerRect, playerPaint);

    // Eyes
    final eyePaint = Paint()..color = Colors.white;
    double eyeOffset =
        engine.player.direction == PlayerDirection.left ? -3 : 3;

    canvas.drawCircle(
      Offset(engine.player.x + engine.player.width / 2 - 6 + eyeOffset,
          drawY + 16),
      4, eyePaint,
    );
    canvas.drawCircle(
      Offset(engine.player.x + engine.player.width / 2 + 6 + eyeOffset,
          drawY + 16),
      4, eyePaint,
    );

    // Pupils
    final pupilPaint = Paint()..color = const Color(0xFF0D1B2A);
    canvas.drawCircle(
      Offset(engine.player.x + engine.player.width / 2 - 5 + eyeOffset,
          drawY + 16),
      2, pupilPaint,
    );
    canvas.drawCircle(
      Offset(engine.player.x + engine.player.width / 2 + 7 + eyeOffset,
          drawY + 16),
      2, pupilPaint,
    );

    // Smile
    if (!engine.player.isFalling) {
      final smilePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;

      final smilePath = Path()
        ..moveTo(engine.player.x + engine.player.width / 2 - 6, drawY + 28)
        ..quadraticBezierTo(
          engine.player.x + engine.player.width / 2,
          drawY + 34,
          engine.player.x + engine.player.width / 2 + 6,
          drawY + 28,
        );
      canvas.drawPath(smilePath, smilePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
