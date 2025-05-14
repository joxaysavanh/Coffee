// lib/screens/login_screen.dart
import 'package:coffee/screens/forget_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../themes/apptheme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

<<<<<<< Updated upstream
  void _login() async { // Make the function async
=======
  Future<void> _login() async {
>>>>>>> Stashed changes
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
<<<<<<< Updated upstream
        print('Username to send: ${_usernameController.text}');
        print('Password to send: ${_passwordController.text}');

final response = await http.post(
  Uri.parse('http://192.168.114.192:3000/login'),
  headers: <String, String>{
    'Content-Type': 'application/json; charset=UTF-8',
  },
  body: jsonEncode(<String, String>{
    'username': _usernameController.text,
    'password': _passwordController.text,
  }),
);

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          // Assuming your backend returns a 'success' boolean and a 'message'
          if (responseData['success'] == true) {
            // Login successful, navigate to shop page
            setState(() {
              _isLoading = false;
            });
            Navigator.pushReplacementNamed(context, '/set_product_page');
            // Optionally store user ID or token if needed
            print('Login successful: ${responseData['message']}');
          } else {
            // Login failed (e.g., wrong credentials), show error message from backend
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(responseData['message'] ?? 'Login failed: Invalid credentials')),
            );
          }
        } else {
          // Handle server errors (e.g., 404, 500)
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Server error: ${response.statusCode}. Please try again later.')),
          );
        }
      } catch (error) {
        // Handle network errors (e.g., no connection)
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Network error. Please check your connection and try again.')),
        );
        print('Error during login: $error');
=======
        // Call to your backend API
        final response = await http.post(
          Uri.parse('http://192.168.100.152:3000/api/login'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'userName': _usernameController.text,
            'password': _passwordController.text,
          }),
        );

        setState(() {
          _isLoading = false;
        });

        if (response.statusCode == 200) {
          // Login successful
          final responseData = json.decode(response.body);

          // You might want to save user data or token in shared preferences here

          // Navigate to shop screen
          Navigator.pushReplacementNamed(context, '/shop_page');
        } else {
          // Login failed
          final responseData = json.decode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData['message'] ?? 'Login failed')),
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
>>>>>>> Stashed changes
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Top logo part - white background
          Expanded(
            flex: 5,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(50),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // JKT Logo
                  Image.asset(
                    'assets/logo.png',
                    height: 200,
                    width: 200,
                    // If asset is not available, use a placeholder
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        width: 200,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            'JKT',
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  // JKT Chanom text
                  Text(
                    'JKT Chanom since 2025',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom form part - orange background
          Expanded(
            flex: 6,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      // Username field
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          hintText: 'Username',
                          prefixIcon:
                              Icon(Icons.person, color: AppTheme.primaryColor),
                          hintStyle: const TextStyle(
                              color: Color.fromRGBO(0, 0, 0, 0.702)),
                          filled: true,
                          fillColor: const Color.fromARGB(255, 255, 255, 255),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'ກາລຸນາປ້ອນຊື່ຜູ້ໃຊ້';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Password field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'Password',
                          prefixIcon:
                              Icon(Icons.lock, color: AppTheme.primaryColor),
                          hintStyle: const TextStyle(
                              color: Color.fromARGB(179, 0, 0, 0)),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'ກາລຸນາປ້ອນລະຫັດຜ່ານ';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),

                      // Login button
                      SizedBox(
                        width: 200,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: AppTheme.primaryColor,
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: AppTheme.primaryColor)
                              : const Text(
                                  'login',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),

                      // Forgot password
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const ForgotPasswordScreen()),
                            );
                          },
                          child: const Text('Forget Password'),
                        ),
                      ),

                      const Spacer(),

                      // Register option
                      Column(
                        children: [
                          const Text(
                            'Don\'t have an account?',
                            style: TextStyle(
                                color: Color.fromARGB(255, 255, 255, 255)),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context,
                                  '/register_page'); // Navigate to registration page
                            },
                            child: const Text(
                              'Create an account',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
