import 'package:coffee/screens/showproduct.dart';
import 'package:coffee/themes/light_mode.dart';
import 'package:flutter/material.dart';
import 'package:coffee/screens/login_screen.dart';
import 'package:coffee/screens/show.dart';
import 'package:coffee/screens/intro.dart';
import 'package:coffee/screens/create.dart';
import 'package:coffee/screens/forget_password.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    var routes = {
        '/intro_page': (context) => const LoginScreen(),
        '/shop_page': (context) => const ProductPage1(),
        '/set_product_page': (context) => const ShowProductsPage(), // Assuming ProductPage is ShowProduct
        '/register_page': (context) => const RegisterPage1(),
        '/forgot_password_page': (context) => const ForgotPasswordPage(),
        };
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Coffee Shop App',
        theme: lightMode,
        home: const BobaSplashScreen(), // Start with the login screen
        routes: routes);
  }
}
