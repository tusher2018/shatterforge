// import 'package:flame/collisions.dart';
// import 'package:flame/components.dart';
// import 'package:flutter/material.dart';

// import '../brick_breaker.dart';
// import '../config.dart';
// import 'ball.dart';
// import 'bat.dart';

// class Brick extends RectangleComponent
//     with CollisionCallbacks, HasGameReference<BrickBreaker> {
//   Brick({required super.position, required Color color})
//       : super(
//           size: Vector2(brickWidth, brickHeight),
//           anchor: Anchor.center,
//           paint: Paint()
//             ..color = color
//             ..style = PaintingStyle.fill,
//           children: [RectangleHitbox()],
//         );

//   @override
//   void onCollisionStart(
//       Set<Vector2> intersectionPoints, PositionComponent other) {
//     super.onCollisionStart(intersectionPoints, other);
//     removeFromParent();

//     if (game.world.children.query<Brick>().length == 1) {
//       game.world.removeAll(game.world.children.query<Ball>());
//       game.world.removeAll(game.world.children.query<Bat>());
//     }
//   }
// }

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:shatterforge/TileData.dart';
import 'dart:math' as Math;

import 'package:shatterforge/src/brick_breaker.dart';

import 'package:shatterforge/src/components/ball.dart';
import 'package:shatterforge/src/config.dart';

