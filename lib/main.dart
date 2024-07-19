//import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mad3_finalsubmission_tabarno/Auth/auth_controller.dart';
import 'package:mad3_finalsubmission_tabarno/firebase_options.dart';
import 'package:mad3_finalsubmission_tabarno/screens/home/create_room.dart';
import 'package:mad3_finalsubmission_tabarno/screens/home/home.dart';
import 'package:mad3_finalsubmission_tabarno/screens/home/join_room.dart';
import 'package:mad3_finalsubmission_tabarno/screens/login/login_screen.dart';
import 'package:mad3_finalsubmission_tabarno/screens/login/signup_screen.dart';
import 'package:mad3_finalsubmission_tabarno/wrapper/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AuthController _authController = AuthController();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TicTacToe 1v1 Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => AuthWrapper(authController: _authController),
        '/login': (context) => LoginPage(authController: _authController),
        '/signup': (context) => SignUpPage(authController: _authController),
        '/home': (context) => HomePage(authController: _authController),
        '/create_room': (context) =>
            CreateRoomPage(authController: _authController),
        '/join_room': (context) =>
            JoinRoomPage(authController: _authController),
      },
    );
  }
}
