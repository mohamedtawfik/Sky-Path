import 'dart:math';
import '../models/level.dart';
import '../models/player.dart';
import '../models/game_state.dart';
import 'levels_data.dart';

class GameEngine {
  late Player player;
  late GameState gameState;
  late GameLevel currentLevel;
  List<Platform> platforms = [];
  List<Collectible> collectibles = [];
  double cameraY = 0;
  double screenWidth;
  double screenHeight;
  final Random _random = Random();

  // Callback for game events
  Function(GameStatus)? onStatusChange;
  Function(int)? onScoreChange;

  GameEngine({
    required this.screenWidth,
    required this.screenHeight,
  }) {
    player = Player();
    gameState = GameState();
  }

  void initLevel(int levelId) {
    currentLevel = LevelsData.getLevel(levelId);
    gameState.currentLevel = levelId;
    gameState.status = GameStatus.playing;
    gameState.score = 0;
    gameState.coins = 0;
    gameState.maxHeight = 0;
    gameState.timeElapsed = 0.0;
    cameraY = 0;

    // Reset player
    player.reset(screenWidth / 2 - player.width / 2, screenHeight - 100);

    // Generate platforms
    _generatePlatforms();

    // Generate collectibles
    _generateCollectibles();

    onStatusChange?.call(GameStatus.playing);
  }

  void _generatePlatforms() {
    platforms.clear();

    double currentY = screenHeight - 50;

    platforms.add(Platform(
      x: screenWidth / 2 - 60,
      y: currentY,
      width: 120,
      height: 15,
      type: PlatformType.normal,
    ));

    double maxJumpHeight = (currentLevel.jumpForce * currentLevel.jumpForce) / (2 * currentLevel.gravity);
    double minGap = maxJumpHeight * 0.4;
    double maxGap = maxJumpHeight * 0.75;
    if (minGap < 50) minGap = 50;
    if (maxGap < 70) maxGap = 70;

    for (int i = 0; i < currentLevel.totalPlatforms; i++) {
      double gap = minGap + _random.nextDouble() * (maxGap - minGap);
      currentY -= gap;

      double x = _random.nextDouble() * (screenWidth - 80);

      PlatformType type = _selectPlatformType();

      double width = 80;
      if (type == PlatformType.breakable) width = 60;
      if (type == PlatformType.spring) width = 70;

      platforms.add(Platform(
        x: x,
        y: currentY,
        width: width,
        height: 15,
        type: type,
      ));
    }

    currentY -= 80;
    platforms.add(Platform(
      x: 0,
      y: currentY,
      width: screenWidth,
      height: 20,
      type: PlatformType.normal,
    ));
  }

  PlatformType _selectPlatformType() {
    if (currentLevel.platformConfigs.isEmpty) return PlatformType.normal;

    double roll = _random.nextDouble();
    double cumulative = 0;

    for (var config in currentLevel.platformConfigs) {
      cumulative += config.probability;
      if (roll <= cumulative) return config.type;
    }

    return PlatformType.normal;
  }

  void _generateCollectibles() {
    collectibles.clear();

    for (int i = 0; i < platforms.length; i++) {
      if (_random.nextDouble() < 0.3) {
        collectibles.add(Collectible(
          x: platforms[i].x + platforms[i].width / 2 - 10,
          y: platforms[i].y - 30,
          type: _random.nextDouble() < 0.2
              ? CollectibleType.star
              : CollectibleType.coin,
        ));
      }
    }
  }

