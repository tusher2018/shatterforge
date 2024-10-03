import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/image_composition.dart';
import 'package:flutter/rendering.dart';

import 'package:shatterforge/src/brick_breaker.dart';

class PlayArea extends RectangleComponent with HasGameReference<BrickBreaker> {
  PlayArea()
      : super(
          paint: Paint()..color = const Color(0x00ffffff),
          children: [RectangleHitbox()],
        );
  late Image backgroundImage;
  @override
  FutureOr<void> onLoad() async {
    super.onLoad();
    backgroundImage = await game.images.load('background.jpg');

    size = Vector2(game.width, game.height);
  }

  @override
  void render(Canvas canvas) {
    // Draw the background image to fill the play area
    paintImage(
      canvas: canvas,
      image: backgroundImage,
      rect: Rect.fromLTWH(0, 10, size.x, size.y),
      fit: BoxFit
          .cover, // You can change this to 'BoxFit.contain', 'BoxFit.fill', etc.
    );

    // Render the rest of the component (hitboxes, children, etc.)
    super.render(canvas);
  }
}
