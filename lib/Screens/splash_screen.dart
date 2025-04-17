import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../accounts/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    Size media = MediaQuery.of(context).size;

    return AnimatedSplashScreen(
      backgroundColor: Colors.orange[50] ?? Colors.orange,  // ✅ Null Safety Applied
      splash: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset("assets/logo.png", height: media.height * 0.15),  // ✅ Height को % में बदला
          SizedBox(height: media.height * 0.04),
          Text(
            "Rawal Bhramin Samaj",
            style: GoogleFonts.breeSerif(
              fontWeight: FontWeight.bold,
              fontSize: media.width * 0.09,
            ),
          ),
        ],
      ),
      splashIconSize: 280,
      duration: 2000,
      nextScreen:  LoginScreen(),  // ✅ const keyword add किया (Performance Optimization)
      splashTransition: SplashTransition.fadeTransition,
      animationDuration: const Duration(seconds: 1),
    );
  }
}
