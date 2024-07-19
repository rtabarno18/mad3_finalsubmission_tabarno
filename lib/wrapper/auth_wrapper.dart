import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mad3_finalsubmission_tabarno/Auth/auth_controller.dart';
import 'package:mad3_finalsubmission_tabarno/screens/home/home.dart';
import 'package:mad3_finalsubmission_tabarno/screens/login/login_screen.dart';

class AuthWrapper extends StatelessWidget {
  final AuthController authController;

  const AuthWrapper({super.key, required this.authController});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: authController.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          return HomePage(authController: authController);
        } else {
          return LoginPage(authController: authController);
        }
      },
    );
  }
}
