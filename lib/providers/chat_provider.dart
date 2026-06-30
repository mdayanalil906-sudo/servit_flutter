import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_message.dart';
import '../models/chat_room.dart';
import '../services/chat_service.dart';

class ChatProvider extends ChangeNotifier {
  List<ChatMessage> _messages = [];
  List<ChatRoom> _rooms = [];
  bool _isLoading = false;
  String? _error;

  List<ChatMessage> get messages => _messages;
  List<ChatRoom> get rooms => _rooms;
  bool get isLoading => _isLoading;
  String? get error => _error;

  StreamSubscription? _messagesSub;
  StreamSubscription? _roomsSub;

  void subscribeMessages(String roomId) {
    _messagesSub?.cancel();
    _messagesSub = ChatService.getMessages(roomId).listen((snapshot) {
      _messages = snapshot.docs
          .map((doc) =>
              ChatMessage.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
      notifyListeners();
    });
  }

  void subscribeUserRooms(String userId) {
    _roomsSub?.cancel();
    _roomsSub = ChatService.getUserChatRooms(userId).listen((snapshot) {
      _rooms = snapshot.docs
          .map((doc) =>
              ChatRoom.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
      notifyListeners();
    });
  }

  void subscribeExpertRooms(String expertId) {
    _roomsSub?.cancel();
    _roomsSub = ChatService.getExpertChatRooms(expertId).listen((snapshot) {
      _rooms = snapshot.docs
          .map((doc) =>
              ChatRoom.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
      notifyListeners();
    });
  }

  Future<bool> sendMessage(String roomId, Map<String, dynamic> msgData) async {
    try {
      await ChatService.sendMessage(roomId, msgData);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> updateTypingStatus(
      String roomId, String userId, bool isTyping) async {
    await ChatService.updateTypingStatus(roomId, userId, isTyping);
  }

  Future<void> markRoomRead(String roomId, String userId, String role) async {
    await ChatService.markRoomRead(roomId, userId, role);
  }

  @override
  void dispose() {
    _messagesSub?.cancel();
    _roomsSub?.cancel();
    super.dispose();
  }
}
