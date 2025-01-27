import 'package:flutter/material.dart';
import 'package:sleepless_app/screens/audio_list_screen.dart';

class LibraryButton extends StatelessWidget {
  final String selectedStory;
  final String selectedGender;

  const LibraryButton({super.key, required this.selectedStory, required this.selectedGender});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToAudioListScreen(context),
      child: Container(
        width: 75,
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: Colors.black12, width: 7),
          gradient: LinearGradient(
            colors: [Color(0xFF5C6689), Color(0xFF3B3E56)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 77),
              blurRadius: 8,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            Icons.library_music_rounded,
            color: Colors.white70,
            size: 28,
          ),
        ),
      ),
    );
  }

  void _navigateToAudioListScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AudioListScreen(
          selectedStory: selectedStory,
          selectedGender: selectedGender,
        ),
        settings: RouteSettings(
            name: 'audio_library_list/${selectedStory}_$selectedGender' // Firebase tracking
        )
      ),
    );
  }
}