class Brick extends PositionComponent
    with CollisionCallbacks, HasGameReference<BrickBreaker> {
  final TileModel tileData;

  Brick(
      {required this.tileData, required super.size, required super.position}) {
    switch (tileData.shape) {
      case 'Rectangle':
        add(RectangleHitbox()); // For rectangles
        break;
      case 'Ellipse':
        add(CircleHitbox()); // For ellipses
        break;
      default:
        add(RectangleHitbox()); // Default to rectangle hitbox if not handled
        break;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    super.render(canvas);

    Paint fillPaint = Paint()
      ..color = tileData.color
      ..style = PaintingStyle.fill;

    Rect tileRect = Rect.fromLTWH(0, 0, size.x, size.y);

    switch (tileData.shape) {
      case 'Ellipse':
        canvas.drawOval(tileRect, fillPaint);
        break;
      case 'Triangle':
        _drawTriangle(canvas, fillPaint, tileRect,
            basePosition: tileData.basePosition ?? 'Bottom');
        break;
      case 'Right Triangle':
        _drawRightTriangle(canvas, fillPaint, tileRect,
            orientation: tileData.orientation ?? 'Bottom-left');
        break;
      case 'Rectangle':
        canvas.drawRect(tileRect, fillPaint);
        break;
      case 'Parallelogram':
        _drawParallelogram(canvas, fillPaint, tileRect,
            slantDirection: tileData.basePosition ?? 'Right');
        break;
      case 'Trapezium':
        _drawTrapezoid(canvas, fillPaint, tileRect,
            basePosition: tileData.basePosition ?? 'Bottom');
        break;
      case 'Hexagon':
        _drawPolygon(canvas, fillPaint, tileRect, 6,
            rotationAngle: tileData.rotationAngle ?? 0);
        break;
      case 'Pentagon':
        _drawPolygon(canvas, fillPaint, tileRect, 5,
            rotationAngle: tileData.rotationAngle ?? 0);
        break;
      case 'Kite':
        _drawKite(canvas, fillPaint, tileRect);
        break;
    }
  }

  void _drawTriangle(Canvas canvas, Paint paint, Rect rect,
      {required String basePosition}) {
    Path path = Path();

    switch (basePosition) {
      case 'Bottom':
        path.moveTo(rect.center.dx, rect.top); // Top vertex
        path.lineTo(rect.left, rect.bottom); // Bottom-left vertex
        path.lineTo(rect.right, rect.bottom); // Bottom-right vertex
        break;

      case 'Top':
        path.moveTo(rect.center.dx, rect.bottom); // Bottom vertex
        path.lineTo(rect.left, rect.top); // Top-left vertex
        path.lineTo(rect.right, rect.top); // Top-right vertex
        break;

      case 'Left':
        path.moveTo(rect.right, rect.center.dy); // Right vertex
        path.lineTo(rect.left, rect.top); // Top-left vertex
        path.lineTo(rect.left, rect.bottom); // Bottom-left vertex
        break;

      case 'Right':
        path.moveTo(rect.left, rect.center.dy); // Left vertex
        path.lineTo(rect.right, rect.top); // Top-right vertex
        path.lineTo(rect.right, rect.bottom); // Bottom-right vertex
        break;
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawRightTriangle(Canvas canvas, Paint paint, Rect rect,
      {required String orientation}) {
    Path path = Path();

    switch (orientation) {
      case 'Bottom-left':
        path.moveTo(rect.left, rect.top); // Top-left
        path.lineTo(rect.right, rect.bottom); // Bottom-right
        path.lineTo(rect.left, rect.bottom); // Bottom-left (90-degree)
        break;

      case 'Top-left':
        path.moveTo(rect.left, rect.bottom); // Bottom-left
        path.lineTo(rect.right, rect.top); // Top-right
        path.lineTo(rect.left, rect.top); // Top-left (90-degree)
        break;

      case 'Bottom-right':
        path.moveTo(rect.right, rect.top); // Top-right
        path.lineTo(rect.left, rect.bottom); // Bottom-left
        path.lineTo(rect.right, rect.bottom); // Bottom-right (90-degree)
        break;

      case 'Top-right':
        path.moveTo(rect.right, rect.bottom); // Bottom-right
        path.lineTo(rect.left, rect.top); // Top-left
        path.lineTo(rect.right, rect.top); // Top-right (90-degree)
        break;
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawKite(Canvas canvas, Paint paint, Rect rect) {
    Path path = Path();
    path.moveTo(rect.center.dx, rect.top);
    path.lineTo(rect.left, rect.center.dy);
    path.lineTo(rect.center.dx, rect.bottom);
    path.lineTo(rect.right, rect.center.dy);
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawParallelogram(Canvas canvas, Paint paint, Rect rect,
      {required String slantDirection}) {
    Path path = Path();

    switch (slantDirection) {
      case 'Right':
        // Parallelogram slanting towards the right
        path.moveTo(
            rect.left + rect.width / 4, rect.top); // Top-left vertex (offset)
        path.lineTo(rect.right, rect.top); // Top-right vertex
        path.lineTo(rect.right - rect.width / 4,
            rect.bottom); // Bottom-right vertex (offset)
        path.lineTo(rect.left, rect.bottom); // Bottom-left vertex
        break;

      case 'Left':
        // Parallelogram slanting towards the left
        path.moveTo(rect.left, rect.top); // Top-left vertex
        path.lineTo(
            rect.right - rect.width / 4, rect.top); // Top-right vertex (offset)
        path.lineTo(rect.right, rect.bottom); // Bottom-right vertex
        path.lineTo(rect.left + rect.width / 4,
            rect.bottom); // Bottom-left vertex (offset)
        break;

      case 'Top':
        // Parallelogram slanting upwards
        path.moveTo(
            rect.left, rect.top + rect.height / 4); // Top-left vertex (offset)
        path.lineTo(rect.right, rect.top); // Top-right vertex
        path.lineTo(rect.right,
            rect.bottom - rect.height / 4); // Bottom-right vertex (offset)
        path.lineTo(rect.left, rect.bottom); // Bottom-left vertex
        break;

      case 'Bottom':
        // Parallelogram slanting downwards
        path.moveTo(rect.left, rect.top); // Top-left vertex
        path.lineTo(rect.right,
            rect.top + rect.height / 4); // Top-right vertex (offset)
        path.lineTo(rect.right, rect.bottom); // Bottom-right vertex
        path.lineTo(rect.left,
            rect.bottom - rect.height / 4); // Bottom-left vertex (offset)
        break;
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawTrapezoid(Canvas canvas, Paint paint, Rect rect,
      {required String basePosition}) {
    Path path = Path();

    switch (basePosition) {
      case 'Bottom':
        // Trapezoid with the longer base at the bottom
        path.moveTo(
            rect.left + rect.width / 4, rect.top); // Top-left vertex (offset)
        path.lineTo(
            rect.right - rect.width / 4, rect.top); // Top-right vertex (offset)
        path.lineTo(rect.right, rect.bottom); // Bottom-right vertex
        path.lineTo(rect.left, rect.bottom); // Bottom-left vertex
        break;

      case 'Top':
        // Trapezoid with the longer base at the top
        path.moveTo(rect.left, rect.top); // Top-left vertex
        path.lineTo(rect.right, rect.top); // Top-right vertex
        path.lineTo(rect.right - rect.width / 4,
            rect.bottom); // Bottom-right vertex (offset)
        path.lineTo(rect.left + rect.width / 4,
            rect.bottom); // Bottom-left vertex (offset)
        break;

      case 'Left':
        // Trapezoid with the longer base on the left side
        path.moveTo(rect.left, rect.top); // Top-left vertex
        path.lineTo(rect.left, rect.bottom); // Bottom-left vertex
        path.lineTo(rect.right,
            rect.bottom - rect.height / 4); // Bottom-right vertex (offset)
        path.lineTo(rect.right,
            rect.top + rect.height / 4); // Top-right vertex (offset)
        break;

      case 'Right':
        // Trapezoid with the longer base on the right side
        path.moveTo(rect.right, rect.top); // Top-right vertex
        path.lineTo(rect.right, rect.bottom); // Bottom-right vertex
        path.lineTo(rect.left,
            rect.bottom - rect.height / 4); // Bottom-left vertex (offset)
        path.lineTo(
            rect.left, rect.top + rect.height / 4); // Top-left vertex (offset)
        break;
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawPolygon(Canvas canvas, Paint paint, Rect rect, int sides,
      {double rotationAngle = 0}) {
    double centerX = rect.center.dx;
    double centerY = rect.center.dy;
    double radius = rect.width / 2;

    Path path = Path();
    double angle = (2 * 3.141592653589793) / sides;

    for (int i = 0; i < sides; i++) {
      // Apply the rotation angle
      double x = centerX + radius * Math.cos(i * angle + rotationAngle);
      double y = centerY + radius * Math.sin(i * angle + rotationAngle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Ball) {
      if (tileData.brickType.name == "Invisible" &&
          tileData.color == Colors.transparent) {
        tileData.color = Colors.white;
      }

      if (tileData.brickType.health <= 0) {
        removeFromParent();
      } else {
        tileData.brickType.health -= Config.balldamage;
      }
    }
  }
}
