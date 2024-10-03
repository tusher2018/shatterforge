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
  TileModel tileData;

  Brick(
      {required this.tileData, required super.size, required super.position}) {
    switch (tileData.shape) {
      case 'Rectangle':
        add(RectangleHitbox()); // For rectangles
        break;
      case 'Ellipse':
        add(CircleHitbox()); // For ellipses
        break;
      case 'Triangle':
        add(PolygonHitbox(_getTriangleVertices())); // For triangles
        break;

      case 'Right Triangle':
        add(PolygonHitbox(
            _getRightTriangleVertices())); // Create a function to get vertices
        break;

      case 'Kite':
        add(PolygonHitbox(
            _getKiteVertices())); // Create a function to get vertices
        break;

      case 'Parallelogram':
        add(PolygonHitbox(_getParallelogramVertices()));
        break;

      case 'Trapezium':
        add(PolygonHitbox(_getTrapezoidVertices()));
        break;

      case 'Pentagon':
        add(PolygonHitbox(_getPolygonVertices(5,
            rotationAngle:
                tileData.rotationAngle ?? 0))); // Example for a hexagon
        break;

      case 'Hexagon':
        add(PolygonHitbox(_getPolygonVertices(6,
            rotationAngle:
                tileData.rotationAngle ?? 0))); // Example for a hexagon
        break;
      default:
        add(RectangleHitbox()); // Default to rectangle hitbox if not handled
        break;
    }
  }

