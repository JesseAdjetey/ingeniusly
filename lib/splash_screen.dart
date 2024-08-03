import 'package:flutter/material.dart';
import 'package:ingeniusly/LoginPage.dart';
import 'dart:async';

import 'package:ingeniusly/main.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Set duration for the full cycle (big-small-big-small)
    _controller = AnimationController(
      duration: const Duration(seconds: 1), // 1 second for each big-small cycle
      vsync: this,
    )..repeat(reverse: true); // Repeat the animation with a reverse effect

    _animation = Tween<double>(begin: 1.0, end: 1.2).animate(_controller);

    Timer(Duration(seconds: 5), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ScaleTransition(
          scale: _animation,
          child: Image.asset(
            'images/inGeniusly.png', // Ensure the image path is correct
            height: 200.0,
            width: 200.0,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
