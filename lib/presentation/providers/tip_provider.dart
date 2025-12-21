import 'package:flutter/material.dart';
import '../../domain/entities/tip.dart';
import '../../data/repositories/tip_repository_impl.dart';
import '../../data/repositories/firebase_repository.dart';

class TipProvider with ChangeNotifier {
  final TipRepository _repository;
  final FirebaseRepository _firebaseRepository = FirebaseRepository();
  
  List<Tip> _tips = [];
  List<Tip> _favoriteTips = [];
  Tip? _dailyTip;
  bool _isLoading = false;
  String? _error;
  
  // Ürün listesi (Firebase'den)
  List<Map<String, dynamic>> _products = [];
  
  List<Map<String, dynamic>> get products => _products;

  TipProvider(this._repository) {
    loadTips();
    _loadProductsFromFirebase();
  }
  
  Future<void> _loadProductsFromFirebase() async {
    try {
      final loadedProducts = await _firebaseRepository.getProducts();
      _products = loadedProducts;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load products from Firebase: $e');
      // Firebase erişimi yoksa boş liste olarak bırak
      _products = [];
    }
  }
  
  /// Ürünleri yeniden yükle
  Future<void> reloadProducts() async {
    await _loadProductsFromFirebase();
  }
  
  List<Map<String, dynamic>> getProductsByCategory(String category) {
    return _products.where((p) => p['category'] == category).toList();
  }

  List<Tip> get tips => _tips;
  List<Tip> get favoriteTips => _favoriteTips;
  Tip? get dailyTip => _dailyTip;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Tip> getTipsByCategory(TipCategory category) {
    return _tips.where((tip) => tip.category == category).toList();
  }

  Future<void> loadTips() async {
    _setLoading(true);
    try {
      // Önce local'den yükle
      _tips = await _repository.getTips();
      _favoriteTips = await _repository.getFavoriteTips();
      _dailyTip = await _repository.getRandomTip();
      
      // Firebase'den de yüklemeyi dene
      await _loadFromFirebaseIfAvailable();
      
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }
  
  Future<void> _loadFromFirebaseIfAvailable() async {
    try {
      final firebaseTips = await _firebaseRepository.getTips();
      if (firebaseTips.isNotEmpty) {
        // Firebase'den gelen tipleri local listeye ekle (duplicate kontrolü ile)
        for (final firebaseTip in firebaseTips) {
          final existingIndex = _tips.indexWhere((t) => t.title == firebaseTip.title);
          if (existingIndex == -1) {
            _tips.add(firebaseTip);
          }
        }
        
        // Eğer local tip yoksa ve Firebase'den geldiyse, dailyTip'i güncelle
        if (_dailyTip == null && _tips.isNotEmpty) {
          _dailyTip = _tips[DateTime.now().millisecond % _tips.length];
        }
      }
    } catch (e) {
      // Firebase yüklenmediyse sessizce devam et
      debugPrint('Firebase tips loading failed: $e');
    }
  }

  Future<void> toggleTipFavorite(int tipId, bool isFavorite) async {
    try {
      await _repository.toggleTipFavorite(tipId, isFavorite);
      
      // Update local state
      final tipIndex = _tips.indexWhere((tip) => tip.id == tipId);
      if (tipIndex != -1) {
        _tips[tipIndex] = _tips[tipIndex].copyWith(isFavorite: isFavorite);
      }

      // Update favorites list
      _favoriteTips = await _repository.getFavoriteTips();
      
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> refreshDailyTip() async {
    try {
      _dailyTip = await _repository.getRandomTip();
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
