import 'package:flutter/material.dart';

class BobaSplashScreen extends StatelessWidget {
  const BobaSplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE67E22), // Orange background color
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Boba Tea Image
                    Image.asset(
                      'assets/bg.png',
                      height: 400,
                    ),
                    const SizedBox(height: 20),
                    // Heading Text
                    const Text(
                      'Time for a boba break....',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Subheading Text
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        'Your daily dose of chewy pearls and sweet delight delivered to your doorstep. start your boba journey now',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Pagination Indicator
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     for (int i = 0; i < 4; i++)
            //       Container(
            //         margin: const EdgeInsets.symmetric(horizontal: 4),
            //         width: i == 3 ? 24 : 8, // Currently active page indicator
            //         height: 8,
            //         decoration: BoxDecoration(
            //           color: Colors.white,
            //           borderRadius: BorderRadius.circular(4),
            //         ),
            //       ),
            //   ],
            // ),
            const SizedBox(height: 40),
            // Get Started Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: ElevatedButton(
                onPressed: () {
                  // Navigation logic
                  Navigator.pushReplacementNamed(context, '/intro_page');

                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Color(0xFFE67E22),
                  minimumSize: Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: const Text(
                  'Get Started',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
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