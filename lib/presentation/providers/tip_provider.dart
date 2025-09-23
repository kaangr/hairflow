import 'package:flutter/material.dart';
import '../../domain/entities/tip.dart';
import '../../data/repositories/tip_repository_impl.dart';

class TipProvider with ChangeNotifier {
  final TipRepository _repository;
  
  List<Tip> _tips = [];
  List<Tip> _favoriteTips = [];
  Tip? _dailyTip;
  bool _isLoading = false;
  String? _error;

  TipProvider(this._repository) {
    loadTips();
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
      _tips = await _repository.getTips();
      _favoriteTips = await _repository.getFavoriteTips();
      _dailyTip = await _repository.getRandomTip();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
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
