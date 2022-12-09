import 'package:campus_rider/auth/auth_page.dart';
import 'package:campus_rider/maps/maps_home.dart';
import 'package:campus_rider/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return MapsHomeScreen();
          } else {
            return AuthScreen();
          }
        },
      ),
    );
  }
}
