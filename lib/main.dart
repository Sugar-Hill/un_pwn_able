import 'package:flutter/material.dart';
import 'package:un_pwn_able/screens/chat_screen.dart';
import 'package:un_pwn_able/screens/landing_screen.dart';
import 'package:un_pwn_able/screens/login_screen.dart';
import 'package:un_pwn_able/screens/registration_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: LandingScreen.id,
      routes: {
        LandingScreen.id: (context) => LandingScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        RegistrationScreen.id: (context) => RegistrationScreen(),
        ChatScreen.id: (context) => ChatScreen(),
      },
    );
  }
}

