import 'package:flutter/material.dart';
import 'dart:async';
import 'package:lottie/lottie.dart'; // Ensure you have the lottie package in your pubspec.yaml

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 10), () {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Lottie.asset('assets/lottie/intro.json', 
          height: 300,
          fit: BoxFit.fill,
        ), //Lottie animation
      ),
    );
  }
}