class AudioItem {
  final String topic;
  final String subtopic;
  final String id;

  AudioItem({required this.topic, required this.subtopic, required this.id});

  factory AudioItem.fromJson(Map<String, dynamic> json) {
    return AudioItem(
      topic: json['topic'],
      subtopic: json['subtopic'],
      id: json['id'],
    );
  }
}