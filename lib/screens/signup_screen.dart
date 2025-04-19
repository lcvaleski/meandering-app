// signup_screen.dart
import 'package:flutter/material.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Sign‑Up Screen',
            style: TextStyle(fontSize: 24, color: Colors.white)
        ),
      ),
    );
  }
}
