import 'dart:async';
import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shatterforge/TileData.dart';
import 'package:shatterforge/src/config.dart';

import 'components/components.dart';

enum PlayState {
  playing,
  gameOver,
  won,
  round1,
  round2,
  round3,
  round4,
  round5,
  round6,
  round7,
  round8,
  round9,
  round10
}

class BrickBreaker extends FlameGame
    with HasCollisionDetection, KeyboardEvents, TapDetector {
  final GridData gridData;
  bool gamePlay = false;
  late Ball ball;
  late Bat bat;
  int playerHealth = 1;
  int brickBreak = 0;
  BuildContext context;

  BrickBreaker(
    this.context, {
    required this.gridData,
    this.playerHealth = 3,
  }) : super();

  final rand = math.Random();
  double get width => size.x;
  double get height => size.y;

  late PlayState _playState; // Add from here...
  PlayState get playState => _playState;
  set playState(PlayState playState) {
    _playState = playState;
    switch (playState) {
      case PlayState.gameOver:
      case PlayState.won:
      case PlayState.round1:
      case PlayState.round2:
      case PlayState.round3:
      case PlayState.round4:
      case PlayState.round5:
      case PlayState.round6:
      case PlayState.round7:
      case PlayState.round8:
      case PlayState.round9:
      case PlayState.round10:
        overlays.add(playState.name);
      case PlayState.playing:
        overlays.remove(PlayState.gameOver.name);
        overlays.remove(PlayState.won.name);
        overlays.remove(PlayState.round1.name);
        overlays.remove(PlayState.round2.name);
        overlays.remove(PlayState.round3.name);
        overlays.remove(PlayState.round4.name);
        overlays.remove(PlayState.round5.name);
        overlays.remove(PlayState.round6.name);
        overlays.remove(PlayState.round7.name);
        overlays.remove(PlayState.round8.name);
        overlays.remove(PlayState.round9.name);
        overlays.remove(PlayState.round10.name);
    }
  } // To here.

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();

    final EdgeInsets safeAreaInsets = MediaQuery.of(context).padding;

    camera.viewfinder.anchor = Anchor.topLeft;

    world.add(PlayArea());
    final double ballVerticalOffset = batHeight * 1.5;
    final Vector2 ballPosition =
        Vector2(width / 2, height * 0.95 - ballRadius - ballVerticalOffset);
    final Vector2 batPosition = Vector2(width / 2, height * 0.95);

    switch (playerHealth) {
      case 10:
        playState = PlayState.round10;
        break;
      case 9:
        playState = PlayState.round9;
        break;
      case 8:
        playState = PlayState.round8;
        break;
      case 7:
        playState = PlayState.round7;
        break;
      case 6:
        playState = PlayState.round6;
        break;
      case 5:
        playState = PlayState.round5;
        break;
      case 4:
        playState = PlayState.round4;
        break;
      case 3:
        playState = PlayState.round3;
        break;
      case 2:
        playState = PlayState.round2;
        break;
      case 1:
        playState = PlayState.round1;
        break;
      case 0:
        playState = PlayState.gameOver; // Game over if no lives left
        world.removeAll(world.children.query<Ball>());
        world.remove(bat);
        return; // Exit the function
    }

    ball = Ball(
        difficultyModifier: difficultyModifier,
        radius: ballRadius,
        position: ballPosition,
        velocity: Vector2((rand.nextDouble() - 0.5) * width, height * 0.2)
            .normalized()
          ..scale(height / 4));
    bat = Bat(
        size: Vector2(batWidth, batHeight),
        cornerRadius: Radius.circular(ballRadius / 2),
        position: batPosition);

    world.add(bat);
    world.add(ball);
    world.addAll([
      for (var i = 0; i < gridData.column; i++)
        for (var j = 0; j < gridData.row; j++)
          if (gridData.tileAttributes[Offset(i.toDouble(), j.toDouble())] !=
              null)
            Brick(
              context: context,
              position: Vector2(
                (size.x / gridData.column) * i,
                ((size.y * 0.5) / gridData.row) * j +
                    safeAreaInsets.top, // Adjust for top safe area
              ),
              tileData:
                  gridData.tileAttributes[Offset(i.toDouble(), j.toDouble())]!,
              size: Vector2(
                size.x / gridData.column,
                (size.y * 0.5) / gridData.row,
              ),
            ),
    ]);
  }

  void startGame() {
    if (playState == PlayState.playing) return;

    playState = PlayState.playing; // To here.
  }

  @override
  void onTap() {
    super.onTap();
    if (!gamePlay) {
      startGame();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (playState == PlayState.playing) {
      // Check if the ball is out of bounds (below the screen)
      if (world.children.query<Ball>().isEmpty) {
        loseLife();
      }
    }
    if (world.children.query<Brick>().where((brick) {
          // Filter breakable bricks based on their category
          final tileData = (brick).tileData;
          return tileData.brickType.isBreakable &&
              tileData.brickType.name != 'Unbreakable';
        }).isEmpty &&
        playState == PlayState.playing) {
      playState = PlayState.won;
      world.removeAll(world.children.query<Ball>());
      world.removeAll(world.children.query<Bat>());
    }
  }

  // Method to reset the ball after losing a life
  void resetBall() {
    world.removeAll(world.children.query<Ball>());
    world.removeAll(world.children.query<Bat>());
    final double ballVerticalOffset = batHeight * 1.5;
    final Vector2 ballPosition =
        Vector2(width / 2, height * 0.95 - ballRadius - ballVerticalOffset);
    final Vector2 batPosition = Vector2(width / 2, height * 0.95);
    ball = Ball(
        difficultyModifier: difficultyModifier,
        radius: ballRadius,
        position: ballPosition,
        velocity: Vector2((rand.nextDouble() - 0.5) * width, height * 0.2)
            .normalized()
          ..scale(height / 4));
    bat = Bat(
        size: Vector2(batWidth, batHeight),
        cornerRadius: Radius.circular(ballRadius / 2),
        position: batPosition);

    world.add(bat);
    world.add(ball);
  }

  void loseLife() {
    playerHealth--;
    // Change the playState based on the player's health
    switch (playerHealth) {
      case 10:
        playState = PlayState.round10;
        break;
      case 9:
        playState = PlayState.round9;
        break;
      case 8:
        playState = PlayState.round8;
        break;
      case 7:
        playState = PlayState.round7;
        break;
      case 6:
        playState = PlayState.round6;
        break;
      case 5:
        playState = PlayState.round5;
        break;
      case 4:
        playState = PlayState.round4;
        break;
      case 3:
        playState = PlayState.round3;
        break;
      case 2:
        playState = PlayState.round2;
        break;
      case 1:
        playState = PlayState.round1;
        break;
      case 0:
        playState = PlayState.gameOver; // Game over if no lives left
        world.remove(ball);
        world.remove(bat);
        return; // Exit the function
    }

    if (playerHealth > 0) {
      resetBall();
    }
  }

  @override
  KeyEventResult onKeyEvent(
      KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    super.onKeyEvent(event, keysPressed);
    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowLeft:
        world.children.query<Bat>().first.moveBy(-batStep);
      case LogicalKeyboardKey.arrowRight:
        world.children.query<Bat>().first.moveBy(batStep);
      case LogicalKeyboardKey.space: // Add from here...
      case LogicalKeyboardKey.enter:
        startGame();
    }
    return KeyEventResult.handled;
  }

