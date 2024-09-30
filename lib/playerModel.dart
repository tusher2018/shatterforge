class PlayerModel {
  // Basic Player Information
  String? name; // Player's name
  final String gameId; // Unique ID for the player in the game
  final String email; // Player's email (private information)
  final String password; // Player's password (private information)

  // Player Performance Metrics
  int matchesPlayed; // Total matches played by the player
  int matchTotalWin;
  int matchTotalLose;
  int hardMatchesPlayed; // Total hard matches played
  int baseLiked; // Number of likes for the player's base
  int baseDisliked; // Number of dislikes for the player's base
  int level; // Player's level
  int ballDamage; // Damage dealt by the player's ball
  int totalBricksDestroyed; // Total bricks destroyed by the player

  // Brick Health Metrics
  int standardWallHealth;
  int explosiveWallHealth;
  int healingWallHealth;
  int invisibleWallHealth;
  int speedWallHealth;
  int multiHitWallHealth;
  int powerUpWallHealth;
  int numberOfUnbreakableWall;
  int maxBrickLimit;

  Map<String, bool> hasUpgradedThisLevel;

  // Constructor
  PlayerModel(
      {this.name,
      required this.gameId,
      required this.email,
      required this.password,
      this.matchesPlayed = 0,
      this.matchTotalWin = 0,
      this.matchTotalLose = 0,
      this.hardMatchesPlayed = 0,
      this.baseLiked = 0,
      this.baseDisliked = 0,
      this.level = 1,
      this.ballDamage = 50,
      this.totalBricksDestroyed = 0,
      this.standardWallHealth = 50,
      this.explosiveWallHealth = 50,
      this.healingWallHealth = 50,
      this.invisibleWallHealth = 50,
      this.speedWallHealth = 50,
      this.multiHitWallHealth = 50,
      this.powerUpWallHealth = 50,
      this.numberOfUnbreakableWall = 25,
      this.maxBrickLimit = 100,
      Map<String, bool>? hasUpgradedThisLevel})
      : hasUpgradedThisLevel = hasUpgradedThisLevel ??
            {
              'Standard Wall': false,
              'Explosive Wall': false,
              'Speed Up Wall': false,
              'Invisible Wall': false,
              'Multi-Hit Wall': false,
              'Power-Up Wall': false,
              'Unbreakable Wall': false,
              'Ball Damage': false,
            };

  // Convert a Player object to a Map<String, dynamic>
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'gameId': gameId,
      'email': email,
      'password': password,
      'matchesPlayed': matchesPlayed,
      'matchTotalWin': matchTotalWin,
      'matchTotalLose': matchTotalLose,
      'hardMatchesPlayed': hardMatchesPlayed,
      'baseLiked': baseLiked,
      'baseDisliked': baseDisliked,
      'level': level,
      'ballDamage': ballDamage,
      'totalBricksDestroyed': totalBricksDestroyed,
      'standardWallHealth': standardWallHealth,
      'explosiveWallHealth': explosiveWallHealth,
      'healingWallHealth': healingWallHealth,
      'invisibleWallHealth': invisibleWallHealth,
      'speedWallHealth': speedWallHealth,
      'multiHitWallHealth': multiHitWallHealth,
      'powerUpWallHealth': powerUpWallHealth,
      'numberOfUnbreakableWall': numberOfUnbreakableWall,
      'maxBrickLimit': maxBrickLimit,
      'hasUpgradedThisLevel': hasUpgradedThisLevel,
    };
  }

  // Create a Player object from a Map<String, dynamic>
  factory PlayerModel.fromMap(Map<String, dynamic> map) {
    return PlayerModel(
      name: map['name'],
      gameId: map['gameId'],
      email: map['email'],
      password: map['password'],
      matchesPlayed: map['matchesPlayed'] ?? 0,
      matchTotalWin: map['matchTotalWin'] ?? 0,
      matchTotalLose: map['matchTotalLose'] ?? 0,
      hardMatchesPlayed: map['hardMatchesPlayed'] ?? 0,
      baseLiked: map['baseLiked'] ?? 0,
      baseDisliked: map['baseDisliked'] ?? 0,
      level: map['level'] ?? 1,
      ballDamage: map['ballDamage'] ?? 10,
      totalBricksDestroyed: map['totalBricksDestroyed'] ?? 0,
      standardWallHealth: map['standardWallHealth'] ?? 100,
      explosiveWallHealth: map['explosiveWallHealth'] ?? 100,
      healingWallHealth: map['healingWallHealth'] ?? 100,
      invisibleWallHealth: map['invisibleWallHealth'] ?? 100,
      speedWallHealth: map['speedWallHealth'] ?? 100,
      multiHitWallHealth: map['multiHitWallHealth'] ?? 100,
      powerUpWallHealth: map['powerUpWallHealth'] ?? 100,
      numberOfUnbreakableWall: map['numberOfUnbreakableWall'] ?? 0,
      maxBrickLimit: map['maxBrickLimit'] ?? 100,
      hasUpgradedThisLevel: map['hasUpgradedThisLevel'] != null
          ? Map<String, bool>.from(map['hasUpgradedThisLevel'])
          : {
              'Standard Wall': false,
              'Explosive Wall': false,
              'Speed Up Wall': false,
              'Invisible Wall': false,
              'Multi-Hit Wall': false,
              'Power-Up Wall': false,
              'Unbreakable Wall': false,
              'Ball Damage': false,
            }, // Default map if null
    );
  }
}
