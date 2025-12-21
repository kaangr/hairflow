import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/routine_provider.dart';
import '../../../core/constants/app_strings.dart';
import 'home_screen.dart';
import 'routines_screen.dart';
import 'knowledge_base_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    // Load today's tasks when the app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RoutineProvider>().loadData();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: const [
          HomeScreen(),
          RoutinesScreen(),
          KnowledgeBaseScreen(),
          ProfileScreen(),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabSelected,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.home_outlined, 0),
              activeIcon: _buildNavIcon(Icons.home, 0, isActive: true),
              label: AppStrings.homeTab,
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.spa_outlined, 1),
              activeIcon: _buildNavIcon(Icons.spa, 1, isActive: true),
              label: AppStrings.routinesTab,
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.school_outlined, 2),
              activeIcon: _buildNavIcon(Icons.school, 2, isActive: true),
              label: AppStrings.learnTab,
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.person_outline, 3),
              activeIcon: _buildNavIcon(Icons.person, 3, isActive: true),
              label: 'Profil',
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.settings_outlined, 4),
              activeIcon: _buildNavIcon(Icons.settings, 4, isActive: true),
              label: AppStrings.settings,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, int index, {bool isActive = false}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isActive
            ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon),
    );
  }
}
