import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/utils/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'core/services/notification_service.dart';
import 'core/services/auth_service.dart';
import 'data/datasources/database_helper.dart';
import 'data/datasources/local_datasource.dart';
import 'data/datasources/web_datasource.dart';
import 'data/repositories/routine_repository_impl.dart';
import 'data/repositories/tip_repository_impl.dart';
import 'data/repositories/user_preferences_repository_impl.dart';
import 'presentation/providers/user_preferences_provider.dart';
import 'presentation/providers/routine_provider.dart';
import 'presentation/providers/tip_provider.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize notification service (only for non-web platforms)
  if (!kIsWeb) {
    await NotificationService().initialize();
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  List<SingleChildWidget> _buildProviders() {
    final List<SingleChildWidget> providers = [
      // Auth Service
      Provider<AuthService>(
        create: (_) => AuthService(),
      ),
      
      // Auth Provider
      ChangeNotifierProvider<AuthProvider>(
        create: (context) => AuthProvider(
          context.read<AuthService>(),
        ),
      ),
    ];
    
    // Platform-specific data source
    if (kIsWeb) {
      providers.add(
        Provider<LocalDataSource>(
          create: (_) => WebDataSource(),
        ),
      );
    } else {
      providers.addAll([
        Provider<DatabaseHelper>(
          create: (_) => DatabaseHelper(),
        ),
        Provider<LocalDataSource>(
          create: (context) => LocalDataSourceImpl(
            context.read<DatabaseHelper>(),
          ),
        ),
      ]);
    }
    
    // Common providers
    providers.addAll([
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
      
      // State Providers
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
    ]);
    
    return providers;
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: _buildProviders(),
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
