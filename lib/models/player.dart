/// Represents the player character
class Player {
  double x;
  double y;
  double velocityX;
  double velocityY;
  final double width;
  final double height;
  bool isJumping;
  bool isFalling;
  PlayerDirection direction;

  Player({
    this.x = 0,
    this.y = 0,
    this.velocityX = 0,
    this.velocityY = 0,
    this.width = 40,
    this.height = 50,
    this.isJumping = false,
    this.isFalling = false,
    this.direction = PlayerDirection.right,
  });

  void reset(double startX, double startY) {
    x = startX;
    y = startY;
    velocityX = 0;
    velocityY = 0;
    isJumping = false;
    isFalling = false;
    direction = PlayerDirection.right;
  }
}

enum PlayerDirection {
  left,
  right,
  idle,
}
