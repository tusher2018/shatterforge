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
  static const double minYVelocity = 0.5;
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
      game.world.remove(this);
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
    } else if (other is Ball) {
      handleBallCollision(other);
    }
  }

  void handleBallCollision(Ball otherBall) {
    Vector2 delta = position - otherBall.position;
    double distance = delta.length;
    double minDist = radius + otherBall.radius;

    if (distance < minDist) {
      delta.normalize();
      velocity.setFrom(
          otherBall.velocity - delta.scaled(2 * otherBall.velocity.dot(delta)));
      otherBall.velocity
          .setFrom(velocity - delta.scaled(2 * velocity.dot(delta)));
    }
    double adjustedYVelocity =
        velocity.y.isNegative ? -minYVelocity : minYVelocity;

    if (velocity.y.abs() < minYVelocity) {
      velocity.y = adjustedYVelocity;
    }

    if (otherBall.velocity.y.abs() < minYVelocity) {
      otherBall.velocity.y = adjustedYVelocity;
    }
  }
}
