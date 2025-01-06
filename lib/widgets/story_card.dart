import 'package:flutter/material.dart';
import '../screens/play_screen.dart';

class StoryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? selectedStory;
  final String? selectedGender;

  const StoryCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.selectedStory,
    required this.selectedGender,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlayScreen(
              selectedGender: selectedGender,
              selectedStory: selectedStory,
              isArchived: false,
            ),
            settings: RouteSettings(
              name: '${selectedStory}_${selectedGender}', // Firebase tracking
            ),
          ),
        );
      },
      child: Container(
        width: 220,
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: Colors.black12, width: 9), // Subtle grey border
          gradient: LinearGradient(
            colors: [Color(0xFF5C6689), Color(0xFF3B3E56)], // Adjusted gradient
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.yellow.withOpacity(0.2),
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(  // Ensure text doesn't exceed available space
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis, // Prevents text overflow
                      maxLines: 1,
                    ),
                    SizedBox(height: 4.0),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.white70,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.play_arrow_rounded,
                color: Colors.white70,
                size: 40,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
