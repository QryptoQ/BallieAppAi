
class MessageModel {
  final String senderId;
  final String content;
  final String type;
  final DateTime timestamp;

  MessageModel({
    required this.senderId,
    required this.content,
    required this.type,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'content': content,
      'type': type,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      senderId: map['senderId'],
      content: map['content'],
      type: map['type'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
