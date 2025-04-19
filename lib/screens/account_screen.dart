import 'package:flutter/material.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Account Screen',
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
      ),
    );
  }
} 