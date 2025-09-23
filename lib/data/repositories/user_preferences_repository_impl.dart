import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user_preferences.dart';
import '../../core/constants/app_constants.dart';

abstract class UserPreferencesRepository {
  Future<UserPreferences> getUserPreferences();
  Future<void> saveUserPreferences(UserPreferences preferences);
  Future<void> updateGoal(String goal);
  Future<void> updateNotificationSettings(bool enabled, String reminderTime);
  Future<void> updateTheme(bool isDarkMode);
  Future<void> setFirstLaunchCompleted();
  Future<bool> isFirstLaunch();
}

class UserPreferencesRepositoryImpl implements UserPreferencesRepository {
  late final SharedPreferences _sharedPreferences;
  bool _isInitialized = false;

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      _sharedPreferences = await SharedPreferences.getInstance();
      _isInitialized = true;
    }
  }

  @override
  Future<UserPreferences> getUserPreferences() async {
    await _ensureInitialized();
    
    final goal = _sharedPreferences.getString(AppConstants.userGoalKey) ?? 
        AppConstants.hairGoals.first;
    final notificationsEnabled = _sharedPreferences.getBool(
        AppConstants.notificationsEnabledKey) ?? true;
    final reminderTime = _sharedPreferences.getString(
        AppConstants.reminderTimeKey) ?? '09:00';
    final isDarkMode = _sharedPreferences.getBool(
        AppConstants.themeKey) ?? false;
    final isFirstLaunch = _sharedPreferences.getBool(
        AppConstants.isFirstLaunchKey) ?? true;

    return UserPreferences(
      goal: goal,
      notificationsEnabled: notificationsEnabled,
      reminderTime: reminderTime,
      isDarkMode: isDarkMode,
      isFirstLaunch: isFirstLaunch,
    );
  }

  @override
  Future<void> saveUserPreferences(UserPreferences preferences) async {
    await _ensureInitialized();
    
    await _sharedPreferences.setString(
        AppConstants.userGoalKey, preferences.goal);
    await _sharedPreferences.setBool(
        AppConstants.notificationsEnabledKey, preferences.notificationsEnabled);
    await _sharedPreferences.setString(
        AppConstants.reminderTimeKey, preferences.reminderTime);
    await _sharedPreferences.setBool(
        AppConstants.themeKey, preferences.isDarkMode);
    await _sharedPreferences.setBool(
        AppConstants.isFirstLaunchKey, preferences.isFirstLaunch);
  }

  @override
  Future<void> updateGoal(String goal) async {
    await _ensureInitialized();
    await _sharedPreferences.setString(AppConstants.userGoalKey, goal);
  }

  @override
  Future<void> updateNotificationSettings(bool enabled, String reminderTime) async {
    await _ensureInitialized();
    await _sharedPreferences.setBool(AppConstants.notificationsEnabledKey, enabled);
    await _sharedPreferences.setString(AppConstants.reminderTimeKey, reminderTime);
  }

  @override
  Future<void> updateTheme(bool isDarkMode) async {
    await _ensureInitialized();
    await _sharedPreferences.setBool(AppConstants.themeKey, isDarkMode);
  }

  @override
  Future<void> setFirstLaunchCompleted() async {
    await _ensureInitialized();
    await _sharedPreferences.setBool(AppConstants.isFirstLaunchKey, false);
  }

  @override
  Future<bool> isFirstLaunch() async {
    await _ensureInitialized();
    return _sharedPreferences.getBool(AppConstants.isFirstLaunchKey) ?? true;
  }
}
