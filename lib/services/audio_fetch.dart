import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/audio_item.dart';

Future<Map<String, Map<String, List<AudioItem>>>> fetchAudioList() async {
  final response = await http.get(Uri.parse('https://storage.googleapis.com/active-audio/audio_metadata.json'));

  if (response.statusCode == 200) {
    final List<dynamic> jsonData = json.decode(response.body)['audios'];
    final List<AudioItem> audioItems = jsonData.map((item) => AudioItem.fromJson(item)).toList();

    // Categorize audio items
    final Map<String, Map<String, List<AudioItem>>> categorizedAudios = {};

    for (var item in audioItems) {
      if (!categorizedAudios.containsKey(item.topic)) {
        categorizedAudios[item.topic] = {};
      }
      if (!categorizedAudios[item.topic]!.containsKey(item.subtopic)) {
        categorizedAudios[item.topic]![item.subtopic] = [];
      }
      categorizedAudios[item.topic]![item.subtopic]!.add(item);
    }

    return categorizedAudios;
  } else {
    throw Exception('Failed to load audio list');
  }
}