  void update(double dt, double tilt) {
    if (gameState.status != GameStatus.playing) return;

    gameState.timeElapsed += dt;

    // Apply horizontal movement from tilt/accelerometer
    player.velocityX = tilt * 400;
    player.x += player.velocityX * dt;

    // Wrap around screen edges
    if (player.x > screenWidth) player.x = -player.width;
    if (player.x < -player.width) player.x = screenWidth;

    // Apply gravity
    player.velocityY += currentLevel.gravity * dt;
    player.y += player.velocityY * dt;

    // Update direction
    if (player.velocityX > 10) {
      player.direction = PlayerDirection.right;
    } else if (player.velocityX < -10) {
      player.direction = PlayerDirection.left;
    }

    // Check if falling
    player.isFalling = player.velocityY > 0;
    player.isJumping = player.velocityY < 0;

    // Platform collision (only when falling)
    if (player.velocityY > 0) {
      for (var platform in platforms) {
        if (!platform.isActive) continue;
        if (_checkPlatformCollision(platform)) {
          _handlePlatformLanding(platform);
        }
      }
    }

    // Collectible collision
    for (var collectible in collectibles) {
      if (!collectible.collected && _checkCollectibleCollision(collectible)) {
        collectible.collected = true;
        if (collectible.type == CollectibleType.coin) {
          gameState.coins += 1;
          gameState.score += 10;
        } else if (collectible.type == CollectibleType.star) {
          gameState.coins += 3;
          gameState.score += 50;
        } else {
          gameState.coins += 5;
          gameState.score += 100;
        }
        onScoreChange?.call(gameState.score);
      }
    }

    // Update moving platforms
    for (var platform in platforms) {
      if (platform.type == PlatformType.moving) {
        platform.x += 60 * dt * (platform.x > screenWidth / 2 ? -1 : 1);
        if (platform.x < 0 || platform.x > screenWidth - platform.width) {
          // Reverse direction (simplified)
        }
      }
    }

    // Camera follow
    if (player.y < screenHeight * 0.4 + cameraY) {
      double targetCamera = player.y - screenHeight * 0.4;
      cameraY += (targetCamera - cameraY) * 0.1;
    }

    // Track height for score
    double currentHeight = -player.y;
    if (currentHeight > gameState.maxHeight) {
      int heightDiff = ((currentHeight - gameState.maxHeight) / 10).floor();
      gameState.score += heightDiff;
      gameState.maxHeight = currentHeight;
      onScoreChange?.call(gameState.score);
    }

    // Check if player fell below screen
    if (player.y > screenHeight + 100 - cameraY) {
      gameState.lives--;
      if (gameState.lives <= 0) {
        gameState.status = GameStatus.gameOver;
        onStatusChange?.call(GameStatus.gameOver);
      } else {
        // Respawn at last safe position
        _respawnPlayer();
      }
    }

    // Check level completion
    if (player.y < platforms.last.y + 10) {
      gameState.status = GameStatus.levelComplete;
      onStatusChange?.call(GameStatus.levelComplete);
    }
  }

  bool _checkPlatformCollision(Platform platform) {
    return player.x + player.width > platform.x &&
        player.x < platform.x + platform.width &&
        player.y + player.height >= platform.y &&
        player.y + player.height <= platform.y + platform.height + 15 &&
        player.velocityY > 0;
  }

  bool _checkCollectibleCollision(Collectible collectible) {
    return (player.x + player.width / 2 - (collectible.x + 10)).abs() < 25 &&
        (player.y + player.height / 2 - (collectible.y + 10)).abs() < 25;
  }

  void _handlePlatformLanding(Platform platform) {
    switch (platform.type) {
      case PlatformType.normal:
        player.velocityY = currentLevel.jumpForce;
        break;
      case PlatformType.moving:
        player.velocityY = currentLevel.jumpForce;
        break;
      case PlatformType.breakable:
        player.velocityY = currentLevel.jumpForce;
        platform.isActive = false;
        break;
      case PlatformType.spring:
        player.velocityY = currentLevel.jumpForce * 1.5;
        break;
      case PlatformType.disappearing:
        player.velocityY = currentLevel.jumpForce;
        // Disappear after a short delay (handled in rendering)
        Future.delayed(Duration(milliseconds: 300), () {
          platform.isActive = false;
        });
        break;
    }
  }

  void _respawnPlayer() {
    // Find a visible platform to respawn on
    double visibleTop = cameraY;
    double visibleBottom = cameraY + screenHeight;

    Platform? safePlatform;
    for (var platform in platforms) {
      if (platform.isActive &&
          platform.y > visibleTop &&
          platform.y < visibleBottom &&
          platform.type == PlatformType.normal) {
        safePlatform = platform;
        break;
      }
    }

    if (safePlatform != null) {
      player.x = safePlatform.x + safePlatform.width / 2 - player.width / 2;
      player.y = safePlatform.y - player.height;
      player.velocityY = currentLevel.jumpForce;
      player.velocityX = 0;
    } else {
      // Fallback: reset to starting position
      player.x = screenWidth / 2 - player.width / 2;
      player.y = screenHeight - 100;
      cameraY = 0;
      player.velocityY = currentLevel.jumpForce;
    }
  }

  void pause() {
    if (gameState.status == GameStatus.playing) {
      gameState.status = GameStatus.paused;
      onStatusChange?.call(GameStatus.paused);
    }
  }

  void resume() {
    if (gameState.status == GameStatus.paused) {
      gameState.status = GameStatus.playing;
      onStatusChange?.call(GameStatus.playing);
    }
  }

  void updateScreenSize(double width, double height) {
    screenWidth = width;
    screenHeight = height;
  }

  int getStarsEarned() {
    double targetTime = currentLevel.totalPlatforms * 1.5;
    
    if (gameState.timeElapsed <= targetTime) return 3;
    if (gameState.timeElapsed <= targetTime * 1.5) return 2;
    if (gameState.timeElapsed <= targetTime * 2.0) return 1;
    return 1;
  }
}
