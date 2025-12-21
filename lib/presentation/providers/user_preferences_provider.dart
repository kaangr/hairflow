import 'package:flutter/material.dart';
import '../../domain/entities/user_preferences.dart';
import '../../data/repositories/user_preferences_repository_impl.dart';

class UserPreferencesProvider with ChangeNotifier {
  final UserPreferencesRepository _repository;
  
  UserPreferences _preferences = const UserPreferences(goal: '');
  bool _isLoading = false;
  String? _error;

  UserPreferencesProvider(this._repository) {
    loadPreferences();
  }

  UserPreferences get preferences => _preferences;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isFirstLaunch => _preferences.isFirstLaunch;
  bool get hasCompletedAssessment => _preferences.hasCompletedAssessment;

  Future<void> loadPreferences() async {
    _setLoading(true);
    try {
      _preferences = await _repository.getUserPreferences();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  Future<void> updateGoal(String goal) async {
    try {
      await _repository.updateGoal(goal);
      _preferences = _preferences.copyWith(goal: goal);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateNotificationSettings(bool enabled, String reminderTime) async {
    try {
      await _repository.updateNotificationSettings(enabled, reminderTime);
      _preferences = _preferences.copyWith(
        notificationsEnabled: enabled,
        reminderTime: reminderTime,
      );
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateTheme(bool isDarkMode) async {
    try {
      await _repository.updateTheme(isDarkMode);
      _preferences = _preferences.copyWith(isDarkMode: isDarkMode);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> completeOnboarding() async {
    try {
      await _repository.setFirstLaunchCompleted();
      _preferences = _preferences.copyWith(isFirstLaunch: false);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Assessment sonuçlarını kaydet
  Future<void> saveAssessmentResults({
    required String hairType,
    required String hairLossStage,
    required String userGoal,
  }) async {
    try {
      await _repository.saveAssessmentResults(
        hairType: hairType,
        hairLossStage: hairLossStage,
        userGoal: userGoal,
      );
      _preferences = _preferences.copyWith(
        hasCompletedAssessment: true,
        hairType: hairType,
        hairLossStage: hairLossStage,
        userGoal: userGoal,
      );
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

  /// Değerlendirmeyi sıfırla
  Future<void> resetAssessment() async {
    try {
      await _repository.resetAssessment();
      _preferences = _preferences.copyWith(
        hasCompletedAssessment: false,
        hairType: '',
        hairLossStage: '',
        userGoal: '',
      );
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
