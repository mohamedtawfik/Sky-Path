import 'dart:ui';

/// Represents a single platform in the game
class Platform {
  double x;
  double y;
  final double width;
  final double height;
  final PlatformType type;
  bool isActive;

  Platform({
    required this.x,
    required this.y,
    this.width = 80,
    this.height = 15,
    this.type = PlatformType.normal,
    this.isActive = true,
  });
}

enum PlatformType {
  normal,
  moving,
  breakable,
  spring,
  disappearing,
}

/// Represents a collectible coin/star in a level
class Collectible {
  double x;
  double y;
  bool collected;
  final CollectibleType type;

  Collectible({
    required this.x,
    required this.y,
    this.collected = false,
    this.type = CollectibleType.coin,
  });
}

enum CollectibleType {
  coin,
  star,
  gem,
}

/// Represents a single level in the game
class GameLevel {
  final int id;
  final String name;
  final String description;
  final int requiredStars;
  final bool isFree;
  final Color primaryColor;
  final Color secondaryColor;
  final String backgroundTheme;
  final double gravity;
  final double jumpForce;
  final int targetScore;
  final int totalPlatforms;
  final double levelHeight;
  final List<PlatformConfig> platformConfigs;

  const GameLevel({
    required this.id,
    required this.name,
    required this.description,
    this.requiredStars = 0,
    required this.isFree,
    required this.primaryColor,
    required this.secondaryColor,
    this.backgroundTheme = 'sky',
    this.gravity = 980,
    this.jumpForce = -550,
    this.targetScore = 1000,
    this.totalPlatforms = 30,
    this.levelHeight = 5000,
    this.platformConfigs = const [],
  });
}

class PlatformConfig {
  final PlatformType type;
  final double probability;

  const PlatformConfig({
    required this.type,
    required this.probability,
  });
}
