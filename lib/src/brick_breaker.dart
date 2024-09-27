import 'dart:async';
import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shatterforge/TileData.dart';

import 'components/components.dart';
import 'config.dart';

enum PlayState { welcome, playing, gameOver, won }

class BrickBreaker extends FlameGame
    with HasCollisionDetection, KeyboardEvents, TapDetector {
  final GridData gridData;
  bool gamePlay = false;
  late Ball ball;
  late Bat bat;

  BrickBreaker({
    required this.gridData,
  }) : super();

  final rand = math.Random();
  double get width => size.x;
  double get height => size.y;

  late PlayState _playState; // Add from here...
  PlayState get playState => _playState;
  set playState(PlayState playState) {
    _playState = playState;
    switch (playState) {
      case PlayState.welcome:
      case PlayState.gameOver:
      case PlayState.won:
        overlays.add(playState.name);
      case PlayState.playing:
        overlays.remove(PlayState.welcome.name);
        overlays.remove(PlayState.gameOver.name);
        overlays.remove(PlayState.won.name);
    }
  } // To here.

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();

    camera.viewfinder.anchor = Anchor.topLeft;

    world.add(PlayArea());
    final double ballVerticalOffset = Config.batHeight * 1.5;
    final Vector2 ballPosition = Vector2(
        width / 2, height * 0.95 - Config.ballRadius - ballVerticalOffset);
    final Vector2 batPosition = Vector2(width / 2, height * 0.95);

    playState = PlayState.welcome;

    ball = Ball(
        difficultyModifier: difficultyModifier,
        radius: Config.ballRadius,
        position: ballPosition,
        velocity: Vector2((rand.nextDouble() - 0.5) * width, height * 0.2)
            .normalized()
          ..scale(height / 4));
    bat = Bat(
        size: Vector2(Config.batWidth, Config.batHeight),
        cornerRadius: Radius.circular(Config.ballRadius / 2),
        position: batPosition);

    world.add(bat);
    world.add(ball);
    //Add Bricks...
    world.addAll([
      for (var i = 0; i < gridData.row; i++)
        for (var j = 0; j < gridData.column; j++)
          Brick(
            position: Vector2((size.x / gridData.column) * i,
                ((size.y * 0.5) / gridData.row) * j),
            tileData:
                gridData.tileAttributes[Offset(i.toDouble(), j.toDouble())] ??
                    TileModel(
                        position: const Offset(0, 0),
                        color: Colors.transparent,
                        brickType: brickTypes[4]),
            size: Vector2(
                size.x / gridData.column, (size.y * 0.5) / gridData.row),
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
  } // To here.

  @override
  KeyEventResult onKeyEvent(
      KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    super.onKeyEvent(event, keysPressed);
    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowLeft:
        world.children.query<Bat>().first.moveBy(-Config.batStep);
      case LogicalKeyboardKey.arrowRight:
        world.children.query<Bat>().first.moveBy(Config.batStep);
      case LogicalKeyboardKey.space: // Add from here...
      case LogicalKeyboardKey.enter:
        startGame();
    }
    return KeyEventResult.handled;
  }
}
