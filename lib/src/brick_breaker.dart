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

class BrickBreaker extends FlameGame
    with HasCollisionDetection, KeyboardEvents {
  final GridData gridData;

  BrickBreaker({
    required this.gridData,
  }) : super();

  final rand = math.Random();
  double get width => size.x;
  double get height => size.y;

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();

    camera.viewfinder.anchor = Anchor.topLeft;

    world.add(PlayArea());
    final double ballVerticalOffset = Config.batHeight * 1.5;
    final Vector2 ballPosition = Vector2(
        width / 2, height * 0.95 - Config.ballRadius - ballVerticalOffset);
    final Vector2 batPosition = Vector2(width / 2, height * 0.95);

    world.add(Ball(
        difficultyModifier: difficultyModifier,
        radius: Config.ballRadius,
        position: ballPosition,
        velocity: Vector2((rand.nextDouble() - 0.5) * width, height * 0.2)
            .normalized()
          ..scale(height / 4)));

    world.add(Bat(
        size: Vector2(Config.batWidth, Config.batHeight),
        cornerRadius: Radius.circular(Config.ballRadius / 2),
        position: batPosition));

    await world.addAll([
      // Add from here...
      for (var i = 0; i < gridData.row; i++)
        for (var j = 0; j <= gridData.column; j++)
          Brick(
            position: Vector2((size.x / gridData.column) * i,
                ((size.y * 0.5) / gridData.row) * j),
            tileData: gridData
                    .tileAttributes[Offset(i.toDouble(), j.toDouble())] ??
                TileModel(position: const Offset(0, 0), color: Colors.white),
            size: Vector2(
                size.x / gridData.column, (size.y * 0.5) / gridData.row),
          ),
    ]);
  }

  @override
  KeyEventResult onKeyEvent(
      KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    super.onKeyEvent(event, keysPressed);
    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowLeft:
        world.children.query<Bat>().first.moveBy(-Config.batStep);
      case LogicalKeyboardKey.arrowRight:
        world.children.query<Bat>().first.moveBy(Config.batStep);
    }
    return KeyEventResult.handled;
  }
}