/////////////////////

  // // Power-up logic for cloning balls
  // void handleBallClonePowerUp() {
  //   Iterable<Ball> balls = world.children.query<Ball>();
  //   int currentBallCount = balls.length;
  //   print(currentBallCount);

  //   if (currentBallCount < 50) {
  //     for (Ball ball in balls) {
  //       Vector2 randomVelocity = Vector2(
  //         ball.velocity.x +
  //             (math.Random().nextDouble() - 0.5) *
  //                 2, // Slight variation on X-axis
  //         ball.velocity.y +
  //             (math.Random().nextDouble() - 0.5) *
  //                 2, // Slight variation on Y-axis
  //       );
  //       Ball newBall = Ball(
  //           velocity: randomVelocity,
  //           position: ball.position,
  //           radius: ball.radius,
  //           difficultyModifier: ball.difficultyModifier);
  //       world.add(newBall);
  //     }
  //   }
  // }

  // // Power-up logic for max damage ball
  // void handleMaxDamageBallPowerUp() {
  //   int originalDamage = balldamage;
  //   balldamage = 100000;
  //   Future.delayed(Duration(seconds: 5), () {
  //     balldamage = originalDamage;
  //   });
  // }

  // // Power-up logic for speeding up the ball
  // void handleSpeedUpBallPowerUp() {
  //   Iterable<Ball> balls = world.children.query<Ball>();
  //   for (Ball ball in balls) {
  //     _increaseBallSpeed(ball);
  //   }
  // }

  // void _increaseBallSpeed(Ball ball) {
  //   const double speedIncreaseFactor = 1.2;
  //   Vector2 originalVelocity = ball.velocity.clone();
  //   ball.velocity.scale(speedIncreaseFactor);
  //   Future.delayed(Duration(seconds: 5), () {
  //     ball.velocity.setFrom(originalVelocity);
  //   });
  // }

