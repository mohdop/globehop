import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/quiz_provider.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
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
                  Text('Loading achievements...'),
                ],
              ),
            );
          }

          final achievements = quizProvider.achievements;
          final unlockedCount = achievements.where((a) => a.isUnlocked).length;

          return Column(
            children: [
              // Progress Header
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppTheme.candyGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Text(
                      '🏆',
                      style: const TextStyle(fontSize: 48),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '$unlockedCount / ${achievements.length}',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Achievements Unlocked',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: unlockedCount / achievements.length,
                        minHeight: 8,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ],
                ),
              ),

              // Achievements List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: achievements.length,
                  itemBuilder: (context, index) {
                    final achievement = achievements[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      color: achievement.isUnlocked 
                          ? Colors.white 
                          : AppTheme.softGray,
                      child: ListTile(
                        leading: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: achievement.isUnlocked
                                ? AppTheme.sunsetGradient
                                : null,
                            color: achievement.isUnlocked
                                ? null
                                : AppTheme.midGray.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              achievement.emoji,
                              style: TextStyle(
                                fontSize: 28,
                                color: achievement.isUnlocked
                                    ? null
                                    : AppTheme.midGray,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          achievement.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: achievement.isUnlocked
                                ? AppTheme.charcoal
                                : AppTheme.midGray,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              achievement.description,
                              style: TextStyle(
                                color: achievement.isUnlocked
                                    ? AppTheme.midGray
                                    : AppTheme.midGray.withOpacity(0.7),
                              ),
                            ),
                            if (achievement.isUnlocked && achievement.unlockedAt != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Unlocked ${_formatDate(achievement.unlockedAt!)}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.sunsetOrange,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                        trailing: achievement.isUnlocked
                            ? const Icon(Icons.check_circle, color: AppTheme.limeZest)
                            : const Icon(Icons.lock, color: AppTheme.midGray),
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return 'on ${date.day}/${date.month}/${date.year}';
    }
  }
}