import 'package:coffee/screens/showproduct.dart';
import 'package:coffee/themes/light_mode.dart';
import 'package:flutter/material.dart';
import 'package:coffee/screens/login_screen.dart';
import 'package:coffee/screens/show.dart';
import 'package:coffee/screens/test.dart';
import 'package:coffee/screens/Create.dart';

// class IntroPage extends StatelessWidget { const IntroPage({Key? key}) : super(key: key); @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Intro'))); }
// class ShopPage extends StatelessWidget { const ShopPage({Key? key}) : super(key: key); @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Shop'))); }
// class CartPage extends StatelessWidget { const CartPage({Key? key}) : super(key: key); @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Cart'))); }

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
        home: const BobaSplashScreen(), // Start with the login screen
        routes: {
        '/intro_page': (context) => const LoginScreen(),
        '/shop_page': (context) => const ProductPage1(),
        '/set_product_page': (context) => const ProductPage(), // Assuming ProductPage is ShowProduct
        '/register_page': (context) => const SignUpScreen(),
        });
  }
}
//sada
