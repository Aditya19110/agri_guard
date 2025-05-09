import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class RegistrationSuccessScreen extends StatefulWidget {
  @override
  _RegistrationSuccessScreenState createState() =>
      _RegistrationSuccessScreenState();
}

class _RegistrationSuccessScreenState extends State<RegistrationSuccessScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Lottie.asset(
          'assets/lottie/register.json',
          width: 200,
          height: 200,
          repeat: false,
        ),
      ),
    );
  }
}
