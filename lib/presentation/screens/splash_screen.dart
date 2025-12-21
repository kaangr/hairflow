import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import '../providers/user_preferences_provider.dart';
import '../providers/auth_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import 'onboarding/onboarding_screen.dart';
import 'main/main_navigation_screen.dart';
import 'landing/landing_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkAuthAndNavigate();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
    ));

    _animationController.forward();
  }

  void _checkAuthAndNavigate() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _navigateToNextScreen();
      }
    });
  }

  void _navigateToNextScreen() {
    final authProvider = context.read<AuthProvider>();
    final userPrefsProvider = context.read<UserPreferencesProvider>();

    // Web platformunda ve kullanıcı giriş yapmamışsa landing page'e git
    if (kIsWeb && !authProvider.isAuthenticated) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => _AuthWrapper(),
        ),
      );
      return;
    }

    // Kullanıcı giriş yapmış
    if (authProvider.isAuthenticated) {
      // İlk açılış mı kontrol et
      if (userPrefsProvider.isFirstLaunch) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const OnboardingScreen(),
          ),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const MainNavigationScreen(),
          ),
        );
      }
      return;
    }

    // Mobilde ve giriş yapmamışsa onboarding'e git
    if (userPrefsProvider.isFirstLaunch) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const OnboardingScreen(),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const MainNavigationScreen(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF4CAF50),
                      Color(0xFF2E7D32),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.grass,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  Text(
                    AppStrings.appTitle,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    AppStrings.appSubtitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 60),
            
            FadeTransition(
              opacity: _fadeAnimation,
              child: const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Wrapper widget that handles authentication flow
class _AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Show error snackbar if there's an error
        if (authProvider.error != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(authProvider.error!),
                backgroundColor: AppColors.error,
                action: SnackBarAction(
                  label: 'Kapat',
                  textColor: Colors.white,
                  onPressed: () => authProvider.clearError(),
                ),
              ),
            );
          });
        }

        // If authenticated, go to app
        if (authProvider.isAuthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final userPrefsProvider = context.read<UserPreferencesProvider>();
            if (userPrefsProvider.isFirstLaunch) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const OnboardingScreen(),
                ),
              );
            } else {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const MainNavigationScreen(),
                ),
              );
            }
          });
        }

        return LandingPage(
          isLoading: authProvider.isLoading,
          onGoogleSignIn: () async {
            await authProvider.signInWithGoogle();
          },
        );
      },
    );
  }
}
