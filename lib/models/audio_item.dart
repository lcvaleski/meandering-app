class AudioItem {
  final String topic;
  final String subtopic;
  final String id;
  final String gender;

  AudioItem({required this.topic, required this.subtopic, required this.id, required this.gender});

  factory AudioItem.fromJson(Map<String, dynamic> json) {
    return AudioItem(
      topic: json['topic'],  // Assuming 'topic' represents the story
      subtopic: json['subtopic'],
      id: json['id'],
      gender: json['gender'],  // Ensure the JSON response includes this field
    );
  }
}
