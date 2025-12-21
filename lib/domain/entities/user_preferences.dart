import 'package:equatable/equatable.dart';

class UserPreferences extends Equatable {
  final String goal;
  final bool notificationsEnabled;
  final String reminderTime; // "HH:mm" format
  final bool isDarkMode;
  final bool isFirstLaunch;
  final bool hasCompletedAssessment; // Kullanıcı saç değerlendirmesini tamamladı mı?
  final String? hairType; // Kaydedilen saç tipi
  final String? hairLossStage; // Kaydedilen dökülme seviyesi
  final String? userGoal; // Kaydedilen kullanıcı hedefi

  const UserPreferences({
    required this.goal,
    this.notificationsEnabled = true,
    this.reminderTime = '09:00',
    this.isDarkMode = false,
    this.isFirstLaunch = true,
    this.hasCompletedAssessment = false,
    this.hairType,
    this.hairLossStage,
    this.userGoal,
  });

  UserPreferences copyWith({
    String? goal,
    bool? notificationsEnabled,
    String? reminderTime,
    bool? isDarkMode,
    bool? isFirstLaunch,
    bool? hasCompletedAssessment,
    String? hairType,
    String? hairLossStage,
    String? userGoal,
  }) {
    return UserPreferences(
      goal: goal ?? this.goal,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
      hasCompletedAssessment: hasCompletedAssessment ?? this.hasCompletedAssessment,
      hairType: hairType ?? this.hairType,
      hairLossStage: hairLossStage ?? this.hairLossStage,
      userGoal: userGoal ?? this.userGoal,
    );
  }

  @override
  List<Object?> get props => [
        goal,
        notificationsEnabled,
        reminderTime,
        isDarkMode,
        isFirstLaunch,
        hasCompletedAssessment,
        hairType,
        hairLossStage,
        userGoal,
      ];
}
