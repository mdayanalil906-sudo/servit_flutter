import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';

class FirestoreService {
  static Future<String> createUserProfile(
      Map<String, dynamic> data) async {
    final uid = FirebaseService.currentUser?.uid;
    if (uid == null) throw Exception('Not authenticated');
    data['uid'] = uid;
    data['role'] = 'user';
    data['createdAt'] = DateTime.now().toIso8601String();
    data['updatedAt'] = DateTime.now().toIso8601String();
    await FirebaseService.users().doc(uid).set(data, SetOptions(merge: true));
    return uid;
  }

  static Future<String> createExpertProfile(
      Map<String, dynamic> data) async {
    final uid = FirebaseService.currentUser?.uid;
    if (uid == null) throw Exception('Not authenticated');
    data['uid'] = uid;
    data['role'] = 'expert';
    data['createdAt'] = DateTime.now().toIso8601String();
    data['updatedAt'] = DateTime.now().toIso8601String();
    await FirebaseService.experts().doc(uid).set(data, SetOptions(merge: true));
    return uid;
  }

  static Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final doc = await FirebaseService.users().doc(uid).get();
    return doc.exists ? doc.data() : null;
  }

  static Future<Map<String, dynamic>?> getExpertProfile(String uid) async {
    final doc = await FirebaseService.experts().doc(uid).get();
    return doc.exists ? doc.data() : null;
  }

  static Future<void> updateUserProfile(
      String uid, Map<String, dynamic> data) async {
    data['updatedAt'] = DateTime.now().toIso8601String();
    await FirebaseService.users().doc(uid).update(data);
  }

  static Future<void> updateExpertProfile(
      String uid, Map<String, dynamic> data) async {
    data['updatedAt'] = DateTime.now().toIso8601String();
    await FirebaseService.experts().doc(uid).update(data);
  }

  static Future<String> createBooking(Map<String, dynamic> data) async {
    data['createdAt'] = DateTime.now().toIso8601String();
    data['updatedAt'] = DateTime.now().toIso8601String();
    final doc = await FirebaseService.bookings().add(data);
    await doc.update({'bookingId': doc.id});
    return doc.id;
  }

  static Stream<QuerySnapshot> getUserBookings(String userId) {
    return FirebaseService.bookings()
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  static Stream<QuerySnapshot> getExpertBookings(String expertUid) {
    return FirebaseService.bookings()
        .where('expertUid', isEqualTo: expertUid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  static Future<void> updateBookingStatus(
      String bookingId, String status, Map<String, dynamic>? extra) async {
    final data = <String, dynamic>{
      'status': status,
      'updatedAt': DateTime.now().toIso8601String(),
    };
    if (extra != null) data.addAll(extra);
    await FirebaseService.bookings().doc(bookingId).update(data);
  }

  static Future<List<Map<String, dynamic>>> searchExperts({
    String? category,
    String? state,
    String? district,
    bool? verified,
    bool? premium,
    double? priceMin,
    double? priceMax,
    String? query,
  }) async {
    Query q = FirebaseService.experts();
    if (category != null && category.isNotEmpty) {
      q = q.where('category', isEqualTo: category);
    }
    final snap = await q.get();
    var experts = snap.docs.map((d) => d.data()).toList();

    if (state != null && state.isNotEmpty) {
      experts = experts
          .where((e) =>
              (e['state'] ?? '').toString().toLowerCase() ==
              state.toLowerCase())
          .toList();
    }
    if (district != null && district.isNotEmpty) {
      experts = experts
          .where((e) =>
              (e['district'] ?? e['city'] ?? '')
                  .toString()
                  .toLowerCase() ==
              district.toLowerCase())
          .toList();
    }
    if (verified == true) {
      experts = experts.where((e) => e['isVerified'] == true).toList();
    }
    if (premium == true) {
      experts = experts.where((e) => e['isExpertPremium'] == true).toList();
    }
    if (priceMin != null) {
      experts = experts
          .where((e) => (e['priceMin'] ?? 0).toDouble() >= priceMin)
          .toList();
    }
    if (priceMax != null) {
      experts = experts
          .where((e) => (e['priceMax'] ?? 0).toDouble() <= priceMax)
          .toList();
    }
    if (query != null && query.isNotEmpty) {
      final ql = query.toLowerCase();
      experts = experts
          .where((e) =>
              (e['name'] ?? '').toString().toLowerCase().contains(ql) ||
              (e['category'] ?? '').toString().toLowerCase().contains(ql))
          .toList();
    }

    experts.sort((a, b) {
      final aV = a['isVerified'] == true ? 1 : 0;
      final bV = b['isVerified'] == true ? 1 : 0;
      if (aV != bV) return bV.compareTo(aV);
      final aP = a['isExpertPremium'] == true ? 1 : 0;
      final bP = b['isExpertPremium'] == true ? 1 : 0;
      if (aP != bP) return bP.compareTo(aP);
      final aR = (a['rating'] ?? 0).toDouble();
      final bR = (b['rating'] ?? 0).toDouble();
      if (aR != bR) return bR.compareTo(aR);
      return (b['jobs'] ?? 0).compareTo(a['jobs'] ?? 0);
    });

    return experts;
  }

  static Stream<QuerySnapshot> getCategories() {
    return FirebaseService.categories().snapshots();
  }

  static String generateChatRoomId(String uid1, String uid2) {
    final ids = [uid1, uid2]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  static Future<void> sendNotification({
    required String userId,
    required String title,
    required String body,
    String icon = '',
  }) async {
    final data = {
      'title': title,
      'body': body,
      'icon': icon,
      'read': false,
      'createdAt': DateTime.now().toIso8601String(),
    };
    await FirebaseService.notifications().add(data);
  }

  static Future<List<Map<String, dynamic>>> loadStates() async {
    final snap = await FirebaseService.states().get();
    return snap.docs.map((d) => d.data()).toList();
  }
}
