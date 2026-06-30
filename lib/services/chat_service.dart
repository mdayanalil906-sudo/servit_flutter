import 'firebase_service.dart';

class ChatService {
  static Future<String> createChatRoom(
      String bookingId, Map<String, dynamic> roomData) async {
    roomData['createdAt'] = DateTime.now().toIso8601String();
    final doc = await FirebaseService.chatRooms().add(roomData);
    return doc.id;
  }

  static Future<void> sendMessage(
      String roomId, Map<String, dynamic> msgData) async {
    msgData['timestamp'] = DateTime.now().toIso8601String();
    await FirebaseService.chatMessages().add(msgData);
    await FirebaseService.chatRooms().doc(roomId).update({
      'lastMessage': msgData['text'] ?? '',
      'lastSender': msgData['senderId'] ?? '',
      'lastTimestamp': DateTime.now().toIso8601String(),
    });
  }

  static Stream<QuerySnapshot> getMessages(String roomId) {
    return FirebaseService.chatMessages()
        .where('roomId', isEqualTo: roomId)
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  static Stream<QuerySnapshot> getUserChatRooms(String userId) {
    return FirebaseService.chatRooms()
        .where('userId', isEqualTo: userId)
        .orderBy('lastTimestamp', descending: true)
        .snapshots();
  }

  static Stream<QuerySnapshot> getExpertChatRooms(String expertId) {
    return FirebaseService.chatRooms()
        .where('expertId', isEqualTo: expertId)
        .orderBy('lastTimestamp', descending: true)
        .snapshots();
  }

  static Future<void> updateTypingStatus(
      String roomId, String userId, bool isTyping) async {
    await FirebaseService.chatRooms().doc(roomId).update({
      'typingUserId': isTyping ? userId : '',
      'typingTimestamp':
          isTyping ? DateTime.now().toIso8601String() : null,
    });
  }

  static Future<void> markRoomRead(
      String roomId, String userId, String role) async {
    final field = role == 'user' ? 'userUnreadCount' : 'expertUnreadCount';
    await FirebaseService.chatRooms().doc(roomId).update({field: 0});
  }

  static Future<void> createSupportChat(
      String chatId, Map<String, dynamic> data) async {
    data['createdAt'] = DateTime.now().toIso8601String();
    await FirebaseService.supportChats().doc(chatId).set(data);
  }

  static Future<void> sendSupportMessage(
      String chatId, Map<String, dynamic> msgData) async {
    msgData['timestamp'] = DateTime.now().toIso8601String();
    await FirebaseService.supportMessages().add(msgData);
  }

  static Stream<QuerySnapshot> getSupportMessages(String chatId) {
    return FirebaseService.supportMessages()
        .where('chatId', isEqualTo: chatId)
        .orderBy('timestamp', descending: false)
        .snapshots();
  }
}