/////////////collision detection start

  List<Vector2> _getTriangleVertices() {
    List<Vector2> vertices = [];

    Rect rect = Rect.fromLTWH(0, 0, size.x, size.y);

    switch (tileData.basePosition) {
      case 'Bottom':
        vertices.add(Vector2(rect.center.dx, rect.top));
        vertices.add(Vector2(rect.left, rect.bottom));
        vertices.add(Vector2(rect.right, rect.bottom));
        break;
      case 'Top':
        vertices.add(Vector2(rect.center.dx, rect.bottom));
        vertices.add(Vector2(rect.left, rect.top));
        vertices.add(Vector2(rect.right, rect.top));
        break;
      case 'Left':
        vertices.add(Vector2(rect.right, rect.center.dy));
        vertices.add(Vector2(rect.left, rect.top));
        vertices.add(Vector2(rect.left, rect.bottom));
        break;
      case 'Right':
        vertices.add(Vector2(rect.left, rect.center.dy));
        vertices.add(Vector2(rect.right, rect.top));
        vertices.add(Vector2(rect.right, rect.bottom));
        break;
      default:
        vertices.add(Vector2(rect.center.dx, rect.top));
        vertices.add(Vector2(rect.left, rect.bottom));
        vertices.add(Vector2(rect.right, rect.bottom));
    }

    return vertices;
  }

  List<Vector2> _getRightTriangleVertices() {
    List<Vector2> vertices = [];
    print(tileData.basePosition);
    Rect rect = Rect.fromLTWH(0, 0, size.x, size.y);
    switch (tileData.orientation) {
      case 'Bottom-left':
        vertices.add(Vector2(rect.left, rect.top));
        vertices.add(Vector2(rect.right, rect.bottom));
        vertices.add(Vector2(rect.left, rect.bottom));
        break;
      case 'Top-left':
        vertices.add(Vector2(rect.left, rect.bottom));
        vertices.add(Vector2(rect.right, rect.top));
        vertices.add(Vector2(rect.left, rect.top));
        break;
      case 'Bottom-right':
        vertices.add(Vector2(rect.right, rect.top));
        vertices.add(Vector2(rect.left, rect.bottom));
        vertices.add(Vector2(rect.right, rect.bottom));
        break;
      case 'Top-right':
        vertices.add(Vector2(rect.right, rect.bottom));
        vertices.add(Vector2(rect.left, rect.top));
        vertices.add(Vector2(rect.right, rect.top));
        break;
      default:
        vertices.add(Vector2(rect.left, rect.top));
        vertices.add(Vector2(rect.right, rect.bottom));
        vertices.add(Vector2(rect.left, rect.bottom));
    }
    print(vertices.length);
    return vertices;
  }

  List<Vector2> _getKiteVertices() {
    Rect rect = Rect.fromLTWH(0, 0, size.x, size.y);
    List<Vector2> vertices = [];
    vertices.add(Vector2(rect.center.dx, rect.top));
    vertices.add(Vector2(rect.left, rect.center.dy));
    vertices.add(Vector2(rect.center.dx, rect.bottom));
    vertices.add(Vector2(rect.right, rect.center.dy));
    return vertices;
  }

  List<Vector2> _getParallelogramVertices() {
    List<Vector2> vertices = [];
    Rect rect = Rect.fromLTWH(0, 0, size.x, size.y);

    switch (tileData.basePosition ?? 'Right') {
      case 'Right':
        vertices.add(Vector2(rect.left + rect.width / 4, rect.top));
        vertices.add(Vector2(rect.right, rect.top));
        vertices.add(Vector2(rect.right - rect.width / 4, rect.bottom));
        vertices.add(Vector2(rect.left, rect.bottom));
        break;
      case 'Left':
        vertices.add(Vector2(rect.left, rect.top));
        vertices.add(Vector2(rect.right - rect.width / 4, rect.top));
        vertices.add(Vector2(rect.right, rect.bottom));
        vertices.add(Vector2(rect.left + rect.width / 4, rect.bottom));
        break;
      case 'Top':
        vertices.add(Vector2(rect.left, rect.top + rect.height / 4));
        vertices.add(Vector2(rect.right, rect.top));
        vertices.add(Vector2(rect.right, rect.bottom - rect.height / 4));
        vertices.add(Vector2(rect.left, rect.bottom));
        break;
      case 'Bottom':
        vertices.add(Vector2(rect.left, rect.top));
        vertices.add(Vector2(rect.right, rect.top + rect.height / 4));
        vertices.add(Vector2(rect.right, rect.bottom));
        vertices.add(Vector2(rect.left, rect.bottom - rect.height / 4));
        break;
    }

    return vertices;
  }

  List<Vector2> _getTrapezoidVertices() {
    List<Vector2> vertices = [];
    Rect rect = Rect.fromLTWH(0, 0, size.x, size.y);
    switch (tileData.basePosition) {
      case 'Bottom':
        vertices.add(Vector2(rect.left + rect.width / 4, rect.top));
        vertices.add(Vector2(rect.right - rect.width / 4, rect.top));
        vertices.add(Vector2(rect.right, rect.bottom));
        vertices.add(Vector2(rect.left, rect.bottom));
        break;
      case 'Top':
        vertices.add(Vector2(rect.left, rect.top));
        vertices.add(Vector2(rect.right, rect.top));
        vertices.add(Vector2(rect.right - rect.width / 4, rect.bottom));
        vertices.add(Vector2(rect.left + rect.width / 4, rect.bottom));
        break;
      case 'Left':
        vertices.add(Vector2(rect.left, rect.top));
        vertices.add(Vector2(rect.left, rect.bottom));
        vertices.add(Vector2(rect.right, rect.bottom - rect.height / 4));
        vertices.add(Vector2(rect.right, rect.top + rect.height / 4));
        break;
      case 'Right':
        vertices.add(Vector2(rect.right, rect.top));
        vertices.add(Vector2(rect.right, rect.bottom));
        vertices.add(Vector2(rect.left, rect.bottom - rect.height / 4));
        vertices.add(Vector2(rect.left, rect.top + rect.height / 4));
        break;
    }

    return vertices;
  }

  List<Vector2> _getPolygonVertices(int sides, {double rotationAngle = 0}) {
    List<Vector2> vertices = [];

    Rect rect = Rect.fromLTWH(0, 0, size.x, size.y);
    double centerX = rect.center.dx;
    double centerY = rect.center.dy;
    double radius = rect.width / 2;

    double angle = (2 * 3.141592653589793) / sides;

    for (int i = 0; i < sides; i++) {
      double x = centerX + radius * Math.cos(i * angle + rotationAngle);
      double y = centerY + radius * Math.sin(i * angle + rotationAngle);
      vertices.add(Vector2(x, y));
    }

    return vertices;
  }

///////////collision detection end

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

///////////draw bricks design start
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

///////draw bricks design end
  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    if (!tileData.brickType.isBreakable) {
      if (other is Ball) {
        tileData.color = Colors.black;
      }

      return;
    }

    if (other is Ball) {
      if (tileData.brickType.name == "Invisible" &&
          tileData.color == Colors.transparent) {
        tileData.color = Colors.white;
      }

      if (tileData.brickType.health <= 0) {
        removeFromParent();
        game.brickBreak += 1;
      } else {
        tileData.brickType.health -= Config.balldamage;
      }
    }
  }
}
