import 'dart:async';
import 'package:flutter/material.dart';
import 'digit_recognizer_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => DigitRecognizerScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(decoration: BoxDecoration(image: DecorationImage(image: AssetImage('assets/onboarding_bg.jpg'), fit: BoxFit.cover )) ),
      ),
    );
  }
}
