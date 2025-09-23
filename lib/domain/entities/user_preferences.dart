import 'package:equatable/equatable.dart';

class UserPreferences extends Equatable {
  final String goal;
  final bool notificationsEnabled;
  final String reminderTime; // "HH:mm" format
  final bool isDarkMode;
  final bool isFirstLaunch;

  const UserPreferences({
    required this.goal,
    this.notificationsEnabled = true,
    this.reminderTime = '09:00',
    this.isDarkMode = false,
    this.isFirstLaunch = true,
  });

  UserPreferences copyWith({
    String? goal,
    bool? notificationsEnabled,
    String? reminderTime,
    bool? isDarkMode,
    bool? isFirstLaunch,
  }) {
    return UserPreferences(
      goal: goal ?? this.goal,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
    );
  }

  @override
  List<Object?> get props => [
        goal,
        notificationsEnabled,
        reminderTime,
        isDarkMode,
        isFirstLaunch,
      ];
}
