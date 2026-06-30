class SupportChat {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String status;
  final String source;
  final DateTime createdAt;

  SupportChat({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    this.status = 'open',
    this.source = 'user',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory SupportChat.fromMap(Map<String, dynamic> map, String id) {
    return SupportChat(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userEmail: map['userEmail'] ?? '',
      status: map['status'] ?? 'open',
      source: map['source'] ?? 'user',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'status': status,
      'source': source,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class SupportMessage {
  final String id;
  final String chatId;
  final String text;
  final String senderId;
  final String senderRole;
  final String senderName;
  final bool escalated;
  final String source;
  final DateTime timestamp;

  SupportMessage({
    required this.id,
    required this.chatId,
    this.text = '',
    required this.senderId,
    required this.senderRole,
    this.senderName = '',
    this.escalated = false,
    this.source = '',
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory SupportMessage.fromMap(Map<String, dynamic> map, String id) {
    return SupportMessage(
      id: id,
      chatId: map['chatId'] ?? '',
      text: map['text'] ?? '',
      senderId: map['senderId'] ?? '',
      senderRole: map['senderRole'] ?? '',
      senderName: map['senderName'] ?? '',
      escalated: map['escalated'] ?? false,
      source: map['source'] ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'chatId': chatId,
      'text': text,
      'senderId': senderId,
      'senderRole': senderRole,
      'senderName': senderName,
      'escalated': escalated,
      'source': source,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
