import 'package:flutter/material.dart';
import '../screens/home_screen.dart'; // 홈스크린 import

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Event Board',
      debugShowCheckedModeBanner: false,
      home: HomeScreen(), // ← 여기를 바꿨어요
    );
  }
}
