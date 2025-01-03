class AudioItem {
  final String topic;
  final String subtopic;
  final String url;

  AudioItem({required this.topic, required this.subtopic, required this.url});

  factory AudioItem.fromJson(Map<String, dynamic> json) {
    return AudioItem(
      topic: json['topic'],
      subtopic: json['subtopic'],
      url: json['url'],
    );
  }
}