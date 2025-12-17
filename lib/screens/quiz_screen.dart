import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../config/theme.dart';
import '../providers/quiz_provider.dart';
import '../models/country.dart';
import '../models/quiz_question.dart';
import 'quiz_result_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
  late AnimationController _flagAnimationController;
  late AnimationController _streakAnimationController;

  @override
  void initState() {
    super.initState();
    _flagAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();

    _streakAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _flagAnimationController.dispose();
    _streakAnimationController.dispose();
    super.dispose();
  }

  void _resetAnimations() {
    _flagAnimationController.reset();
    _flagAnimationController.forward();
  }

  void _playStreakAnimation() {
    _streakAnimationController.forward().then((_) {
      _streakAnimationController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await _showExitDialog(context);
        return shouldPop ?? false;
      },
      child: Scaffold(
        body: SafeArea(
          child: Consumer<QuizProvider>(
            builder: (context, quizProvider, child) {
              if (quizProvider.questions.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Preparing your quiz...'),
                    ],
                  ),
                );
              }

              if (!quizProvider.isQuizActive) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const QuizResultScreen(),
                    ),
                  );
                });
                return const Center(child: CircularProgressIndicator());
              }

              final question = quizProvider.currentQuestion;
              if (question == null) {
                return const Center(child: Text('No question available'));
              }

              return Column(
                children: [
                  _buildHeader(quizProvider),
                  _buildProgressBar(quizProvider),
                  _buildPowerUps(quizProvider),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildQuestionCard(question, quizProvider),
                          const SizedBox(height: 24),
                          if (quizProvider.currentHint != null)
                            _buildHintDisplay(quizProvider.currentHint!),
                          if (quizProvider.currentHint != null)
                            const SizedBox(height: 24),
                          _buildOptions(question, quizProvider),
                          if (quizProvider.hasAnswered) ...[
                            const SizedBox(height: 24),
                            _buildNextButton(quizProvider),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(QuizProvider quizProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.sunsetGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: AppTheme.cream),
            onPressed: () => _showExitDialog(context),
          ),
          Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.favorite, color: Colors.red, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    'x${quizProvider.lives}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.cream,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 16),
                  if (quizProvider.currentStreak > 0) ...[
                    const Text('🔥', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 4),
                    ScaleTransition(
                      scale: Tween<double>(begin: 1.0, end: 1.3).animate(
                        _streakAnimationController,
                      ),
                      child: Text(
                        '${quizProvider.currentStreak}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.cream,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              Text(
                '⏱️ ${quizProvider.formattedTime}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.cream,
                ),
              ),
            ],
          ),
          Text(
            '${quizProvider.correctAnswers}/${quizProvider.totalQuestions}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.cream,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(QuizProvider quizProvider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${quizProvider.currentQuestionIndex + 1}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${quizProvider.currentQuestionIndex + 1}/${quizProvider.totalQuestions}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.midGray,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: quizProvider.progress,
              minHeight: 8,
              backgroundColor: AppTheme.softGray,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.sunsetOrange),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPowerUps(QuizProvider quizProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildPowerUpButton(
            icon: Icons.clear,
            label: '50/50',
            count: quizProvider.powerUps[PowerUpType.fiftyFifty] ?? 0,
            enabled: !quizProvider.usedFiftyFifty && !quizProvider.hasAnswered,
            onTap: () => quizProvider.useFiftyFifty(),
          ),
          _buildPowerUpButton(
            icon: Icons.skip_next,
            label: 'Skip',
            count: quizProvider.powerUps[PowerUpType.skip] ?? 0,
            enabled: !quizProvider.hasAnswered,
            onTap: () => quizProvider.useSkip(),
          ),
          _buildPowerUpButton(
            icon: Icons.lightbulb_outline,
            label: 'Hint',
            count: quizProvider.powerUps[PowerUpType.hint] ?? 0,
            enabled: !quizProvider.hasAnswered && quizProvider.currentHint == null,
            onTap: () => quizProvider.useHint(),
          ),
        ],
      ),
    );
  }

  Widget _buildPowerUpButton({
    required IconData icon,
    required String label,
    required int count,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    final isEnabled = count > 0 && enabled;
    return InkWell(
      onTap: isEnabled ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isEnabled ? AppTheme.bubblegumPink.withOpacity(0.1) : AppTheme.softGray,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isEnabled ? AppTheme.bubblegumPink : AppTheme.midGray,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isEnabled ? AppTheme.bubblegumPink : AppTheme.midGray,
              size: 20,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isEnabled ? AppTheme.charcoal : AppTheme.midGray,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: isEnabled ? AppTheme.bubblegumPink : AppTheme.midGray,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard(QuizQuestion question, QuizProvider quizProvider) {
    return FadeTransition(
      opacity: _flagAnimationController,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _flagAnimationController,
          curve: Curves.easeOut,
        )),
        child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  question.question,
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                if (question.type == QuizType.flag)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: question.correctAnswer.flagPng,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        height: 150,
                        color: AppTheme.softGray,
                        child: Center(
                          child: Text(
                            question.correctAnswer.flag,
                            style: const TextStyle(fontSize: 80),
                          ),
                        ),
                      ),
                    ),
                  ),
                if (question.type == QuizType.capital || question.type == QuizType.region)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: AppTheme.candyGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          question.correctAnswer.flag,
                          style: const TextStyle(fontSize: 80),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          question.correctAnswer.name,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptions(QuizQuestion question, QuizProvider quizProvider) {
    return Column(
      children: question.options.asMap().entries.map<Widget>((entry) {
        final index = entry.key;
        final country = entry.value;
        
        // Check if this option should be removed by 50/50
        if (quizProvider.removedOptions.contains(country)) {
          return const SizedBox.shrink();
        }
        
        final isSelected = quizProvider.selectedAnswer?.cca3 == country.cca3;
        final isCorrect = question.correctAnswer.cca3 == country.cca3;
        
        Color? backgroundColor;
        Color? borderColor;
        
        if (quizProvider.hasAnswered) {
          if (isCorrect) {
            backgroundColor = AppTheme.limeZest.withOpacity(0.2);
            borderColor = AppTheme.limeZest;
          } else if (isSelected && !isCorrect) {
            backgroundColor = Colors.red.withOpacity(0.2);
            borderColor = Colors.red;
          }
        } else if (isSelected) {
          backgroundColor = AppTheme.sunsetOrange.withOpacity(0.1);
          borderColor = AppTheme.sunsetOrange;
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 200 + (index * 100).toInt()),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Opacity(
                  opacity: value,
                  child: child,
                ),
              );
            },
            child: InkWell(
              onTap: quizProvider.hasAnswered
                  ? null
                  : () {
                      quizProvider.selectAnswer(country);
                      if (isCorrect && quizProvider.currentStreak > 0) {
                        _playStreakAnimation();
                      }
                    },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: backgroundColor ?? Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: borderColor ?? AppTheme.softGray,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: isCorrect && quizProvider.hasAnswered
                            ? AppTheme.joyGradient
                            : AppTheme.candyGradient,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          String.fromCharCode(65 + index),
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppTheme.cream,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        question.type == QuizType.capital 
                            ? country.capital
                            : question.type == QuizType.region
                                ? country.region
                                : country.name,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (quizProvider.hasAnswered && isCorrect)
                      const Icon(Icons.check_circle, color: AppTheme.limeZest),
                    if (quizProvider.hasAnswered && isSelected && !isCorrect)
                      const Icon(Icons.cancel, color: Colors.red),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNextButton(QuizProvider quizProvider) {
    final isLastQuestion = 
        quizProvider.currentQuestionIndex == quizProvider.totalQuestions - 1;
    
    return ElevatedButton(
      onPressed: () async {
        await quizProvider.nextQuestion();
        if (quizProvider.isQuizActive) {
          _resetAnimations();
        }
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isLastQuestion ? 'Finish Quiz' : 'Next Question',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(width: 8),
          Icon(isLastQuestion ? Icons.check : Icons.arrow_forward),
        ],
      ),
    );
  }

  Widget _buildHintDisplay(String hint) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 500),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: AppTheme.joyGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.mangoYellow.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.lightbulb,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              hint,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showExitDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Exit Quiz?'),
        content: const Text('Your progress will be lost. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<QuizProvider>().resetQuiz();
              Navigator.pop(context, true);
              Navigator.pop(context);
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
}