import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_preferences_provider.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.settings),
      ),
      body: Consumer<UserPreferencesProvider>(
        builder: (context, userPrefsProvider, child) {
          final preferences = userPrefsProvider.preferences;
          
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Theme Settings
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        preferences.isDarkMode 
                            ? Icons.dark_mode 
                            : Icons.light_mode,
                      ),
                      title: const Text(AppStrings.darkMode),
                      subtitle: Text(
                        preferences.isDarkMode ? 'Açık' : 'Kapalı',
                      ),
                      trailing: Switch(
                        value: preferences.isDarkMode,
                        onChanged: (value) {
                          userPrefsProvider.updateTheme(value);
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Notification Settings
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.notifications),
                      title: const Text(AppStrings.notifications),
                      subtitle: Text(
                        preferences.notificationsEnabled ? 'Açık' : 'Kapalı',
                      ),
                      trailing: Switch(
                        value: preferences.notificationsEnabled,
                        onChanged: (value) {
                          userPrefsProvider.updateNotificationSettings(
                            value,
                            preferences.reminderTime,
                          );
                        },
                      ),
                    ),
                    if (preferences.notificationsEnabled)
                      ListTile(
                        leading: const Icon(Icons.schedule),
                        title: const Text(AppStrings.reminderTime),
                        subtitle: Text(preferences.reminderTime),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _showTimePickerDialog(context, userPrefsProvider),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Goal Settings
              Card(
                child: ListTile(
                  leading: const Icon(Icons.flag),
                  title: const Text('Hedef'),
                  subtitle: Text(preferences.goal),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showGoalSelectionDialog(context, userPrefsProvider),
                ),
              ),

              const SizedBox(height: 32),

              // App Info
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.info),
                      title: const Text(AppStrings.about),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showAboutDialog(context),
                    ),
                    ListTile(
                      leading: const Icon(Icons.assignment),
                      title: const Text(AppStrings.version),
                      subtitle: const Text(AppConstants.appVersion),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Legal
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.privacy_tip),
                      title: const Text(AppStrings.privacyPolicy),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // TODO: Show privacy policy
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Gizlilik politikası yakında eklenecek'),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.description),
                      title: const Text(AppStrings.termsOfService),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // TODO: Show terms of service
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Kullanım şartları yakında eklenecek'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showTimePickerDialog(BuildContext context, UserPreferencesProvider provider) {
    final currentTime = provider.preferences.reminderTime.split(':');
    final initialTime = TimeOfDay(
      hour: int.parse(currentTime[0]),
      minute: int.parse(currentTime[1]),
    );

    showTimePicker(
      context: context,
      initialTime: initialTime,
    ).then((time) {
      if (time != null) {
        final timeString = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
        provider.updateNotificationSettings(
          provider.preferences.notificationsEnabled,
          timeString,
        );
      }
    });
  }

  void _showGoalSelectionDialog(BuildContext context, UserPreferencesProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hedefinizi Seçin'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppConstants.hairGoals
              .map((goal) => RadioListTile<String>(
                    title: Text(goal),
                    value: goal,
                    groupValue: provider.preferences.goal,
                    onChanged: (value) {
                      if (value != null) {
                        provider.updateGoal(value);
                        Navigator.pop(context);
                      }
                    },
                  ))
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: AppConstants.appVersion,
      applicationIcon: Container(
        width: 64,
        height: 64,
        decoration: const BoxDecoration(
          color: Colors.green,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.health_and_safety,
          size: 32,
          color: Colors.white,
        ),
      ),
      children: [
        const Text(
          'HairFlow, erkekler için tasarlanmış kapsamlı bir saç sağlığı asistanıdır. '
          'Günlük rutinlerinizi takip edin, uzman tavsiyeleri alın ve saç sağlığınızı iyileştirin.',
        ),
      ],
    );
  }
}
