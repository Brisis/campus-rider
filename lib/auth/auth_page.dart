import 'package:campus_rider/auth/login_screen.dart';
import 'package:campus_rider/auth/register_screen.dart';
import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  //intially show login
  bool showLoginSceen = true;

  void toggleScreens() {
    setState(() {
      showLoginSceen = !showLoginSceen;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginSceen) {
      return LoginScreen(showRegisterScreen: toggleScreens);
    } else {
      return RegisterScreen(
        showLoginScreen: toggleScreens,
      );
    }
  }
}
