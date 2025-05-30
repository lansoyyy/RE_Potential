import 'package:flutter/material.dart';
import 'package:re_potential/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'RE Potential',
      home: HomeScreen(),
    );
  }
}
