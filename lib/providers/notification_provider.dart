import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';
import '../services/firebase_service.dart';

class NotificationProvider extends ChangeNotifier {
  List<AppNotification> _notifications = [];
  int _unreadCount = 0;
  StreamSubscription? _sub;

  List<AppNotification> get notifications => _notifications;
  int get unreadCount => _unreadCount;

  void subscribe(String uid) {
    _sub?.cancel();
    _sub = FirebaseService.notifications()
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      _notifications = snapshot.docs
          .map((doc) =>
              AppNotification.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
      _unreadCount = _notifications.where((n) => !n.read).length;
      notifyListeners();
    });
  }

  Future<void> markAsRead(String id) async {
    await FirebaseService.notifications().doc(id).update({'read': true});
  }

  Future<void> markAllAsRead() async {
    for (final n in _notifications) {
      if (!n.read) {
        await FirebaseService.notifications().doc(n.id).update({'read': true});
      }
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
