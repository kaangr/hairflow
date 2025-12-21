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
  Future<void> saveAssessmentResults({
    required String hairType,
    required String hairLossStage,
    required String userGoal,
  });
  Future<bool> hasCompletedAssessment();
  Future<void> resetAssessment();
}

class UserPreferencesRepositoryImpl implements UserPreferencesRepository {
  late final SharedPreferences _sharedPreferences;
  bool _isInitialized = false;

  // Keys for new fields
  static const String _hasCompletedAssessmentKey = 'has_completed_assessment';
  static const String _hairTypeKey = 'hair_type';
  static const String _hairLossStageKey = 'hair_loss_stage';
  static const String _userGoalKey = 'user_goal_assessment';

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
    final hasCompletedAssessment = _sharedPreferences.getBool(
        _hasCompletedAssessmentKey) ?? false;
    final hairType = _sharedPreferences.getString(_hairTypeKey);
    final hairLossStage = _sharedPreferences.getString(_hairLossStageKey);
    final userGoal = _sharedPreferences.getString(_userGoalKey);

    return UserPreferences(
      goal: goal,
      notificationsEnabled: notificationsEnabled,
      reminderTime: reminderTime,
      isDarkMode: isDarkMode,
      isFirstLaunch: isFirstLaunch,
      hasCompletedAssessment: hasCompletedAssessment,
      hairType: hairType,
      hairLossStage: hairLossStage,
      userGoal: userGoal,
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
    await _sharedPreferences.setBool(
        _hasCompletedAssessmentKey, preferences.hasCompletedAssessment);
    if (preferences.hairType != null) {
      await _sharedPreferences.setString(_hairTypeKey, preferences.hairType!);
    }
    if (preferences.hairLossStage != null) {
      await _sharedPreferences.setString(_hairLossStageKey, preferences.hairLossStage!);
    }
    if (preferences.userGoal != null) {
      await _sharedPreferences.setString(_userGoalKey, preferences.userGoal!);
    }
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

  @override
  Future<void> saveAssessmentResults({
    required String hairType,
    required String hairLossStage,
    required String userGoal,
  }) async {
    await _ensureInitialized();
    await _sharedPreferences.setBool(_hasCompletedAssessmentKey, true);
    await _sharedPreferences.setString(_hairTypeKey, hairType);
    await _sharedPreferences.setString(_hairLossStageKey, hairLossStage);
    await _sharedPreferences.setString(_userGoalKey, userGoal);
  }

  @override
  Future<bool> hasCompletedAssessment() async {
    await _ensureInitialized();
    return _sharedPreferences.getBool(_hasCompletedAssessmentKey) ?? false;
  }

  @override
  Future<void> resetAssessment() async {
    await _ensureInitialized();
    await _sharedPreferences.setBool(_hasCompletedAssessmentKey, false);
    await _sharedPreferences.remove(_hairTypeKey);
    await _sharedPreferences.remove(_hairLossStageKey);
    await _sharedPreferences.remove(_userGoalKey);
  }
}
