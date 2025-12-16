import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/quiz_provider.dart';
import '../models/quiz_question.dart';

class QuizHistoryScreen extends StatelessWidget {
  const QuizHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz History'),
      ),
      body: Consumer<QuizProvider>(
        builder: (context, quizProvider, child) {
          // Show loading indicator while data is being loaded
          if (quizProvider.isLoadingHistory) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading history...'),
                ],
              ),
            );
          }

          if (quizProvider.quizHistory.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('📚', style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 16),
                  Text(
                    'No quiz history yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Complete a quiz to see your history!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.midGray,
                    ),
                  ),
                ],
              ),
            );
          }

          final history = quizProvider.quizHistory.reversed.toList();

          return Column(
            children: [
              // Stats Summary
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppTheme.sunsetGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      context,
                      '🎯',
                      'Total',
                      '${quizProvider.totalQuizzesCompleted}',
                    ),
                    _buildStatItem(
                      context,
                      '🏆',
                      'High Score',
                      '${quizProvider.highScore ?? 0}',
                    ),
                    _buildStatItem(
                      context,
                      '🔥',
                      'Best Streak',
                      '${quizProvider.bestStreak}',
                    ),
                  ],
                ),
              ),
              
              // History List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final result = history[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: _getGradientForScore(result.score),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${result.score}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          _getQuizTypeName(result.quizType),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${result.correctAnswers}/${result.totalQuestions} • ${_formatTime(result.timeSpent)} • ${result.difficulty}',
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (result.streak > 0)
                              Text(
                                '🔥 ${result.streak}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            Text(
                              _formatDate(result.completedAt),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.midGray,
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
          );
        },
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String emoji, String label, String value) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 32)),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppTheme.cream,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.cream,
          ),
        ),
      ],
    );
  }

  String _getQuizTypeName(QuizType type) {
    switch (type) {
      case QuizType.flag:
        return '🏁 Flag Quiz';
      case QuizType.capital:
        return '🏛️ Capital Quiz';
      case QuizType.region:
        return '🌍 Region Quiz';
      case QuizType.population:
        return '👥 Population Quiz';
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes}m ${remainingSeconds}s';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  LinearGradient _getGradientForScore(int score) {
    if (score >= 75) {
      return AppTheme.joyGradient;
    } else if (score >= 50) {
      return AppTheme.sunsetGradient;
    } else {
      return AppTheme.candyGradient;
    }
  }
}