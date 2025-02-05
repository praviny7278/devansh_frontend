import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';

import '../auth/number_input.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  get splash => null;

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Column(
        children: [
          Center(
            child: Container(
              alignment: Alignment.center,
              // padding: const EdgeInsets.fromLTRB(50, 5, 50, 5)
              width: 240,
              height: 250,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
                image: const DecorationImage(
                    image: AssetImage('assets/milk.jpg'), fit: BoxFit.fill),
              ),
            ),
          ),
        ],
      ),
      nextScreen: const NumberTextField(),
      splashIconSize: 300,
      backgroundColor: Colors.greenAccent,
    );
  }
}
