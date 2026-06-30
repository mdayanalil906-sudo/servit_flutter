import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';

class BookingProvider extends ChangeNotifier {
  List<Booking> _userBookings = [];
  List<Booking> _expertBookings = [];
  bool _isLoading = false;
  String? _error;
  String _activeUserTab = 'pending';
  String _activeExpertTab = 'pending';

  List<Booking> get userBookings => _userBookings;
  List<Booking> get expertBookings => _expertBookings;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get activeUserTab => _activeUserTab;
  String get activeExpertTab => _activeExpertTab;

  List<Booking> get filteredUserBookings {
    if (_activeUserTab == 'all') return _userBookings;
    return _userBookings
        .where((b) => b.status == _activeUserTab)
        .toList();
  }

  List<Booking> get filteredExpertBookings {
    if (_activeExpertTab == 'all') return _expertBookings;
    return _expertBookings
        .where((b) => b.status == _activeExpertTab)
        .toList();
  }

  void setActiveUserTab(String tab) {
    _activeUserTab = tab;
    notifyListeners();
  }

  void setActiveExpertTab(String tab) {
    _activeExpertTab = tab;
    notifyListeners();
  }

  void subscribeUserBookings() {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) return;
    FirestoreService.getUserBookings(uid).listen((snapshot) {
      _userBookings = snapshot.docs
          .map((doc) =>
              Booking.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
      notifyListeners();
    });
  }

  void subscribeExpertBookings() {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) return;
    FirestoreService.getExpertBookings(uid).listen((snapshot) {
      _expertBookings = snapshot.docs
          .map((doc) =>
              Booking.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
      notifyListeners();
    });
  }

  Future<String?> createBooking(Map<String, dynamic> data) async {
    try {
      final id = await FirestoreService.createBooking(data);
      return id;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateStatus(
      String bookingId, String status, Map<String, dynamic>? extra) async {
    try {
      await FirestoreService.updateBookingStatus(bookingId, status, extra);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  int countByStatus(String status) {
    return _userBookings.where((b) => b.status == status).length;
  }

  int expertCountByStatus(String status) {
    return _expertBookings.where((b) => b.status == status).length;
  }
}
