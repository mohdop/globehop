import 'country.dart';

enum QuizType {
  flag,
  capital,
  region,
  population,
}

class QuizQuestion {
  final Country correctAnswer;
  final List<Country> options; // 4 options total (1 correct + 3 wrong)
  final String question;
  final QuizType type;

  QuizQuestion({
    required this.correctAnswer,
    required this.options,
    required this.question,
    required this.type,
  });

  bool isCorrect(Country selectedCountry) {
    return selectedCountry.cca3 == correctAnswer.cca3;
  }
  
  String getQuestionText() {
    switch (type) {
      case QuizType.flag:
        return 'Which country does this flag belong to?';
      case QuizType.capital:
        return 'What is the capital of ${correctAnswer.name}?';
      case QuizType.region:
        return 'Which region is ${correctAnswer.name} in?';
      case QuizType.population:
        return 'Which country has a larger population?';
    }
  }
}

enum PowerUpType {
  fiftyFifty,
  skip,
  hint,
}

class QuizResult {
  final int correctAnswers;
  final int totalQuestions;
  final int timeSpent; // in seconds
  final DateTime completedAt;
  final int streak;
  final int speedBonus;
  final QuizType quizType;
  final String difficulty;

  QuizResult({
    required this.correctAnswers,
    required this.totalQuestions,
    required this.timeSpent,
    required this.completedAt,
    this.streak = 0,
    this.speedBonus = 0,
    required this.quizType,
    required this.difficulty,
  });

  int get score => ((correctAnswers / totalQuestions) * 100).round();
  int get finalScore => score + speedBonus + (streak * 5);
  
  String get grade {
    if (score >= 90) return '🏆 Amazing!';
    if (score >= 75) return '🌟 Great Job!';
    if (score >= 60) return '👍 Good!';
    if (score >= 40) return '💪 Keep Going!';
    return '📚 Practice More!';
  }

  Map<String, dynamic> toJson() {
    return {
      'correctAnswers': correctAnswers,
      'totalQuestions': totalQuestions,
      'timeSpent': timeSpent,
      'completedAt': completedAt.toIso8601String(),
      'streak': streak,
      'speedBonus': speedBonus,
      'quizType': quizType.toString(),
      'difficulty': difficulty,
    };
  }

  factory QuizResult.fromJson(Map<String, dynamic> json) {
    return QuizResult(
      correctAnswers: json['correctAnswers'],
      totalQuestions: json['totalQuestions'],
      timeSpent: json['timeSpent'],
      completedAt: DateTime.parse(json['completedAt']),
      streak: json['streak'] ?? 0,
      speedBonus: json['speedBonus'] ?? 0,
      quizType: QuizType.values.firstWhere(
        (e) => e.toString() == json['quizType'],
        orElse: () => QuizType.flag,
      ),
      difficulty: json['difficulty'] ?? 'Medium',
    );
  }
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'emoji': emoji,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
    };
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      emoji: json['emoji'],
      isUnlocked: json['isUnlocked'] ?? false,
      unlockedAt: json['unlockedAt'] != null 
          ? DateTime.parse(json['unlockedAt']) 
          : null,
    );
  }
}