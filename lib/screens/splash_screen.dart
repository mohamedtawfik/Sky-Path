import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/firebase_service.dart';
import '../services/storage_service.dart';
import '../services/iap_service.dart';
import '../services/audio_service.dart';
import '../services/analytics_service.dart';
import '../providers/game_provider.dart';
import '../utils/theme.dart';
import 'home_screen.dart';
import 'dart:io' show Platform;

class SplashScreen extends StatefulWidget {
  final GameProvider gameProvider;

  const SplashScreen({super.key, required this.gameProvider});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _pulseController;
  late AnimationController _particleController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _pulseAnimation;

  String _statusText = 'Loading...';
  bool _showForceUpdate = false;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _particleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _logoScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _logoController.forward();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Step 1: Initialize storage
      setState(() {
        _statusText = 'Initializing...';
        _progress = 0.1;
      });
      await StorageService().initialize();
      await Future.delayed(const Duration(milliseconds: 300));

      // Step 2: Initialize Firebase services
      setState(() {
        _statusText = 'Connecting to services...';
        _progress = 0.3;
      });
      await FirebaseService().initialize();
      await Future.delayed(const Duration(milliseconds: 300));

      // Step 3: Check force update
      setState(() {
        _statusText = 'Checking for updates...';
        _progress = 0.5;
      });
      bool needsUpdate = await FirebaseService().isForceUpdateRequired();

      if (needsUpdate && mounted) {
        AnalyticsService().logForceUpdateShown(
            FirebaseService().getMinVersion());
        setState(() {
          _showForceUpdate = true;
        });
        return; // Stop initialization, show force update dialog
      }

      // Step 4: Initialize IAP
      setState(() {
        _statusText = 'Loading store...';
        _progress = 0.7;
      });
      await IAPService().initialize();
      await Future.delayed(const Duration(milliseconds: 300));

      // Step 5: Initialize audio
      setState(() {
        _statusText = 'Preparing audio...';
        _progress = 0.85;
      });
      await AudioService().initialize();

      // Step 6: Initialize game provider
      setState(() {
        _statusText = 'Ready!';
        _progress = 1.0;
      });
      await widget.gameProvider.initialize();
      await Future.delayed(const Duration(milliseconds: 500));

      // Navigate to home
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                HomeScreen(gameProvider: widget.gameProvider),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    } catch (e, stack) {
      FirebaseService().logError(e, stack, reason: 'Splash initialization failed');
      if (mounted) {
        setState(() {
          _statusText = 'Error loading. Tap to retry.';
        });
      }
    }
  }

  void _openStore() async {
    AnalyticsService().logForceUpdateClicked();
    final String url;
    if (Platform.isIOS) {
      url = 'https://apps.apple.com/app/idYOUR_APP_ID'; // Replace with real App Store URL
    } else {
      url = 'https://play.google.com/store/apps/details?id=com.tifasoft.skypath';
    }

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _pulseController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        child: Stack(
          children: [
            // Animated particles background
            AnimatedBuilder(
              animation: _particleController,
              builder: (context, _) => CustomPaint(
                size: MediaQuery.of(context).size,
                painter: _ParticlePainter(_particleController.value),
              ),
            ),

            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  AnimatedBuilder(
                    animation: _logoController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _logoOpacity.value,
                        child: Transform.scale(
                          scale: _logoScale.value,
                          child: child,
                        ),
                      );
                    },
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: child,
                        );
                      },
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppTheme.accent,
                              AppTheme.accentSecondary,
                            ],
                          ),
                          boxShadow: AppTheme.glowShadow(AppTheme.accent),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.rocket_launch_rounded,
                            size: 70,
                            color: Colors.white,
                          ),
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
                        fontSize: 44,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 8,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'REACH THE SKY',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.accent.withValues(alpha: 0.7),
                      letterSpacing: 10,
                    ),
                  ),

                  const SizedBox(height: 60),

                  // Progress bar or Force Update
                  if (_showForceUpdate)
                    _buildForceUpdateDialog()
                  else
                    _buildProgressSection(),
                ],
              ),
            ),

            // Bottom branding
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Text(
                'TifaSoft © 2026',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textMuted.withValues(alpha: 0.5),
                  letterSpacing: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection() {
    return Column(
      children: [
        // Progress bar
        Container(
          width: 220,
          height: 4,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: Colors.white.withValues(alpha: 0.1),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: _progress,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                gradient: AppTheme.accentGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accent.withValues(alpha: 0.5),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Status text
        GestureDetector(
          onTap: _statusText.contains('retry') ? _initializeApp : null,
          child: Text(
            _statusText,
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary.withValues(alpha: 0.7),
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForceUpdateDialog() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.danger.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.system_update_rounded,
            size: 48,
            color: AppTheme.danger,
          ),
          const SizedBox(height: 16),
          const Text(
            'Update Required',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'A new version of Sky Path is available.\nPlease update to continue playing.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary.withValues(alpha: 0.8),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _openStore,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.danger,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: const Text(
                'UPDATE NOW',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final double animationValue;
  final Random _random = Random(42); // Fixed seed for consistent particles

  _ParticlePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 30; i++) {
      double baseX = _random.nextDouble() * size.width;
      double baseY = _random.nextDouble() * size.height;
      double radius = _random.nextDouble() * 3 + 1;

      double offsetY = sin((animationValue * 2 * pi) + i) * 20;
      double opacity = (sin((animationValue * 2 * pi) + i * 0.5) + 1) / 2;

      paint.color = (i % 3 == 0 ? AppTheme.accent : AppTheme.accentSecondary)
          .withValues(alpha: opacity * 0.3);

      canvas.drawCircle(
        Offset(baseX, baseY + offsetY),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
