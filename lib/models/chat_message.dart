class ChatMessage {
  final String id;
  final String roomId;
  final String senderId;
  final String senderRole;
  final String senderName;
  final String text;
  final String imageUrl;
  final bool read;
  final String type;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.senderRole,
    required this.senderName,
    this.text = '',
    this.imageUrl = '',
    this.read = false,
    this.type = 'text',
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory ChatMessage.fromMap(Map<String, dynamic> map, String id) {
    return ChatMessage(
      id: id,
      roomId: map['roomId'] ?? '',
      senderId: map['senderId'] ?? '',
      senderRole: map['senderRole'] ?? '',
      senderName: map['senderName'] ?? '',
      text: map['text'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      read: map['read'] ?? false,
      type: map['type'] ?? 'text',
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'roomId': roomId,
      'senderId': senderId,
      'senderRole': senderRole,
      'senderName': senderName,
      'text': text,
      'imageUrl': imageUrl,
      'read': read,
      'type': type,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  bool get isMine => senderRole == 'user' || senderRole == 'expert';
}
