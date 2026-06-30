import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/user.dart';
import '../models/expert.dart';

class AuthProvider extends ChangeNotifier {
  UserProfile? _userProfile;
  ExpertProfile? _expertProfile;
  String _role = '';
  bool _isLoggedIn = false;
  bool _isInitialized = false;
  bool _isLoading = false;
  String? _error;

  UserProfile? get userProfile => _userProfile;
  ExpertProfile? get expertProfile => _expertProfile;
  String get role => _role;
  bool get isLoggedIn => _isLoggedIn;
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isUser => _role == 'user';
  bool get isExpert => _role == 'expert';

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    AuthService.authStateChanges.listen((User? user) async {
      if (user != null) {
        await _restoreSession();
      } else {
        _userProfile = null;
        _expertProfile = null;
        _isLoggedIn = false;
        _isInitialized = true;
        notifyListeners();
      }
    });
    await _restoreSession();
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final storedRole = prefs.getString('role') ?? '';
    final email = prefs.getString('email') ?? '';
    if (storedRole.isEmpty || email.isEmpty || AuthService.currentUser == null) {
      _isLoggedIn = false;
      _isInitialized = true;
      notifyListeners();
      return;
    }
    _role = storedRole;
    if (_role == 'expert') {
      await loadExpertProfile();
    } else {
      await loadUserProfile();
    }
  }

  Future<void> _saveSession(String role, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('role', role);
    await prefs.setString('email', email);
  }

  Future<void> loadUserProfile() async {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) return;
    final data = await FirestoreService.getUserProfile(uid);
    if (data != null) {
      _userProfile = UserProfile.fromMap(data, uid);
      _role = 'user';
      _isLoggedIn = true;
      notifyListeners();
    }
  }

  Future<void> loadExpertProfile() async {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) return;
    final data = await FirestoreService.getExpertProfile(uid);
    if (data != null) {
      _expertProfile = ExpertProfile.fromMap(data, uid);
      _role = 'expert';
      _isLoggedIn = true;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password, String role) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await AuthService.loginWithEmail(email, password);
      _role = role;
      if (role == 'expert') {
        await loadExpertProfile();
      } else {
        await loadUserProfile();
      }
      _isLoggedIn = true;
      await _saveSession(role, email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(
    String email,
    String password,
    String role,
    Map<String, dynamic> profileData,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await AuthService.registerWithEmail(email, password);
      _role = role;
      if (role == 'expert') {
        await FirestoreService.createExpertProfile(profileData);
        await loadExpertProfile();
      } else {
        await FirestoreService.createUserProfile(profileData);
        await loadUserProfile();
      }
      _isLoggedIn = true;
      await _saveSession(role, email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await AuthService.logout();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('role');
    await prefs.remove('email');
    _userProfile = null;
    _expertProfile = null;
    _isLoggedIn = false;
    _role = '';
    _isInitialized = true;
    notifyListeners();
  }

  Future<bool> resetPassword(String email) async {
    try {
      await AuthService.sendPasswordReset(email);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void updateUserProfile(UserProfile profile) {
    _userProfile = profile;
    notifyListeners();
  }

  void updateExpertProfile(ExpertProfile profile) {
    _expertProfile = profile;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
