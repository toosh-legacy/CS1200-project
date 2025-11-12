class Message {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  String? feedback; // 'support', 'dont_support', or null

  Message({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.feedback,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'feedback': feedback,
    };
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      text: json['text'],
      isUser: json['isUser'],
      timestamp: DateTime.parse(json['timestamp']),
      feedback: json['feedback'],
    );
  }
}
