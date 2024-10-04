// ignore_for_file: must_be_immutable, use_build_context_synchronously, non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shatterforge/TileData.dart';
import 'package:shatterforge/playerModel.dart';
import 'package:shatterforge/src/brick_breaker.dart';
import 'package:shatterforge/src/components/commonText.dart';

import 'package:shatterforge/src/config.dart';
import 'package:shatterforge/src/widgets/overlay_screen.dart';

enum DifficultyLevel { easy, medium, hard }

class GameApp extends StatefulWidget {
  GameApp(
      {super.key,
      required this.gridData,
      required this.playerModel,
      this.playerTest = false});
  GridData gridData;
  PlayerModel? playerModel;
  bool playerTest;

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
    int health = 3;
    if (widget.playerModel != null) {
      switch (widget.playerModel!.level) {
        case 1:
        case 2:
        case 3:
        case 4:
        case 5:
        case 6:
          health = 3;
          break;
        case 7:
          health = 4;
          break;
        case 8:
          health = 5;
          break;
        case 9:
          health = 6;
          break;
        case 10:
          health = 7;
          break;
        case 11:
          health = 8;
          break;
        case 12:
          health = 9;
          break;
        case 13:
          health = 10;
          break;
        default:
          health = 10;
          break;
      }
    }
    if (widget.playerTest) {
      health = 10;
    }
    game =
        BrickBreaker(context, gridData: widget.gridData, playerHealth: health);
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
          bodyColor: const Color.fromARGB(255, 0, 0, 0),
          displayColor: const Color.fromARGB(255, 0, 0, 0),
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
                      EndScreen("GAME OVER", false),
                  PlayState.won.name: (context, game) =>
                      EndScreen("Y O U   W O N ! ! !", true),

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

  Widget EndScreen(String text, bool win) {
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
                Expanded(
                  child: FittedBox(
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
                Expanded(
                  child: FittedBox(
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
                        } else if (selectedDifficulty ==
                            DifficultyLevel.medium) {
                          widget.gridData.medium += 1;
                        } else if (selectedDifficulty == DifficultyLevel.hard) {
                          widget.gridData.hard += 1;
                        }
                        if (widget.playerModel != null &&
                            FirebaseAuth.instance.currentUser != null &&
                            FirebaseAuth.instance.currentUser!.uid !=
                                widget.gridData.userId) {
                          if (win) {
                            widget.playerModel!.matchTotalWin += 1;
                          } else {
                            widget.playerModel!.matchTotalLose += 1;
                          }
                          widget.playerModel!.totalBricksDestroyed +=
                              game.brickBreak;
                          widget.playerModel!.matchesPlayed += 1;
                          widget.playerModel!.coins += 10;

                          //own player progress
                          FirebaseFirestore.instance
                              .collection('players')
                              .doc(FirebaseAuth.instance.currentUser!.uid)
                              .update({
                            'coin': widget.playerModel!.coins,
                            'matchesPlayed': widget.playerModel!.matchesPlayed,
                            'totalBricksDestroyed':
                                widget.playerModel!.totalBricksDestroyed,
                            'matchTotalWin': widget.playerModel!.matchTotalWin,
                            'matchTotalLose':
                                widget.playerModel!.matchTotalLose,
                          });

                          //bitted player progress
                          FirebaseFirestore.instance
                              .collection('Maps')
                              .doc(widget.gridData.userId)
                              .update(widget.gridData.toMap());
                          FirebaseFirestore.instance
                              .collection('players')
                              .doc(widget.gridData.userId)
                              .update({
                            "baseLiked": widget.gridData.like,
                            "baseDisliked": widget.gridData.dislike,
                          });
                        }
                        if (win && widget.playerTest) {
                          try {
                            widget.gridData.isPlayable = true;
                            await FirebaseFirestore.instance
                                .collection('Maps')
                                .doc(FirebaseAuth.instance.currentUser!.uid)
                                .update({
                              'isPlayable': true,
                            });
                            showCommonSnackbar(
                              context,
                              message:
                                  'Map updated! Get ready to beat your opponents!',
                              icon: Icons.save,
                            );
                          } catch (e) {
                            showCommonSnackbar(
                              context,
                              message:
                                  'An error occoured map could not saved successfully.',
                              icon: Icons.error,
                            );
                          }
                          Navigator.pop(context);
                        }
                        Navigator.pop(context);
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
