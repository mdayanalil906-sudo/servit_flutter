import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../config/firebase_config.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  static FirebaseAuth get auth => _auth;
  static FirebaseFirestore get firestore => _firestore;
  static FirebaseStorage get storage => _storage;

  static User? get currentUser => _auth.currentUser;

  static CollectionReference users() => _firestore.collection('users');
  static CollectionReference experts() => _firestore.collection('experts');
  static CollectionReference bookings() => _firestore.collection('bookings');
  static CollectionReference categories() =>
      _firestore.collection('categories');
  static CollectionReference notifications() =>
      _firestore.collection('notifications');
  static CollectionReference ratings() => _firestore.collection('ratings');
  static CollectionReference payments() => _firestore.collection('payments');
  static CollectionReference chatRooms() =>
      _firestore.collection('chat_rooms');
  static CollectionReference chatMessages() =>
      _firestore.collection('chat_messages');
  static CollectionReference supportChats() =>
      _firestore.collection('support_chats');
  static CollectionReference supportMessages() =>
      _firestore.collection('support_messages');
  static CollectionReference tickets() => _firestore.collection('tickets');
  static CollectionReference states() => _firestore.collection('states');

  static Reference storageRef(String path) => _storage.ref(path);

  static Future<void> setDocument(
      String collection, String docId, Map<String, dynamic> data) async {
    await _firestore.collection(collection).doc(docId).set(data, SetOptions(merge: true));
  }

  static Future<Map<String, dynamic>?> getDocument(
      String collection, String docId) async {
    final doc = await _firestore.collection(collection).doc(docId).get();
    return doc.exists ? doc.data() : null;
  }

  static Future<List<Map<String, dynamic>>> getCollection(
      String collection) async {
    final snap = await _firestore.collection(collection).get();
    return snap.docs.map((d) => d.data()).toList();
  }

  static Future<String> addDocument(
      String collection, Map<String, dynamic> data) async {
    final doc = await _firestore.collection(collection).add(data);
    return doc.id;
  }

  static Future<void> deleteDocument(String collection, String docId) async {
    await _firestore.collection(collection).doc(docId).delete();
  }

  static Stream<QuerySnapshot> streamCollection(String collection,
      {String? orderBy, bool descending = true, int? limit}) {
    Query query = _firestore.collection(collection);
    if (orderBy != null) query = query.orderBy(orderBy, descending: descending);
    if (limit != null) query = query.limit(limit);
    return query.snapshots();
  }
}
