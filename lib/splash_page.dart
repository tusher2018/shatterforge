// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shatterforge/all_match.dart';
import 'package:shatterforge/leaderboard.dart';
import 'package:shatterforge/map_create.dart';
import 'package:shatterforge/playerModel.dart';
import 'package:shatterforge/player_update.dart';
import 'package:shatterforge/profile.dart';
import 'package:shatterforge/src/components/commonText.dart';
import 'package:shatterforge/src/config.dart';

class CombinedSplashHomePage extends StatefulWidget {
  @override
  _CombinedSplashHomePageState createState() => _CombinedSplashHomePageState();
}

class _CombinedSplashHomePageState extends State<CombinedSplashHomePage> {
  PlayerModel? _playerData;
  bool _logoAtCenter = true;
  bool _showButtons = false;
  bool _showSignInForm = false;
  bool _exitButtons = false;
  bool _exitingSignInForm = false;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  // Transition to Sign-In form with exit animation for buttons
  void _transitionToSignInForm() {
    setState(() {
      _exitButtons = true; // Start exit animation for buttons
    });

    // Delay until button exit animation completes, then show sign-in form
    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() {
        _showButtons = false;
        _showSignInForm = true;
        _exitButtons = false; // Reset button exit state for the future
      });
    });
  }

  // Transition back to buttons with exit animation for sign-in form
  void _transitionToButtons() {
    setState(() {
      _exitingSignInForm = true; // Start exit animation for sign-in form
    });

    // Delay until sign-in form exit animation completes, then show buttons
    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() {
        _showSignInForm = false;
        _showButtons = true;
        _exitingSignInForm = false; // Reset sign-in form exit state
      });
    });
  }

  Future<void> _loadPlayerData(String userId) async {
    try {
      // Reference to Firestore collection
      final playerDoc = await FirebaseFirestore.instance
          .collection('players')
          .doc(userId)
          .get();

      if (playerDoc.exists) {
        // Create PlayerModel from the data
        PlayerModel playerData = PlayerModel.fromMap(playerDoc.data()!);

        // Update state with player data
        setState(() {
          _playerData = playerData;
          balldamage = playerData.ballDamage;
        });

        print('Player data loaded successfully');
      } else {
        print('No player data found for this user.');
      }
    } catch (e) {
      print('Failed to load player data: $e');
    }
  }

  @override
  void initState() {
    super.initState();

    // Check if the user is logged in, and if so, load their data
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _loadPlayerData(user.uid);
    }

    // Simulate initial splash logo animation
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _logoAtCenter = false;
      });

      // Show buttons after logo animation
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _showButtons = true;
        });
      });
    });
  }

  // Build Sign-In Form with enter/exit animations
  Widget _buildSignInForm() {
    return Column(
      children: [
        _buildTextField('Email', emailController, Icons.email, 100),
        _buildTextField('Password', passwordController, Icons.lock, 400),
        TweenAnimationBuilder(
          tween: Tween<Offset>(
            begin: _exitingSignInForm
                ? Offset.zero
                : const Offset(1.5, 0), // Entry/Exit based on state
            end: _exitingSignInForm
                ? const Offset(1.5, 0)
                : Offset.zero, // Exit animation moves to the right
          ),
          duration: Duration(milliseconds: 700),
          curve: Curves.ease,
          builder: (context, Offset offset, child) {
            return Transform.translate(
              offset: Offset(MediaQuery.of(context).size.width * offset.dx, 0),
              child: child,
            );
          },
          child: GestureDetector(
            onTap: () {
              _signUpUser(
                  context, emailController.text, passwordController.text);
            },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: MediaQuery.of(context).size.width * 0.4,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFEFEF5CE),
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(color: Colors.black, blurRadius: 6),
                  BoxShadow(
                      color: Colors.black,
                      blurRadius: 6,
                      blurStyle: BlurStyle.inner),
                ],
                border: Border.all(color: Colors.black, width: 2.5),
              ),
              child: Center(
                child: commonText("Join",
                    size: 22, isBold: true, color: Colors.black),
              ),
            ),
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.8,
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: _transitionToButtons, // Go back to buttons
            child: commonText("Go Back", color: primaryColor, isBold: true),
          ),
        ),
      ],
    );
  }

  // Build TextField with enter/exit animations
  Widget _buildTextField(String hintText, TextEditingController controller,
      IconData icon, double delay) {
    return TweenAnimationBuilder(
      tween: Tween<Offset>(
        begin: _exitingSignInForm
            ? Offset.zero
            : const Offset(1.5, 0), // Entry/Exit based on state
        end: _exitingSignInForm
            ? const Offset(1.5, 0)
            : Offset.zero, // Exit animation moves to the right
      ),
      duration: Duration(milliseconds: delay.toInt()),
      curve: Curves.ease,
      builder: (context, Offset offset, child) {
        return Transform.translate(
          offset: Offset(MediaQuery.of(context).size.width * offset.dx, 0),
          child: child,
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        width: MediaQuery.of(context).size.width * 0.8,
        child: TextField(
          style:
              const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          controller: controller,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.black),
            hintText: hintText,
            filled: true,
            fillColor: const Color.fromARGB(150, 255, 248, 225),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(width: 2, color: Colors.black),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            Image.asset(
              'assets/images/background.jpg',
              fit: BoxFit.cover,
            ),

            AnimatedPositioned(
              duration: const Duration(seconds: 1),
              curve: Curves.easeInOut,
              top: _logoAtCenter
                  ? MediaQuery.of(context).size.height * 0.3
                  : MediaQuery.of(context).size.height * 0.05,
              left: MediaQuery.of(context).size.width * 0.15,
              right: MediaQuery.of(context).size.width * 0.15,
              child: Image.asset(
                'assets/images/logo.png',
                width: MediaQuery.of(context).size.width * 0.7,
              ),
            ),

            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 10),
                child: _showButtons
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          iconsBuild(
                            "assets/images/play.png",
                            "Play",
                            size: 120,
                            delay: 300,
                            color: Colors.black,
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AllMatch(
                                    playerModel: _playerData,
                                  ),
                                ),
                              );
                            },
                            exitButton: _exitButtons,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              iconsBuild("assets/images/join.png", "Join",
                                  _transitionToSignInForm,
                                  size: 80,
                                  delay: 300,
                                  exitButton: _exitButtons),
                              iconsBuild("assets/images/map.png", "Map", () {
                                if (_playerData == null) {
                                  showCommonSnackbar(
                                    context,
                                    message: 'Make sure you joined!',
                                    icon: Icons.error,
                                  );
                                  return;
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MapCreatePage(
                                      playerData: _playerData!,
                                    ),
                                  ),
                                );
                              }, delay: 600, exitButton: _exitButtons),
                              iconsBuild(
                                "assets/images/rank.png",
                                "LeaderShip",
                                delay: 900,
                                exitButton: _exitButtons,
                                () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Leaderboard(
                                        playerModel: _playerData,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              iconsBuild(
                                delay: 900,
                                exitButton: _exitButtons,
                                "assets/images/update.png",
                                "Update",
                                () {
                                  if (_playerData == null) {
                                    showCommonSnackbar(
                                      context,
                                      message: 'Make sure you joined!',
                                      icon: Icons.error,
                                    );
                                    return;
                                  }

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PlayerUpgradePage(
                                        playerModel: _playerData!,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              iconsBuild(
                                  "assets/images/profile.png",
                                  delay: 1200,
                                  exitButton: _exitButtons,
                                  "Profile", () {
                                if (_playerData == null) {
                                  showCommonSnackbar(
                                    context,
                                    message: 'Make sure you joined!',
                                    icon: Icons.error,
                                  );
                                  return;
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => PlayerProfilePage(
                                            profile: _playerData!,
                                          )),
                                );
                              }),
                              iconsBuild(
                                  "assets/images/settings.png",
                                  delay: 1500,
                                  exitButton: _exitButtons,
                                  "Settings",
                                  () {}),
                            ],
                          )
                        ],
                      )
                    : _showSignInForm
                        ? _buildSignInForm()
                        : const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget iconsBuild(String Path, String name, VoidCallback onPressed,
      {double size = 50,
      Color color = primaryColor,
      required double delay,
      required bool exitButton}) {
    return TweenAnimationBuilder(
      tween: Tween<Offset>(
        begin: exitButton ? Offset.zero : const Offset(1.5, 0), // Entry
        end: exitButton ? const Offset(1.5, 0) : Offset.zero, // Exit animation
      ),
      duration: Duration(milliseconds: delay.toInt()),
      curve: Curves.ease,
      builder: (context, Offset offset, child) {
        return Transform.translate(
          offset: Offset(MediaQuery.of(context).size.width * offset.dx, 0),
          child: child,
        );
      },
      child: GestureDetector(
        onTap: onPressed,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              Path,
              height: size,
              width: size,
            ),
            if ((size != 120))
              const SizedBox(
                height: 10,
              ),
            commonText(name,
                isBold: true, size: (size == 120) ? 24 : 14, color: color)
          ],
        ),
      ),
    );
  }

  void _signUpUser(BuildContext context, String email, String password) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    if (email.isEmpty) {
      showCommonSnackbar(context,
          message: 'Please enter your email.', icon: Icons.error);
      return;
    }

    if (password.isEmpty) {
      showCommonSnackbar(context,
          message: 'Please enter your password.', icon: Icons.error);
      return;
    }

    showCommonSnackbar(context, message: 'Please wait...', icon: Icons.error);

    try {
      // Create a new user account
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
          email: email, password: password);

      // Generate a unique Game ID for the player (or use the Firebase user ID)
      String gameId = userCredential.user!.uid;

      // Create a new player model instance with default values
      PlayerModel newPlayer = PlayerModel(
        name: "Player", // Default name (can be updated later)
        gameId: gameId,
        email: email,
        password: password, // This can be hashed for security reasons
      );

      // Save the player data to Firestore
      await firestore.collection('players').doc(gameId).set(newPlayer.toMap());

      showCommonSnackbar(context,
          message: 'Account created successfully!', icon: Icons.check_circle);
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _loadPlayerData(user.uid);
      }
      setState(() {
        _showSignInForm = false;
        _showButtons = true;
        _exitButtons = false;
      });
    } on FirebaseAuthException catch (e) {
      print(e);

      if (e.code == "email-already-in-use") {
        handleUserAuthentication(context, email, password);
      } else {
        _handleAuthException(e);
      }
    }
  }

  void _resetPassword(String email) async {
    if (email.isEmpty) {
      showCommonSnackbar(
        context,
        message: 'Please enter your email.',
        icon: Icons.error,
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      showCommonSnackbar(
        context,
        message: 'Password reset email sent.',
        icon: Icons.restore,
      );
    } on FirebaseAuthException catch (e) {
      _handleAuthException(e);
    } catch (e) {
      showCommonSnackbar(
        context,
        message: 'Failed to send password reset email. Please try again later.',
        icon: Icons.error,
      );
    }
  }

  void _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        showCommonSnackbar(
          context,
          message: 'The email address is not valid.',
          icon: Icons.error,
        );
        break;
      case 'user-disabled':
        showCommonSnackbar(
          context,
          message: 'This user account has been disabled.',
          icon: Icons.block,
        );
        break;
      case 'wrong-password':
        showCommonSnackbar(
          context,
          message: 'Incorrect password.',
          icon: Icons.lock_open,
        );
        break;
      case 'email-already-in-use':
        showCommonSnackbar(
          context,
          message: 'This email is already associated with another account.',
          icon: Icons.email,
        );
        break;
      case 'operation-not-allowed':
        showCommonSnackbar(
          context,
          message: 'Email/password accounts are not enabled.',
          icon: Icons.block,
        );
        break;
      case 'weak-password':
        showCommonSnackbar(
          context,
          message: 'The password provided is too weak.',
          icon: Icons.lock,
        );
        break;
      case 'network-request-failed':
        showCommonSnackbar(
          context,
          message: 'Network error. Please check your connection.',
          icon: Icons.wifi_off,
        );
        break;
      case 'too-many-requests':
        showCommonSnackbar(
          context,
          message: 'Too many attempts. Please try again later.',
          icon: Icons.hourglass_empty,
        );
        break;
      default:
        showCommonSnackbar(
          context,
          message: 'Authentication error: ${e.message}',
          icon: Icons.error,
        );
        break;
    }
  }

  void _showResetPasswordConfirmationDialog(String email) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: primaryColor,
          title: commonText('Reset Password',
              color: Colors.black, size: 14, isBold: true),
          content: commonText(
              'The password you entered is incorrect. Would you like to reset your password?',
              overflow: TextOverflow.visible,
              size: 12,
              color: Colors.black),
          actions: [
            SizedBox(
              width: MediaQuery.sizeOf(context).width * 0.8,
              child: Row(
                children: [
                  Expanded(
                    child: commonButton(context, 'Try again', () {
                      Navigator.of(context).pop();
                    }, fontSize: 12),
                  ),
                  SizedBox(
                    width: 16,
                  ),
                  Expanded(
                    child: commonButton(context, "Reset Password", () {
                      Navigator.of(context).pop();
                      _resetPassword(email);
                    }, fontSize: 12),
                  )
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void handleUserAuthentication(
      BuildContext context, String email, String password) async {
    final FirebaseAuth auth = FirebaseAuth.instance;

    try {
      // Try to sign in first
      await auth.signInWithEmailAndPassword(email: email, password: password);

      // If sign-in is successful
      showCommonSnackbar(context,
          message: 'Logged in successfully!', icon: Icons.check_circle);
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _loadPlayerData(user.uid);
      }
      setState(() {
        _showSignInForm = false;
        _showButtons = true;
        _exitButtons = false;
      });
    } on FirebaseAuthException catch (e) {
      print(e);
      if (e.code == 'invalid-credential') {
        _showResetPasswordConfirmationDialog(email);
      } else {
        _handleAuthException(e);
      }
    }
  }
}
