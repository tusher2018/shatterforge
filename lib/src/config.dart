import 'package:flutter/material.dart';

const difficultyModifier = 1.02;
const int balldamage = 50;
const primaryColor = Color(0xFFEFEF5CE);

class Config {
  static late double ballRadius;
  static late double batWidth;
  static late double batHeight;
  static late double batStep;
  static late double screenWidth;
  static late double screenHeight;

  // Function to initialize sizes based on screen width and height
  static void initialize(BuildContext context) {
    screenWidth = MediaQuery.sizeOf(context).width;
    screenHeight = MediaQuery.sizeOf(context).height;
    const double ballPercentage = 0.02; // Ball is 4% of the screen width
    const double batWidthPercentage = 0.25; // Bat is 25% of the screen width
    const double batHeightPercentage =
        0.02; // Bat height is 4% of the screen height
    const double batStepPercentage = 0.05; // Bat step is 5% of the screen width

    ballRadius = screenWidth * ballPercentage;
    batWidth = screenWidth * batWidthPercentage;
    batHeight = screenHeight * batHeightPercentage;
    batStep = screenWidth * batStepPercentage;
  }
}
