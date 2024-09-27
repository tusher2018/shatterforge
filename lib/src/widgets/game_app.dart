import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shatterforge/TileData.dart';
import 'package:shatterforge/src/brick_breaker.dart';
import 'package:shatterforge/src/config.dart';
import 'package:shatterforge/src/widgets/overlay_screen.dart';

class GameApp extends StatefulWidget {
  const GameApp({
    super.key,
    required this.gridData,
  });
  final GridData gridData;

  @override
  State<GameApp> createState() => _GameAppState();
}

class _GameAppState extends State<GameApp> {
  late final BrickBreaker game;

  @override
  void initState() {
    super.initState();
    game = BrickBreaker(gridData: widget.gridData);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.pressStart2pTextTheme().apply(
          bodyColor: Color.fromARGB(255, 0, 0, 0),
          displayColor: Color.fromARGB(255, 0, 0, 0),
        ),
      ),
      home: Scaffold(
        body: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: SizedBox(
              width: Config.screenWidth,
              height: Config.screenHeight,
              child: GameWidget(
                game: game,
                overlayBuilderMap: {
                  PlayState.welcome.name: (context, game) =>
                      const OverlayScreen(
                        title: 'TAP TO PLAY',
                        subtitle: 'Use arrow keys or swipe',
                      ),
                  PlayState.gameOver.name: (context, game) =>
                      const OverlayScreen(
                        title: 'GAME OVER',
                        subtitle: 'Tap to Play Again',
                      ),
                  PlayState.won.name: (context, game) => const OverlayScreen(
                        title: 'Y O U   W O N ! ! !',
                        subtitle: 'Tap to Play Again',
                      ),
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
