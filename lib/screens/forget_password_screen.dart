// lib/screens/forgot_password_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../themes/apptheme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isVerified = false; // Controls which form is shown

  Future<void> _verifyUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Call to backend API to verify user exists with provided username and phone
        final response = await http.post(
          Uri.parse('http://192.168.100.152:3000/api/verify-user'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'userName': _usernameController.text,
            'phone': _phoneController.text,
          }),
        );

        setState(() {
          _isLoading = false;
        });

        if (response.statusCode == 200) {
          // User verified
          setState(() {
            _isVerified = true;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User verified. Please set a new password.')),
          );
        } else {
          // Verification failed
          final responseData = json.decode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData['message'] ?? 'User verification failed')),
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

  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Call to backend API to reset password
        final response = await http.post(
          Uri.parse('http://192.168.100.152:3000/api/reset-password'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'userName': _usernameController.text,
            'phone': _phoneController.text,
            'newPassword': _newPasswordController.text,
          }),
        );

        setState(() {
          _isLoading = false;
        });

        if (response.statusCode == 200) {
          // Password reset successful
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password reset successful!')),
          );
          
          // Navigate back to login screen after a short delay
          Future.delayed(const Duration(seconds: 2), () {
            Navigator.pushReplacementNamed(context, '/login_page');
          });
        } else {
          // Password reset failed
          final responseData = json.decode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData['message'] ?? 'Password reset failed')),
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
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Forgot Password'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Top design - orange background
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.2,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Center(
              child: Icon(
                Icons.lock_reset,
                size: 80,
                color: Colors.white,
              ),
            ),
          ),

          // Form part - white background
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        _isVerified ? 'ຕັ້ງລະຫັດຜ່ານໃໝ່' : 'ຢືນຢັນບັນຊີຂອງທ່ານ',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Username field - always visible
                      TextFormField(
                        controller: _usernameController,
                        enabled: !_isVerified, // Disable after verification
                        decoration: InputDecoration(
                          labelText: 'ຊື່ຜູ້ໃຊ້',
                          hintText: 'ປ້ອນຊື່ຜູ້ໃຊ້',
                          prefixIcon: Icon(Icons.person, color: AppTheme.primaryColor),
                          filled: true,
                          fillColor: Colors.grey[100],
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

                      // Phone field - always visible
                      TextFormField(
                        controller: _phoneController,
                        enabled: !_isVerified, // Disable after verification
                        decoration: InputDecoration(
                          labelText: 'ເບີໂທລະສັບ',
                          hintText: 'ປ້ອນເບີໂທລະສັບ',
                          prefixIcon: Icon(Icons.phone, color: AppTheme.primaryColor),
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Show new password fields only after verification
                      if (_isVerified) ...[
                        TextFormField(
                          controller: _newPasswordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'New Password',
                            hintText: 'Enter your new password',
                            prefixIcon: Icon(Icons.lock, color: AppTheme.primaryColor),
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 15),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'ກາລຸນາປ້ອນລະຫັດຜ່ານໃໝ່';
                            }
                            if (value.length < 6) {
                              return 'ລະຫັດຜ່ານຕ້ອງມີຢ່າງນ້ອຍ 6 ຕົວ';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'ຢືນຢັນລະຫັດຜ່ານ',
                            hintText: 'ຢືນຢັນລະຫັດຜ່ານ',
                            prefixIcon: Icon(Icons.lock_outline, color: AppTheme.primaryColor),
                            filled: true,
                            fillColor: Colors.grey[100],
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
                            if (value != _newPasswordController.text) {
                              return 'ລະຫັດຜ່ານບໍ່ຕົງກັນ';
                            }
                            return null;
                          },
                        ),
                      ],
                      const SizedBox(height: 40),

                      // Action button - Verify or Reset based on state
                      SizedBox(
                        width: 200,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : (_isVerified ? _resetPassword : _verifyUser),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  _isVerified ? 'Reset Password' : 'Verify Account',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Back to login button
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/login_page');
                        },
                        child: Text(
                          'Back to Login',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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