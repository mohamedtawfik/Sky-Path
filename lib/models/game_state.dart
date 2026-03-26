enum GameStatus {
  idle,
  playing,
  paused,
  gameOver,
  levelComplete,
}

class GameState {
  GameStatus status;
  int score;
  int coins;
  int highScore;
  int currentLevel;
  int lives;
  double maxHeight;
  double timeElapsed;

  GameState({
    this.status = GameStatus.idle,
    this.score = 0,
    this.coins = 0,
    this.highScore = 0,
    this.currentLevel = 1,
    this.lives = 3,
    this.maxHeight = 0,
    this.timeElapsed = 0.0,
  });

  void reset() {
    status = GameStatus.idle;
    score = 0;
    coins = 0;
    lives = 3;
    maxHeight = 0;
    timeElapsed = 0.0;
  }
}
