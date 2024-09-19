import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shatterforge/map_create.dart';
import 'package:shatterforge/src/components/commonText.dart';
import 'package:shatterforge/src/config.dart';

class CombinedSplashHomePage extends StatefulWidget {
  @override
  _CombinedSplashHomePageState createState() => _CombinedSplashHomePageState();
}

class _CombinedSplashHomePageState extends State<CombinedSplashHomePage> {
  bool _logoAtCenter = true;
  bool _showButtons = false;
  bool _showSignInForm = false;
  bool _exitButtons = false;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _logoAtCenter = false;
      });

      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _showButtons = true;
        });
      });
    });
  }

  Widget _buildCustomButton(
      String text, VoidCallback onPressed, double delay, bool exitButton) {
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
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          width: MediaQuery.of(context).size.width * 0.4,
          height: 50,
          decoration: BoxDecoration(
            color: Color(0xFFEFEF5CE),
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
            child: Text(
              text,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  void _transitionToSignInForm() {
    setState(() {
      _exitButtons = true; // Trigger reverse animation for button exit
    });

    // Delay until the button exit animation completes, then show the sign-in form
    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() {
        _showButtons = false; // Hide buttons after exit animation
        _showSignInForm = true; // Show the sign-in form
      });
    });
  }

  // void _authenticateUser() async {
  //   String email = emailController.text;
  //   String password = passwordController.text;
  //   if (email.isEmpty) {
  //     showCommonSnackbar(
  //       context,
  //       message: 'Please enter your email.',
  //       icon: Icons.error,
  //     );
  //     return;
  //   } else if (password.isEmpty) {
  //     showCommonSnackbar(
  //       context,
  //       message: 'Please enter your password.',
  //       icon: Icons.error,
  //     );
  //     return;
  //   }
  //   try {
  //     final FirebaseAuth auth = FirebaseAuth.instance;
  //     UserCredential userCredential = await auth.signInWithEmailAndPassword(
  //         email: email, password: password);
  //     showCommonSnackbar(
  //       context,
  //       message: 'Logged in as: ${userCredential.user?.email}',
  //       icon: Icons.check_circle,
  //     );
  //     setState(() {
  //       _showSignInForm = false;
  //       _showButtons = true;
  //       _exitButtons = false;
  //     });
  //   } on FirebaseAuthException catch (e) {
  //     print(e.code);
  //     if (e.code == 'invalid-credential') {
  //       showCommonSnackbar(
  //         context,
  //         message: 'User not found, signing up...',
  //         icon: Icons.person_add,
  //       );
  //       _signUpUser(email, password);
  //     } else {
  //       showCommonSnackbar(
  //         context,
  //         message: 'Error: ${e.message}',
  //         icon: Icons.error,
  //       );
  //     }
  //   }
  // }
  // void _signUpUser(String email, String password) async {
  //   try {
  //     final FirebaseAuth auth = FirebaseAuth.instance;
  //     UserCredential userCredential = await auth.createUserWithEmailAndPassword(
  //         email: email, password: password);
  //     showCommonSnackbar(
  //       context,
  //       message: 'Signed up as: ${userCredential.user?.email}',
  //       icon: Icons.check_circle,
  //     );
  //     setState(() {
  //       _showSignInForm = false;
  //       _showButtons = true;
  //       _exitButtons = false;
  //     });
  //   } catch (e) {
  //     showCommonSnackbar(
  //       context,
  //       message: 'Sign-up failed: $e',
  //       icon: Icons.error,
  //     );
  //   }
  // }
  // void _resetPassword() async {
  //   String email = emailController.text.trim();
  //   if (email.isNotEmpty) {
  //     try {
  //       await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  //       showCommonSnackbar(
  //         context,
  //         message: 'Password reset email sent.',
  //         icon: Icons.restore,
  //       );
  //     } on FirebaseAuthException catch (e) {
  //       if (e.code == 'user-not-found') {
  //         showCommonSnackbar(
  //           context,
  //           message: 'User not found',
  //           icon: Icons.person_off_outlined,
  //         );
  //       } else {
  //         showCommonSnackbar(
  //           context,
  //           message: 'Failed to send password reset email.',
  //           icon: Icons.error,
  //         );
  //       }
  //     }
  //   } else {
  //     showCommonSnackbar(
  //       context,
  //       message: 'Please enter your email.',
  //       icon: Icons.error,
  //     );
  //   }
  // }

  Widget _buildSignInForm() {
    return Column(
      children: [
        _buildTextField('Email', emailController, Icons.email, 100),
        _buildTextField('Password', passwordController, Icons.lock, 400),
        Container(
            width: MediaQuery.of(context).size.width * 0.8,
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: _resetPassword,
              child: commonText("Forget password",
                  color: primaryColor, isBold: true),
            )),
        _buildCustomButton("Join", _authenticateUser, 700, !_exitButtons),
      ],
    );
  }

  Widget _buildTextField(String hintText, TextEditingController controller,
      IconData icon, double delay) {
    return TweenAnimationBuilder(
      tween: Tween<Offset>(
        begin: const Offset(1.5, 0), // Starting off-screen to the right
        end: Offset.zero, // Ending at the normal position
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
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          controller: controller,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.black),
            hintText: hintText,
            filled: true,
            fillColor: Color.fromARGB(150, 255, 248, 225),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(width: 2, color: Colors.black),
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
            // Animated logo
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
            // Buttons or sign-in form based on the state
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 800),
                child: _showButtons
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildCustomButton("Join", _transitionToSignInForm,
                              100, _exitButtons),
                          _buildCustomButton("Play", () {}, 400, _exitButtons),
                          _buildCustomButton("Maps", () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MapCreatePage(),
                                ));
                          }, 700, _exitButtons),
                          _buildCustomButton("Rank", () {}, 1000, _exitButtons),
                        ],
                      )
                    : _showSignInForm
                        ? _buildSignInForm()
                        : SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _authenticateUser() async {
    String email = emailController.text;
    String password = passwordController.text;

    if (email.isEmpty) {
      showCommonSnackbar(
        context,
        message: 'Please enter your email.',
        icon: Icons.error,
      );
      return;
    } else if (password.isEmpty) {
      showCommonSnackbar(
        context,
        message: 'Please enter your password.',
        icon: Icons.error,
      );
      return;
    }

    try {
      final FirebaseAuth auth = FirebaseAuth.instance;
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
          email: email, password: password);

      showCommonSnackbar(
        context,
        message: 'Logged in as: ${userCredential.user?.email}',
        icon: Icons.check_circle,
      );

      setState(() {
        _showSignInForm = false;
        _showButtons = true;
        _exitButtons = false;
      });
    } on FirebaseAuthException catch (e) {
         print(e);
      print(e.code);
      _handleAuthException(e);
    } catch (e) {
      showCommonSnackbar(
        context,
        message: 'An unknown error occurred. Please try again later.',
        icon: Icons.error,
      );
    }
  }

  void _signUpUser(String email, String password) async {
    try {
      final FirebaseAuth auth = FirebaseAuth.instance;
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
          email: email, password: password);

      showCommonSnackbar(
        context,
        message: 'Signed up as: ${userCredential.user?.email}',
        icon: Icons.check_circle,
      );

      setState(() {
        _showSignInForm = false;
        _showButtons = true;
        _exitButtons = false;
      });
    } on FirebaseAuthException catch (e) {
      _handleAuthException(e);
    } catch (e) {
      showCommonSnackbar(
        context,
        message: 'Sign-up failed. Please try again later.',
        icon: Icons.error,
      );
    }
  }

  void _resetPassword() async {
    String email = emailController.text.trim();

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
      print(e);
      print(e.code);
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
      case 'user-not-found':
        showCommonSnackbar(
          context,
          message: 'No user found with this email.',
          icon: Icons.person_off,
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
}
