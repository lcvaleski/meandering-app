import 'package:flutter/material.dart';

class StoryCardContainer extends StatelessWidget {

  const StoryCardContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 340, // Adjust as needed
      height: 375, // Adjust as needed
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF2E2F45), // Adjust to match the exact shade
            Color(0xFF1E1F30),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
    );
  }
}