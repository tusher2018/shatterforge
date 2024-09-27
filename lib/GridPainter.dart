import 'package:flutter/material.dart';
import 'package:shatterforge/TileData.dart';
import 'dart:math' as Math;

class GridPainter extends CustomPainter {
  final int rows;
  final int columns;
  final Map<Offset, TileModel> tileAttributes;

  GridPainter(this.rows, this.columns, this.tileAttributes);

  @override
  void paint(Canvas canvas, Size size) {
    double tileWidth = size.width / columns;
    double tileHeight = size.height / rows;

    Paint borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke;

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < columns; col++) {
        Rect tileRect = Rect.fromLTWH(
            col * tileWidth, row * tileHeight, tileWidth, tileHeight);
        Offset tileOffset = Offset(col.toDouble(), row.toDouble());

        TileModel? attributes = tileAttributes[tileOffset];
        if (attributes != null) {
          Paint fillPaint = Paint()
            ..color = attributes.color
            ..style = PaintingStyle.fill;

          switch (attributes.shape) {
            case 'Ellipse':
              canvas.drawOval(tileRect, fillPaint);
              break;
            case 'Triangle':
              _drawTriangle(canvas, fillPaint, tileRect,
                  basePosition: attributes.basePosition ?? 'Bottom');
              break;
            case 'Right Triangle':
              _drawRightTriangle(canvas, fillPaint, tileRect,
                  orientation: attributes.orientation ?? 'Bottom-left');
              break;
            case 'Rectangle':
              canvas.drawRect(tileRect, fillPaint);
              break;
            case 'Parallelogram':
              _drawParallelogram(canvas, fillPaint, tileRect,
                  slantDirection: attributes.basePosition ?? 'Right');
              break;
            case 'Trapezium':
              _drawTrapezoid(canvas, fillPaint, tileRect,
                  basePosition: attributes.basePosition ?? 'Bottom');
              break;
            case 'Hexagon':
              _drawPolygon(canvas, fillPaint, tileRect, 6,
                  rotationAngle: attributes.rotationAngle ?? 0);
              break;
            case 'Pentagon':
              _drawPolygon(canvas, fillPaint, tileRect, 5,
                  rotationAngle: attributes.rotationAngle ?? 0);
              break;
            case 'Kite':
              _drawKite(canvas, fillPaint, tileRect);
              break;
          }
        }

        canvas.drawRect(tileRect, borderPaint);
      }
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}
