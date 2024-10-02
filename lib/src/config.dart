import 'package:flutter/material.dart';

const difficultyModifier = 1.02;

const primaryColor = Color(0xFFEFEF5CE);
final int maxHealth = 10;
int maxLevel = 13; // Maximum level the player can reach

class Config {
  static late double ballRadius;
  static late double batWidth;
  static late double batHeight;
  static late double batStep;
  static late double screenWidth;
  static late double screenHeight;
  static int balldamage = 50;

  // Function to initialize sizes based on screen width and height
  static void initialize(BuildContext context) {
    screenWidth = MediaQuery.sizeOf(context).width;
    screenHeight = MediaQuery.sizeOf(context).height;
    // const double ballPercentage = 0.02; // Ball is 4% of the screen width
    // const double batWidthPercentage = 0.25; // Bat is 25% of the screen width
    // const double batHeightPercentage =
    //     0.02; // Bat height is 4% of the screen height
    // const double batStepPercentage = 0.05; // Bat step is 5% of the screen width

    // ballRadius = screenWidth * ballPercentage;
    // batWidth = screenWidth * batWidthPercentage;
    // batHeight = screenHeight * batHeightPercentage;
    // batStep = screenWidth * batStepPercentage;
    ballRadius = 8.0; // Ball radius in pixels
    batWidth = 100.0; // Bat width in pixels
    batHeight = 10.0; // Bat height in pixels
    batStep = 15.0; // Bat step (how much the bat moves) in pixels
  }
}
