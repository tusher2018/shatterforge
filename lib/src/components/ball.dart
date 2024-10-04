import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

import '../brick_breaker.dart';
import 'bat.dart';
import 'brick.dart'; // Add this import
import 'play_area.dart';

class Ball extends CircleComponent
    with CollisionCallbacks, HasGameReference<BrickBreaker> {
  Ball({
    required this.velocity,
    required super.position,
    required double radius,
    required this.difficultyModifier, // Add this parameter
  }) : super(
            radius: radius,
            anchor: Anchor.center,
            paint: Paint()
              ..color = Colors.yellow.shade50
              ..style = PaintingStyle.fill,
            children: [CircleHitbox()]);

  final Vector2 velocity;

  final double difficultyModifier; // Add this member

  @override
  void update(double dt) {
    super.update(dt);
    if (game.playState != PlayState.playing) {
      return;
    }
    position += velocity * dt;
    // Prevent ball from going off-screen
    if (position.x - radius <= 0) {
      // Left side collision
      position.x = radius;
      velocity.x = -velocity.x;
    } else if (position.x + radius >= game.width) {
      // Right side collision
      position.x = game.width - radius;
      velocity.x = -velocity.x;
    }

    if (position.y - radius <= 0) {
      // Top side collision
      position.y = radius;
      velocity.y = -velocity.y;
    } else if (position.y + radius >= game.height) {
      // Bottom side (game over)
      // game.playState = PlayState.gameOver;
    }
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is PlayArea) {
      if (intersectionPoints.first.y <= 0) {
        velocity.y = -velocity.y;
      } else if (intersectionPoints.first.x <= 0) {
        velocity.x = -velocity.x;
      } else if (intersectionPoints.first.x >= game.width) {
        velocity.x = -velocity.x;
      } else if (intersectionPoints.first.y >= game.height) {
        add(RemoveEffect(
            delay: 0.35,
            onComplete: () {
              // game.playState = PlayState.gameOver;
            }));
      }
    } else if (other is Bat) {
      velocity.y = -velocity.y;
      velocity.x = velocity.x +
          (position.x - other.position.x) / other.size.x * game.width * 0.3;
    } else if (other is Brick) {
      // Modify from here...
      if (position.y < other.position.y - other.size.y / 2) {
        velocity.y = -velocity.y;
      } else if (position.y > other.position.y + other.size.y / 2) {
        velocity.y = -velocity.y;
      } else if (position.x < other.position.x) {
        velocity.x = -velocity.x;
      } else if (position.x > other.position.x) {
        velocity.x = -velocity.x;
      }
      velocity.setFrom(velocity * difficultyModifier);
    }
  }
}
