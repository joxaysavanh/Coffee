import 'package:flutter/material.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Column(
          children: [
            // Logo Area
            Container(
              padding: EdgeInsets.only(
                top: 60,
                bottom: 40,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: Center(
                child: Column(
                  children: [
                    // JKT Chanom Logo
                    Image.asset(
                      'assets/bg.png',
                      height: 120,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'JKT Chanom since 2025',
                      style: TextStyle(
                        color: Color(0xFFE67E22),
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Form Area
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: Color(0xFFE67E22),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 40),

                      // Username Field
                      TextField(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Username',
                          hintStyle: TextStyle(
                            color: Color(0xFFE67E22),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Phone Number Field
                      TextField(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Phone number',
                          hintStyle: TextStyle(
                            color: Color(0xFFE67E22),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Password Field
                      TextField(
                        obscureText: true,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Password',
                          hintStyle: TextStyle(
                            color: Color(0xFFE67E22),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Confirm Password Field
                      TextField(
                        obscureText: true,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Confirm password',
                          hintStyle: TextStyle(
                            color: Color(0xFFE67E22),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Create User Button
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Color(0xFFE67E22),
                          minimumSize: Size(200, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Text(
                          'Create User',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20), // Add some spacing

                      // Back Button
                      TextButton(
                        onPressed: () {
                          // Navigate back to the previous screen
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Back to Login',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
