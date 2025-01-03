import 'package:flutter/material.dart';
import '../models/audio_item.dart';
import '../services/audio_fetch.dart';

class AudioListScreen extends StatefulWidget {
  @override
  _AudioListScreenState createState() => _AudioListScreenState();
}

class _AudioListScreenState extends State<AudioListScreen> {
  late Future<Map<String, Map<String, List<AudioItem>>>> futureAudioList;

  @override
  void initState() {
    super.initState();
    futureAudioList = fetchAudioList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Audio List')),
      body: FutureBuilder<Map<String, Map<String, List<AudioItem>>>>(
        future: futureAudioList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final categorizedAudios = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                children: categorizedAudios.entries.map((topicEntry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          topicEntry.key, // Topic name
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                      ...topicEntry.value.entries.map((subtopicEntry) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 16.0, top: 4.0),
                              child: Text(
                                subtopicEntry.key, // Subtopic name
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
                              ),
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(), // Prevent scrolling of inner list
                              itemCount: subtopicEntry.value.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  title: Text(subtopicEntry.value[index].subtopic),
                                  // Remove the play button for now
                                );
                              },
                            ),
                          ],
                        );
                      }).toList(),
                    ],
                  );
                }).toList(),
              ),
            );
          }
        },
      ),
    );
  }
}