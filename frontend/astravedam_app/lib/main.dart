import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';
import 'screens/birth_data_screen.dart';

void main() {
  runApp(const AstravedamApp());
}

class AstravedamApp extends StatelessWidget {
  const AstravedamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Astravedam',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        fontFamily: 'Georgia', // More spiritual font
      ),
      home: const WelcomeScreen(), // Start with welcome screen
      debugShowCheckedModeBanner: false,
    );
  }
}