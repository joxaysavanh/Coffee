// lib/screens/register_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../themes/apptheme.dart';


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Call to your backend API
        final response = await http.post(
          Uri.parse('http://192.168.100.152:3000/api/register'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'userName': _usernameController.text,
            'phone': _phoneController.text,
            'password': _passwordController.text,
          }),
        );

        setState(() {
          _isLoading = false;
        });

        if (response.statusCode == 201) {
          // Registration successful
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration successful!')),
          );
          // Navigate to login screen
          Navigator.pushReplacementNamed(context, '/login_page');
        } else {
          // Registration failed
          final responseData = json.decode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData['message'] ?? 'Registration failed')),
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
            flex: 4,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Back button
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  
                  // JKT Logo
                  Image.asset(
                    'assets/logo.png',
                    height: 150,
                    width: 150,
                    // If asset is not available, use a placeholder
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 150,
                        width: 150,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            'JKT',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  // JKT Chanom text
                  Text(
                    'JKT Chanom since 2025',
                    style: TextStyle(
                      fontSize: 18,
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
            flex: 7,
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
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),

                        // Username field
                        TextFormField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            hintText: 'ຊື່ຜູ້ໃຊ້',
                            prefixIcon: Icon(Icons.person, color: AppTheme.primaryColor),
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
                              return 'ກາລຸນາປ້ອນຊື່ຜູ້ໃຊ້';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),

                        // Phone field
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: 'ເບີໂທລະສັບ',
                            prefixIcon: Icon(Icons.phone, color: AppTheme.primaryColor),
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
                              return 'ກາລຸນາປ້ອນເບີໂທລະສັບ';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),

                        // Password field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: 'ລະຫັດຜ່ານ',
                            prefixIcon: Icon(Icons.lock, color: AppTheme.primaryColor),
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
                            if (value.length < 6) {
                              return 'ລະຫັດຜ່ານຕ້ອງມີຢ່າງນ້ອຍ 6 ຕົວ';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),

                        // Confirm Password field
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: 'ຢືນຢັນລະຫັດຜ່ານ',
                            prefixIcon: Icon(Icons.lock_outline, color: AppTheme.primaryColor),
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
                              return 'ກາລຸນາຢືນຢັນລະຫັດຜ່ານ';
                            }
                            if (value != _passwordController.text) {
                              return 'ລະຫັດຜ່ານບໍ່ຕົງກັນ';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 30),

                        // Create User button
                        SizedBox(
                          width: 200,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _register,
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
                                    'Create User',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Already have an account
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'ທ່ານມີບັນຊີແລ້ວບໍ່?',
                              style: TextStyle(color: Colors.white),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacementNamed(context, '/login_page');
                              },
                              child: const Text(
                                'Login',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
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
          ),
        ],
      ),
    );
  }
}