// Power-up logic for cloning balls
  void handleBallClonePowerUp() {
    final Iterable<Ball> balls = world.children.query<Ball>();
    final int currentBallCount = balls.length;
    print(currentBallCount);

    // Define max balls constant
    const int maxBalls = 100;

    if (currentBallCount < maxBalls) {
      final math.Random random =
          math.Random(); // Create a single instance of Random
      for (Ball ball in balls) {
        Vector2 randomVelocity = Vector2(
          ball.velocity.x +
              (random.nextDouble() - 0.5) * 2, // Slight variation on X-axis
          ball.velocity.y +
              (random.nextDouble() - 0.5) * 2, // Slight variation on Y-axis
        );
        Ball newBall = Ball(
          velocity: randomVelocity,
          position: ball.position
              .clone(), // Ensure the new ball has a unique position
          radius: ball.radius,
          difficultyModifier: ball.difficultyModifier,
        );
        world.add(newBall);
      }
    }
  }

// Power-up logic for max damage ball
  void handleMaxDamageBallPowerUp() {
    const int maxDamage = 100000; // Define as a constant
    final int originalDamage = balldamage;
    balldamage = maxDamage;

    // Use a single function to reset the damage
    _resetDamageAfterDelay(originalDamage, 5);
  }

// Power-up logic for speeding up the ball
  void handleSpeedUpBallPowerUp() {
    final Iterable<Ball> balls = world.children.query<Ball>();
    for (Ball ball in balls) {
      _increaseBallSpeed(ball);
    }
  }

// Method to increase ball speed
  void _increaseBallSpeed(Ball ball) {
    const double speedIncreaseFactor = 1.2;
    final Vector2 originalVelocity = ball.velocity.clone();
    ball.velocity.scale(speedIncreaseFactor);

    // Use a single function to reset the velocity after a delay
    _resetVelocityAfterDelay(ball, originalVelocity, 5);
  }

// Reset damage to original value after a delay
  void _resetDamageAfterDelay(int originalDamage, int seconds) {
    Future.delayed(Duration(seconds: seconds), () {
      balldamage = originalDamage;
    });
  }

// Reset ball velocity to original after a delay
  void _resetVelocityAfterDelay(
      Ball ball, Vector2 originalVelocity, int seconds) {
    Future.delayed(Duration(seconds: seconds), () {
      ball.velocity.setFrom(originalVelocity);
    });
  }
}
