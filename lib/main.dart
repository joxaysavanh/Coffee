import 'package:coffee/screens/showproduct.dart';
import 'package:coffee/themes/light_mode.dart';
import 'package:flutter/material.dart';
import 'package:coffee/screens/login_screen.dart';
import 'package:coffee/screens/show.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Coffee Shop App',
      theme: lightMode,

      home: const ProductPage(), // Start with the login screen
    );
  }
}

//kokokoo0
// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key});