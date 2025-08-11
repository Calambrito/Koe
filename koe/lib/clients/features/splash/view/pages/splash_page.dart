import 'package:flutter/material.dart';
import 'package:koe/clients/features/auth/view/pages/login_page.dart';
import 'package:koe/clients/features/auth/view/pages/signup_page.dart';
import 'package:koe/clients/features/home/view/pages/main_navigation_page.dart';
import 'package:koe/core/theme/app_pallete.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Pallete.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo/title
            const Text(
              'Koe Music',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Pallete.whiteColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Music Streaming App',
              style: TextStyle(fontSize: 18, color: Pallete.subtitleText),
            ),
            const SizedBox(height: 60),

            // Navigation buttons
            _buildNavigationButton(
              context,
              'Go to Home Page',
              Icons.home,
              () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const MainNavigationPage(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildNavigationButton(
              context,
              'Go to Login Page',
              Icons.login,
              () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              ),
            ),
            const SizedBox(height: 16),
            _buildNavigationButton(
              context,
              'Go to Signup Page',
              Icons.person_add,
              () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const SignupPage()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButton(
    BuildContext context,
    String text,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return Container(
      width: 250,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: const LinearGradient(
          colors: [Pallete.gradient1, Pallete.gradient2],
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
        ),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Pallete.transparentColor,
          shadowColor: Pallete.transparentColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Pallete.whiteColor, size: 20),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Pallete.whiteColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
