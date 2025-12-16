import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/quiz_provider.dart';
import '../providers/countries_provider.dart';

class QuizResultScreen extends StatefulWidget {
  const QuizResultScreen({super.key});

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<QuizProvider>(
          builder: (context, quizProvider, child) {
            if (quizProvider.quizHistory.isEmpty) {
              return const Center(child: Text('No quiz results'));
            }

            final result = quizProvider.quizHistory.last;
            final percentage = result.score;
            final isNewHighScore = quizProvider.highScore == percentage;

            return Container(
              decoration: BoxDecoration(
                gradient: _getGradientForScore(percentage),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          
                          // Trophy/Medal icon
                          ScaleTransition(
                            scale: _scaleAnimation,
                            child: Text(
                              _getEmojiForScore(percentage),
                              style: const TextStyle(fontSize: 100),
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Grade text
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: Text(
                              result.grade,
                              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Score
                          ScaleTransition(
                            scale: _scaleAnimation,
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    '$percentage%',
                                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                      fontSize: 56,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.sunsetOrange,
                                    ),
                                  ),
                                  Text(
                                    '${result.correctAnswers} out of ${result.totalQuestions} correct',
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: AppTheme.midGray,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Stats cards
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: Row(
                              children: [
                                Expanded(
                                  child: _buildStatCard(
                                    '⏱️',
                                    'Time',
                                    _formatTime(result.timeSpent),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildStatCard(
                                    '🏆',
                                    'High Score',
                                    '${quizProvider.highScore ?? 0}%',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          if (isNewHighScore) ...[
                            const SizedBox(height: 24),
                            ScaleTransition(
                              scale: _scaleAnimation,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  gradient: AppTheme.candyGradient,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text('✨', style: TextStyle(fontSize: 24)),
                                    const SizedBox(width: 8),
                                    Text(
                                      'New High Score!',
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text('✨', style: TextStyle(fontSize: 24)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  
                  // Buttons
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              final countriesProvider = context.read<CountriesProvider>();
                              quizProvider.generateQuiz(
                                countriesProvider.allCountries,
                                numberOfQuestions: 10,
                              );
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.replay),
                            label: const Text('Play Again'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              quizProvider.resetQuiz();
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.home),
                            label: const Text('Back to Home'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.all(16),
                              side: const BorderSide(color: Colors.white, width: 2),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatCard(String emoji, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.midGray,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.sunsetOrange,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes}m ${remainingSeconds}s';
  }

  String _getEmojiForScore(int score) {
    if (score >= 90) return '🏆';
    if (score >= 75) return '🌟';
    if (score >= 60) return '👍';
    if (score >= 40) return '💪';
    return '📚';
  }

  LinearGradient _getGradientForScore(int score) {
    if (score >= 75) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFB627), Color(0xFF90EE90)],
      );
    } else if (score >= 50) {
      return AppTheme.candyGradient;
    } else {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFF8FAB), Color(0xFFA855F7)],
      );
    }
  }
}