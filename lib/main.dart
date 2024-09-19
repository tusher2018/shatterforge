// import 'package:flame/game.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shatterforge/firebase_options.dart';
import 'package:shatterforge/splash_page.dart';

// import 'src/brick_breaker.dart';

void main() async {
  // final game = BrickBreaker();
  // runApp(GameWidget(game: game));
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CombinedSplashHomePage(),
    );
  }
}
