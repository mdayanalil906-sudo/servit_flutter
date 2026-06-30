class ChatRoom {
  final String id;
  final String bookingId;
  final String userId;
  final String expertId;
  final String userName;
  final String expertName;
  final String category;
  final String status;
  final String lastMessage;
  final String lastSender;
  final DateTime? lastTimestamp;
  final int userUnreadCount;
  final int expertUnreadCount;
  final String typingUserId;
  final DateTime? typingTimestamp;

  ChatRoom({
    required this.id,
    required this.bookingId,
    required this.userId,
    required this.expertId,
    required this.userName,
    required this.expertName,
    this.category = '',
    this.status = 'active',
    this.lastMessage = '',
    this.lastSender = '',
    this.lastTimestamp,
    this.userUnreadCount = 0,
    this.expertUnreadCount = 0,
    this.typingUserId = '',
    this.typingTimestamp,
  });

  factory ChatRoom.fromMap(Map<String, dynamic> map, String id) {
    return ChatRoom(
      id: id,
      bookingId: map['bookingId'] ?? '',
      userId: map['userId'] ?? '',
      expertId: map['expertId'] ?? '',
      userName: map['userName'] ?? '',
      expertName: map['expertName'] ?? '',
      category: map['category'] ?? '',
      status: map['status'] ?? 'active',
      lastMessage: map['lastMessage'] ?? '',
      lastSender: map['lastSender'] ?? '',
      lastTimestamp: map['lastTimestamp'] != null
          ? DateTime.tryParse(map['lastTimestamp'])
          : null,
      userUnreadCount: map['userUnreadCount'] ?? 0,
      expertUnreadCount: map['expertUnreadCount'] ?? 0,
      typingUserId: map['typingUserId'] ?? '',
      typingTimestamp: map['typingTimestamp'] != null
          ? DateTime.tryParse(map['typingTimestamp'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bookingId': bookingId,
      'userId': userId,
      'expertId': expertId,
      'userName': userName,
      'expertName': expertName,
      'category': category,
      'status': status,
      'lastMessage': lastMessage,
      'lastSender': lastSender,
      'lastTimestamp': lastTimestamp?.toIso8601String(),
      'userUnreadCount': userUnreadCount,
      'expertUnreadCount': expertUnreadCount,
      'typingUserId': typingUserId,
      'typingTimestamp': typingTimestamp?.toIso8601String(),
    };
  }
}
