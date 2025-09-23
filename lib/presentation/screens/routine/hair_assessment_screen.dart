import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/predefined_routines.dart';
import '../../../core/constants/app_strings.dart';
import '../../widgets/animated_loading.dart';
import 'routine_recommendations_screen.dart';

class HairAssessmentScreen extends StatefulWidget {
  const HairAssessmentScreen({super.key});

  @override
  State<HairAssessmentScreen> createState() => _HairAssessmentScreenState();
}

class _HairAssessmentScreenState extends State<HairAssessmentScreen>
    with TickerProviderStateMixin {
  int _currentQuestionIndex = 0;
  final List<dynamic> _answers = [];
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> _questions = 
      PredefinedRoutines.getHairAssessmentQuestions();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 100.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _selectAnswer(dynamic answer) async {
    _answers.add(answer);

    if (_currentQuestionIndex < _questions.length - 1) {
      // Animate out
      await _animationController.reverse();
      
      setState(() {
        _currentQuestionIndex++;
      });
      
      // Animate in
      await _animationController.forward();
    } else {
      // Assessment complete
      _navigateToRecommendations();
    }
  }

  void _navigateToRecommendations() {
    final hairType = _answers[0] as HairType;
    final hairLossStage = _answers[1] as HairLossStage;
    final userGoal = _answers[2] as UserGoal;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => RoutineRecommendationsScreen(
          hairType: hairType,
          hairLossStage: hairLossStage,
          userGoal: userGoal,
        ),
      ),
    );
  }

  void _goBack() async {
    if (_currentQuestionIndex > 0) {
      await _animationController.reverse();
      
      setState(() {
        _currentQuestionIndex--;
        _answers.removeLast();
      });
      
      await _animationController.forward();
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / _questions.length;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Saç Analizi'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _goBack,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Progress indicator
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Stack(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: MediaQuery.of(context).size.width * progress,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.secondary,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Progress text
              Text(
                '${_currentQuestionIndex + 1} / ${_questions.length}',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 40),

              // Question
              Expanded(
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _slideAnimation.value),
                      child: Opacity(
                        opacity: _fadeAnimation.value,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Question icon
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                _getQuestionIcon(_currentQuestionIndex),
                                size: 48,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Question text
                            Text(
                              currentQuestion['question'],
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                height: 1.3,
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Answer options
                            Expanded(
                              child: ListView.builder(
                                itemCount: currentQuestion['options'].length,
                                itemBuilder: (context, index) {
                                  final option = currentQuestion['options'][index];
                                  
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _buildOptionCard(
                                      option['text'],
                                      () => _selectAnswer(option['value']),
                                      index,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(String text, VoidCallback onTap, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, (1 - value) * 50),
          child: Opacity(
            opacity: value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.surface,
                    Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                  ],
                ),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              String.fromCharCode(65 + index), // A, B, C, D
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            text,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getQuestionIcon(int questionIndex) {
    switch (questionIndex) {
      case 0:
        return Icons.spa; // Saç tipi
      case 1:
        return Icons.trending_down; // Dökülme seviyesi
      case 2:
        return Icons.flag; // Hedef
      default:
        return Icons.help;
    }
  }
}
