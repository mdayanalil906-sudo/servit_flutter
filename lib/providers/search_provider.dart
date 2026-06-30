import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category.dart';
import '../models/expert.dart';
import '../services/firestore_service.dart';

class SearchProvider extends ChangeNotifier {
  List<Category> _categories = [];
  List<ExpertProfile> _searchResults = [];
  bool _isLoading = false;
  String? _error;
  String _query = '';
  String? _selectedCategory;
  String? _selectedState;
  String? _selectedDistrict;
  bool _verifiedOnly = false;
  bool _premiumOnly = false;
  double? _priceMin;
  double? _priceMax;

  List<Category> get categories => _categories;
  List<ExpertProfile> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get query => _query;
  String? get selectedCategory => _selectedCategory;
  String? get selectedState => _selectedState;
  String? get selectedDistrict => _selectedDistrict;
  bool get verifiedOnly => _verifiedOnly;
  bool get premiumOnly => _premiumOnly;
  double? get priceMin => _priceMin;
  double? get priceMax => _priceMax;

  StreamSubscription? _catSub;

  SearchProvider() {
    _subscribeCategories();
  }

  void _subscribeCategories() {
    _catSub = FirestoreService.getCategories().listen((snapshot) {
      _categories = snapshot.docs
          .map((doc) =>
              Category.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
      notifyListeners();
    });
  }

  void setQuery(String q) {
    _query = q;
    notifyListeners();
  }

  void setCategory(String? cat) {
    _selectedCategory = cat;
    notifyListeners();
  }

  void setState(String? state) {
    _selectedState = state;
    notifyListeners();
  }

  void setDistrict(String? district) {
    _selectedDistrict = district;
    notifyListeners();
  }

  void setVerifiedOnly(bool v) {
    _verifiedOnly = v;
    notifyListeners();
  }

  void setPremiumOnly(bool v) {
    _premiumOnly = v;
    notifyListeners();
  }

  void setPriceRange(double? min, double? max) {
    _priceMin = min;
    _priceMax = max;
    notifyListeners();
  }

  void clearFilters() {
    _query = '';
    _selectedCategory = null;
    _selectedState = null;
    _selectedDistrict = null;
    _verifiedOnly = false;
    _premiumOnly = false;
    _priceMin = null;
    _priceMax = null;
    notifyListeners();
  }

  Future<void> search() async {
    _isLoading = true;
    notifyListeners();
    try {
      final results = await FirestoreService.searchExperts(
        category: _selectedCategory,
        state: _selectedState,
        district: _selectedDistrict,
        verified: _verifiedOnly,
        premium: _premiumOnly,
        priceMin: _priceMin,
        priceMax: _priceMax,
        query: _query.isNotEmpty ? _query : null,
      );
      _searchResults = results
          .map((m) => ExpertProfile.fromMap(m, m['uid'] ?? ''))
          .toList();
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _catSub?.cancel();
    super.dispose();
  }
}
