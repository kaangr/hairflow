import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/utils/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'core/services/notification_service.dart';
import 'data/datasources/database_helper.dart';
import 'data/datasources/local_datasource.dart';
import 'data/repositories/routine_repository_impl.dart';
import 'data/repositories/tip_repository_impl.dart';
import 'data/repositories/user_preferences_repository_impl.dart';
import 'presentation/providers/user_preferences_provider.dart';
import 'presentation/providers/routine_provider.dart';
import 'presentation/providers/tip_provider.dart';
import 'presentation/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize notification service
  await NotificationService().initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Repositories
        Provider<DatabaseHelper>(
          create: (_) => DatabaseHelper(),
        ),
        Provider<LocalDataSource>(
          create: (context) => LocalDataSourceImpl(
            context.read<DatabaseHelper>(),
          ),
        ),
        Provider<RoutineRepository>(
          create: (context) => RoutineRepositoryImpl(
            context.read<LocalDataSource>(),
          ),
        ),
        Provider<TipRepository>(
          create: (context) => TipRepositoryImpl(
            context.read<LocalDataSource>(),
          ),
        ),
        Provider<UserPreferencesRepository>(
          create: (_) => UserPreferencesRepositoryImpl(),
        ),
        Provider<NotificationService>(
          create: (_) => NotificationService(),
        ),
        
        // Providers
        ChangeNotifierProvider<UserPreferencesProvider>(
          create: (context) => UserPreferencesProvider(
            context.read<UserPreferencesRepository>(),
          ),
        ),
        ChangeNotifierProvider<RoutineProvider>(
          create: (context) => RoutineProvider(
            context.read<RoutineRepository>(),
          ),
        ),
        ChangeNotifierProvider<TipProvider>(
          create: (context) => TipProvider(
            context.read<TipRepository>(),
          ),
        ),
      ],
      child: Consumer<UserPreferencesProvider>(
        builder: (context, userPrefsProvider, child) {
          return MaterialApp(
            title: AppStrings.appTitle,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: userPrefsProvider.preferences.isDarkMode 
                ? ThemeMode.dark 
                : ThemeMode.light,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}