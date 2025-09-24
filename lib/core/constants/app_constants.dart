class AppConstants {
  // App Information
  static const String appName = 'HairFlow';
  static const String appVersion = '1.0.0';
  
  // Database
  static const String databaseName = 'hairflow.db';
  static const int databaseVersion = 4;
  
  // Tables
  static const String routinesTable = 'routines';
  static const String routineTasksTable = 'routine_tasks';
  static const String userPreferencesTable = 'user_preferences';
  static const String tipsTable = 'tips';
  
  // SharedPreferences Keys
  static const String isFirstLaunchKey = 'is_first_launch';
  static const String userGoalKey = 'user_goal';
  static const String themeKey = 'theme_mode';
  static const String notificationsEnabledKey = 'notifications_enabled';
  static const String reminderTimeKey = 'reminder_time';
  
  // Default Routine Tasks
  static const List<String> defaultRoutineTasks = [
    'Sabah Minoxidil uygulaması',
    'Kafeinli şampuan ile saç yıkama',
    'Biotin takviyesi alma',
    'Akşam Minoxidil uygulaması (2. doz)',
  ];
  
  // Hair Goals
  static const List<String> hairGoals = [
    'Saç dökülmesini durdurmak',
    'Yeni saç çıkarmak',
    'Saç kalitesini artırmak',
    'Genel saç sağlığını korumak',
  ];
  
  // Notification
  static const int dailyReminderNotificationId = 1;
  static const String notificationChannelId = 'hairflow_reminders';
  static const String notificationChannelName = 'Rutin Hatırlatmaları';
  static const String notificationChannelDescription = 'Günlük saç bakım rutini hatırlatmaları';
}
