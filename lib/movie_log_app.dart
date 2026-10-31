import 'package:flutter/material.dart';
import 'start_screen.dart';

class MovieLogApp extends StatelessWidget {
  const MovieLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MovieLog',
      theme: ThemeData(
        useMaterial3: false,
        fontFamily: 'Arial',
      ),
      home: const StartScreen(),
    );
  }
}
