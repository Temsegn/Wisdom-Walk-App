import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const Spacer(),
              _buildLogo(),
              const SizedBox(height: 40),
              _buildWelcomeText(),
              const Spacer(),
              _buildButtons(context),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: const Color(0xFFF5E1E5),
            borderRadius: BorderRadius.circular(60),
          ),
          child: const Center(
            child: Icon(Icons.favorite, size: 60, color: Color(0xFFD4A017)),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'WisdomWalk',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4A4A4A),
            fontFamily: 'Playfair Display',
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeText() {
    return Column(
      children: const [
        Text(
          'Welcome to WisdomWalk',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4A4A4A),
          ),
        ),
        SizedBox(height: 16),
        Text(
          'A faith-centered community for Christian women to connect, share, and grow spiritually in a safe, supportive environment.',
          style: TextStyle(fontSize: 16, color: Color(0xFF757575)),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              context.go('/register');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4A017),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Create an Account',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: () {
              context.go('/login');
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFD4A017)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Log In',
              style: TextStyle(fontSize: 13, color: Color(0xFFD4A017)),
            ),
          ),
        ),
      ],
    );
  }
}
