import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shatterforge/TileData.dart';
import 'package:shatterforge/src/brick_breaker.dart';

import 'package:shatterforge/src/config.dart';
import 'package:shatterforge/src/widgets/overlay_screen.dart';

enum DifficultyLevel { easy, medium, hard }

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
  bool isLiked = true; // To track like/dislike
  DifficultyLevel selectedDifficulty =
      DifficultyLevel.medium; // Default selection for difficulty level

  @override
  void initState() {
    super.initState();
    game = BrickBreaker(gridData: widget.gridData);
    if (widget.gridData.dislike > widget.gridData.like) {
      isLiked = false;
    } else {
      isLiked = true;
    }

    if (widget.gridData.easy > widget.gridData.medium &&
        widget.gridData.easy > widget.gridData.hard) {
      selectedDifficulty = DifficultyLevel.easy;
    } else if (widget.gridData.medium > widget.gridData.easy &&
        widget.gridData.medium > widget.gridData.hard) {
      selectedDifficulty = DifficultyLevel.medium;
    } else {
      DifficultyLevel.hard;
    }
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
                  PlayState.gameOver.name: (context, game) =>
                      EndScreen("GAME OVER"),
                  PlayState.won.name: (context, game) =>
                      EndScreen("Y O U   W O N ! ! !"),

                  /////////
                  PlayState.round1.name: (context, game) => const OverlayScreen(
                        title: 'TAP TO START',
                        subtitle: 'Round 1',
                      ),
                  PlayState.round2.name: (context, game) => const OverlayScreen(
                        title: 'TAP TO START',
                        subtitle: 'Round 2',
                      ),
                  PlayState.round3.name: (context, game) => const OverlayScreen(
                        title: 'TAP TO START',
                        subtitle: 'Round 3',
                      ),
                  PlayState.round4.name: (context, game) => const OverlayScreen(
                        title: 'TAP TO START',
                        subtitle: 'Round 4',
                      ),
                  PlayState.round5.name: (context, game) => const OverlayScreen(
                        title: 'TAP TO START',
                        subtitle: 'Round 5',
                      ),
                  PlayState.round6.name: (context, game) => const OverlayScreen(
                        title: 'TAP TO START',
                        subtitle: 'Round 6',
                      ),
                  PlayState.round7.name: (context, game) => const OverlayScreen(
                        title: 'TAP TO START',
                        subtitle: 'Round 7',
                      ),
                  PlayState.round8.name: (context, game) => const OverlayScreen(
                        title: 'TAP TO START',
                        subtitle: 'Round 8',
                      ),
                  PlayState.round9.name: (context, game) => const OverlayScreen(
                        title: 'TAP TO START',
                        subtitle: 'Round 8',
                      ),
                  PlayState.round9.name: (context, game) => const OverlayScreen(
                        title: 'TAP TO START',
                        subtitle: 'Round 9',
                      ),
                  PlayState.round10.name: (context, game) =>
                      const OverlayScreen(
                        title: 'TAP TO START',
                        subtitle: 'Round 10',
                      ),
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget EndScreen(String text) {
    return Container(
      color: Colors.black54,
      alignment: const Alignment(0, 0.3),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Game Over Text Animation
          SizedBox(
            height: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 40,
                        color:
                            primaryColor // Change text color for selected state
                        ),
                  ).animate().slideY(duration: 750.ms, begin: -3, end: 0),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Custom Difficulty Radio Buttons
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: DifficultyLevel.values.map((DifficultyLevel level) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedDifficulty = level;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(
                      vertical: 8), // Add vertical space between buttons
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8), // Add padding

                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Radio<DifficultyLevel>(
                        value: level,
                        groupValue: selectedDifficulty,
                        activeColor: primaryColor,
                        onChanged: (DifficultyLevel? newLevel) {
                          if (newLevel != null) {
                            setState(() {
                              selectedDifficulty = newLevel;
                            });
                          }
                        },
                      ),
                      Text(
                        level.name.toUpperCase(),
                        style: const TextStyle(
                            color:
                                primaryColor // Change text color for selected state
                            ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Like/Dislike Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(
                  isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                  color: primaryColor,
                ),
                onPressed: () {
                  setState(() {
                    isLiked = true;
                  });
                },
              ),
              IconButton(
                icon: Icon(
                    !isLiked ? Icons.thumb_down : Icons.thumb_down_outlined,
                    color: primaryColor),
                onPressed: () {
                  setState(() {
                    isLiked = false;
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Submit Button (if needed)
          SizedBox(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: GestureDetector(
                    onTap: () async {
                      if (isLiked) {
                        widget.gridData.like += 1;
                      } else {
                        widget.gridData.dislike += 1;
                      }
                      if (selectedDifficulty == DifficultyLevel.easy) {
                        widget.gridData.easy += 1;
                      } else if (selectedDifficulty == DifficultyLevel.medium) {
                        widget.gridData.medium += 1;
                      } else if (selectedDifficulty == DifficultyLevel.hard) {
                        widget.gridData.hard += 1;
                      }

                      await FirebaseFirestore.instance
                          .collection('Maps')
                          .doc(widget.gridData.userId)
                          .update(widget.gridData.toMap())
                          .then((value) => Navigator.pop(context));
                    },
                    child: const Text(
                      "Go to Home",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 40,
                          color:
                              primaryColor // Change text color for selected state
                          ),
                    ).animate().slideY(duration: 750.ms, begin: 3, end: 0),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
