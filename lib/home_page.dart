// Updated HomeScreen with logo in the upper half
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset(
            'assets/images/background.jpg',
            fit: BoxFit.cover,
          ),
          // Position logo in the upper half of the screen
          Column(
            children: [
              // This will push the logo to the upper half
              Expanded(
                flex: 2,
                child: Center(
                  child: Hero(
                    tag: "hero",
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: MediaQuery.sizeOf(context).width * 0.7,
                    ),
                  ),
                ),
              ),
              // Empty space for the lower half
              Expanded(
                flex: 3,
                child: Container(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: MediaQuery.sizeOf(context).width * 0.5,
                          height: 50,
                          decoration: const BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage("assets/images/button.png"),
                                  fit: BoxFit.fill)),
                          child: Text("Play"),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
