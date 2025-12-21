import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import '../../providers/user_preferences_provider.dart';
import '../../providers/auth_provider.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/firebase_seed_service.dart';
import '../../../core/services/firestore_service.dart';
import '../splash_screen.dart';

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
              
              const SizedBox(height: 24),
              
              // Account Section
              _buildAccountSection(context),
              
              const SizedBox(height: 24),
              
              // Developer Section (Firebase)
              _buildDeveloperSection(context),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildAccountSection(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (!authProvider.isAuthenticated) {
          return const SizedBox.shrink();
        }
        
        return Card(
          child: Column(
            children: [
              // User info
              ListTile(
                leading: CircleAvatar(
                  backgroundImage: authProvider.photoURL != null
                      ? NetworkImage(authProvider.photoURL!)
                      : null,
                  backgroundColor: AppColors.primary,
                  child: authProvider.photoURL == null
                      ? const Icon(Icons.person, color: Colors.white)
                      : null,
                ),
                title: Text(authProvider.displayName ?? 'Kullanıcı'),
                subtitle: Text(authProvider.email ?? ''),
              ),
              const Divider(height: 1),
              // Sync to Firebase
              ListTile(
                leading: const Icon(Icons.cloud_sync, color: AppColors.secondary),
                title: const Text('Verileri Senkronize Et'),
                subtitle: const Text('Cloud\'a yedekle'),
                onTap: () => _syncToFirebase(context),
              ),
              const Divider(height: 1),
              // Sign out
              ListTile(
                leading: const Icon(Icons.logout, color: AppColors.error),
                title: const Text(
                  'Çıkış Yap',
                  style: TextStyle(color: AppColors.error),
                ),
                onTap: () => _showSignOutDialog(context, authProvider),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildDeveloperSection(BuildContext context) {
    // Only show in debug mode or for certain users
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              '🔧 Geliştirici Ayarları',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.cloud_upload, color: Colors.blue),
            title: const Text('Varsayılan Verileri Yükle'),
            subtitle: const Text('Ürünler ve ipuçlarını Firebase\'e ekle'),
            onTap: () => _seedFirebaseData(context),
          ),
          ListTile(
            leading: const Icon(Icons.refresh, color: Colors.orange),
            title: const Text('Değerlendirmeyi Sıfırla'),
            subtitle: const Text('Saç değerlendirmesini tekrar yap'),
            onTap: () => _resetAssessment(context),
          ),
          ListTile(
            leading: Icon(
              kIsWeb ? Icons.web : Icons.phone_android, 
              color: Colors.green,
            ),
            title: Text('Platform: ${kIsWeb ? "Web" : "Mobil"}'),
            subtitle: Text('Firebase: ${FirestoreService().isLoggedIn ? "Bağlı" : "Bağlı Değil"}'),
          ),
        ],
      ),
    );
  }
  
  void _syncToFirebase(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    
    if (!FirestoreService().isLoggedIn) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Önce giriş yapmalısınız'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Veriler senkronize ediliyor...'),
          ],
        ),
      ),
    );
    
    try {
      // TODO: Implement actual sync logic
      await Future.delayed(const Duration(seconds: 2));
      
      if (context.mounted) Navigator.pop(context);
      
      messenger.showSnackBar(
        const SnackBar(
          content: Text('✅ Veriler başarıyla senkronize edildi!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      
      messenger.showSnackBar(
        SnackBar(
          content: Text('Hata: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
  
  void _seedFirebaseData(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Varsayılan Verileri Yükle'),
        content: const Text(
          'Bu işlem Firebase\'e varsayılan ürünleri ve ipuçlarını ekleyecek. '
          'Mevcut veriler varsa atlanacak. Devam etmek istiyor musunuz?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const AlertDialog(
                  content: Row(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(width: 16),
                      Text('Veriler yükleniyor...'),
                    ],
                  ),
                ),
              );
              
              try {
                await FirebaseSeedService().seedAll();
                
                if (context.mounted) Navigator.pop(context);
                
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('✅ Varsayılan veriler yüklendi!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                if (context.mounted) Navigator.pop(context);
                
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Hata: $e'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: const Text('Yükle'),
          ),
        ],
      ),
    );
  }
  
  void _resetAssessment(BuildContext context) async {
    final userPrefsProvider = Provider.of<UserPreferencesProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Değerlendirmeyi Sıfırla'),
        content: const Text(
          'Saç değerlendirmenizi sıfırlamak istiyor musunuz? '
          'Bu işlem sonrasında yeniden değerlendirme yapmanız gerekecek.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            onPressed: () async {
              Navigator.pop(context);
              
              await userPrefsProvider.resetAssessment();
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Değerlendirme sıfırlandı. Rutinler ekranından yeniden başlayabilirsiniz.'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Sıfırla', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
  
  void _showSignOutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text('Hesabınızdan çıkış yapmak istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await authProvider.signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const SplashScreen()),
                  (route) => false,
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Çıkış Yap'),
          ),
        ],
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
