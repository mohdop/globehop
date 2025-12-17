import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/country.dart';
import '../models/quiz_question.dart';

class QuizProvider with ChangeNotifier {
  List<QuizQuestion> _questions = [];
  int _currentQuestionIndex = 0;
  int _correctAnswers = 0;
  int _timeElapsed = 0;
  Timer? _timer;
  bool _isQuizActive = false;
  Country? _selectedAnswer;
  bool _hasAnswered = false;
  List<QuizResult> _quizHistory = [];
  
  // New features
  int _lives = 3;
  int _currentStreak = 0;
  int _bestStreak = 0;
  int _speedBonus = 0;
  QuizType _currentQuizType = QuizType.flag;
  String _difficulty = 'Medium';
  Map<PowerUpType, int> _powerUps = {
    PowerUpType.fiftyFifty: 2,
    PowerUpType.skip: 1,
    PowerUpType.hint: 3,
  };
  List<Achievement> _achievements = [];
  bool _usedFiftyFifty = false;
  List<Country> _removedOptions = [];
  bool _isLoadingHistory = false;
  String? _currentHint; // Add hint storage

  // Getters
  List<QuizQuestion> get questions => _questions;
  int get currentQuestionIndex => _currentQuestionIndex;
  int get correctAnswers => _correctAnswers;
  int get timeElapsed => _timeElapsed;
  bool get isQuizActive => _isQuizActive;
  Country? get selectedAnswer => _selectedAnswer;
  bool get hasAnswered => _hasAnswered;
  int get totalQuestions => _questions.length;
  List<QuizResult> get quizHistory => _quizHistory;
  int get lives => _lives;
  int get currentStreak => _currentStreak;
  int get bestStreak => _bestStreak;
  int get speedBonus => _speedBonus;
  QuizType get currentQuizType => _currentQuizType;
  Map<PowerUpType, int> get powerUps => _powerUps;
  List<Achievement> get achievements => _achievements;
  bool get usedFiftyFifty => _usedFiftyFifty;
  List<Country> get removedOptions => _removedOptions;
  bool get isLoadingHistory => _isLoadingHistory;
  String? get currentHint => _currentHint;
  
  QuizQuestion? get currentQuestion {
    if (_currentQuestionIndex < _questions.length) {
      return _questions[_currentQuestionIndex];
    }
    return null;
  }

  int? get highScore {
    if (_quizHistory.isEmpty) return null;
    return _quizHistory.map((r) => r.finalScore).reduce((a, b) => a > b ? a : b);
  }

  int get totalQuizzesCompleted => _quizHistory.length;

  // Generate quiz questions
  void generateQuiz(
    List<Country> allCountries, {
    int numberOfQuestions = 10,
    QuizType type = QuizType.flag,
    String difficulty = 'Medium',
  }) {
    _questions.clear();
    _currentQuestionIndex = 0;
    _correctAnswers = 0;
    _timeElapsed = 0;
    _selectedAnswer = null;
    _hasAnswered = false;
    _lives = 3;
    _currentStreak = 0;
    _speedBonus = 0;
    _currentQuizType = type;
    _difficulty = difficulty;
    _usedFiftyFifty = false;
    _removedOptions.clear();
    _currentHint = null; // Reset hint

    if (allCountries.length < 4) {
      debugPrint('❌ Not enough countries to generate quiz');
      return;
    }

    final shuffled = List<Country>.from(allCountries)..shuffle();
    final quizCountries = shuffled.take(numberOfQuestions).toList();

    debugPrint('✅ Generating $type quiz with ${quizCountries.length} questions');

    for (var correctCountry in quizCountries) {
      List<Country> wrongAnswers;
      
      if (type == QuizType.region) {
        // For region quiz, ensure we get countries from different regions
        final correctRegion = correctCountry.region;
        final availableRegions = ['Africa', 'Americas', 'Asia', 'Europe', 'Oceania']
            .where((r) => r != correctRegion)
            .toList();
        
        wrongAnswers = [];
        for (var region in availableRegions.take(3)) {
          final countriesInRegion = allCountries
              .where((c) => c.region == region)
              .toList();
          if (countriesInRegion.isNotEmpty) {
            countriesInRegion.shuffle();
            wrongAnswers.add(countriesInRegion.first);
          }
        }
        
        // If we couldn't get 3 different regions, fill with any other countries
        if (wrongAnswers.length < 3) {
          final remaining = allCountries
              .where((c) => c.cca3 != correctCountry.cca3 && 
                           !wrongAnswers.any((w) => w.cca3 == c.cca3))
              .toList();
          remaining.shuffle();
          wrongAnswers.addAll(remaining.take(3 - wrongAnswers.length));
        }
      } else {
        // For other quiz types, pick any 3 random countries
        final otherCountries = allCountries
            .where((c) => c.cca3 != correctCountry.cca3)
            .toList();
        
        otherCountries.shuffle();
        wrongAnswers = otherCountries.take(3).toList();
      }
      
      final options = [correctCountry, ...wrongAnswers]..shuffle();

      _questions.add(QuizQuestion(
        correctAnswer: correctCountry,
        options: options,
        question: _getQuestionForType(type, correctCountry),
        type: type,
      ));
    }

    _isQuizActive = true;
    _startTimer();
    debugPrint('✅ Quiz generated: ${_questions.length} questions');
    notifyListeners();
  }

  String _getQuestionForType(QuizType type, Country country) {
    switch (type) {
      case QuizType.flag:
        return 'Which country does this flag belong to?';
      case QuizType.capital:
        return 'What is the capital of ${country.name}?';
      case QuizType.region:
        return 'Which region is ${country.name} in?';
      case QuizType.population:
        return 'Which country has more people?';
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _timeElapsed++;
      notifyListeners();
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void selectAnswer(Country country) {
    if (_hasAnswered) return;

    _selectedAnswer = country;
    _hasAnswered = true;

    final isCorrect = currentQuestion?.isCorrect(country) ?? false;
    
    if (isCorrect) {
      _correctAnswers++;
      _currentStreak++;
      if (_currentStreak > _bestStreak) {
        _bestStreak = _currentStreak;
      }
      // Speed bonus: answer in less than 5 seconds = bonus points
      if (_timeElapsed < 5) {
        _speedBonus += 10;
      }
      _checkAchievements();
    } else {
      _currentStreak = 0;
      _lives--;
      if (_lives <= 0) {
        finishQuiz(); // Game over
      }
    }

    notifyListeners();
  }

  Future<void> nextQuestion() async {
    if (_currentQuestionIndex < _questions.length - 1) {
      _currentQuestionIndex++;
      _selectedAnswer = null;
      _hasAnswered = false;
      _usedFiftyFifty = false;
      _removedOptions.clear();
      _currentHint = null; // Reset hint for next question
      notifyListeners();
    } else {
      await finishQuiz();
    }
  }

  // Power-Ups
  void useFiftyFifty() {
    if (_powerUps[PowerUpType.fiftyFifty]! <= 0 || _usedFiftyFifty || _hasAnswered) return;
    
    _powerUps[PowerUpType.fiftyFifty] = _powerUps[PowerUpType.fiftyFifty]! - 1;
    _usedFiftyFifty = true;
    
    final question = currentQuestion;
    if (question != null) {
      final wrongOptions = question.options
          .where((c) => c.cca3 != question.correctAnswer.cca3)
          .toList()..shuffle();
      _removedOptions = wrongOptions.take(2).toList();
    }
    
    notifyListeners();
  }

  void useSkip() {
    if (_powerUps[PowerUpType.skip]! <= 0 || _hasAnswered) return;
    
    _powerUps[PowerUpType.skip] = _powerUps[PowerUpType.skip]! - 1;
    nextQuestion();
  }

  void useHint() {
    if (_powerUps[PowerUpType.hint]! <= 0 || _hasAnswered || _currentHint != null) return;
    
    _powerUps[PowerUpType.hint] = _powerUps[PowerUpType.hint]! - 1;
    
    final question = currentQuestion;
    if (question != null) {
      // Generate hint based on quiz type
      switch (question.type) {
        case QuizType.flag:
          // Show first letter of country name
          _currentHint = '💡 First letter: ${question.correctAnswer.name[0]}';
          break;
        case QuizType.capital:
          // Show first letter of capital
          _currentHint = '💡 First letter: ${question.correctAnswer.capital[0]}';
          break;
        case QuizType.region:
          // Show continent
          _currentHint = '💡 Continent: ${question.correctAnswer.continents.first}';
          break;
        case QuizType.population:
          // Show population range
          final pop = question.correctAnswer.population;
          if (pop > 100000000) {
            _currentHint = '💡 Population: Over 100 million';
          } else if (pop > 50000000) {
            _currentHint = '💡 Population: 50-100 million';
          } else if (pop > 10000000) {
            _currentHint = '💡 Population: 10-50 million';
          } else {
            _currentHint = '💡 Population: Under 10 million';
          }
          break;
      }
    }
    
    notifyListeners();
  }

  Future<void> finishQuiz() async {
    _stopTimer();
    _isQuizActive = false;

    final result = QuizResult(
      correctAnswers: _correctAnswers,
      totalQuestions: _questions.length,
      timeSpent: _timeElapsed,
      completedAt: DateTime.now(),
      streak: _bestStreak,
      speedBonus: _speedBonus,
      quizType: _currentQuizType,
      difficulty: _difficulty,
    );

    _quizHistory.add(result);
    await _saveQuizHistory();
    _checkAchievements();
    
    notifyListeners();
  }

  void resetQuiz() {
    _stopTimer();
    _questions.clear();
    _currentQuestionIndex = 0;
    _correctAnswers = 0;
    _timeElapsed = 0;
    _isQuizActive = false;
    _selectedAnswer = null;
    _hasAnswered = false;
    _lives = 3;
    _currentStreak = 0;
    _speedBonus = 0;
    _usedFiftyFifty = false;
    _removedOptions.clear();
    notifyListeners();
  }

  String get formattedTime {
    final minutes = (_timeElapsed ~/ 60).toString().padLeft(2, '0');
    final seconds = (_timeElapsed % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  double get progress {
    if (_questions.isEmpty) return 0;
    return (_currentQuestionIndex + 1) / _questions.length;
  }

  // Achievements
  void _initializeAchievements() {
    _achievements = [
      Achievement(
        id: 'first_quiz',
        title: 'First Steps',
        description: 'Complete your first quiz',
        emoji: '🎯',
      ),
      Achievement(
        id: 'perfect_score',
        title: 'Perfect!',
        description: 'Get 100% on a quiz',
        emoji: '💯',
      ),
      Achievement(
        id: 'speed_demon',
        title: 'Speed Demon',
        description: 'Complete a quiz in under 2 minutes',
        emoji: '⚡',
      ),
      Achievement(
        id: 'explorer',
        title: 'World Explorer',
        description: 'Complete 10 quizzes',
        emoji: '🌍',
      ),
      Achievement(
        id: 'master',
        title: 'Geography Master',
        description: 'Complete 50 quizzes',
        emoji: '🏆',
      ),
      Achievement(
        id: 'streak_5',
        title: 'On Fire!',
        description: 'Get 5 correct answers in a row',
        emoji: '🔥',
      ),
      Achievement(
        id: 'streak_10',
        title: 'Unstoppable!',
        description: 'Get 10 correct answers in a row',
        emoji: '💥',
      ),
      Achievement(
        id: 'survivor',
        title: 'Survivor',
        description: 'Complete a quiz without losing a life',
        emoji: '❤️',
      ),
    ];
  }

  void _checkAchievements() {
    if (_achievements.isEmpty) return;

    // First quiz
    if (totalQuizzesCompleted >= 1) {
      _unlockAchievement('first_quiz');
    }

    // Perfect score
    if (_quizHistory.isNotEmpty && _quizHistory.last.score == 100) {
      _unlockAchievement('perfect_score');
    }

    // Speed demon
    if (_quizHistory.isNotEmpty && _quizHistory.last.timeSpent < 120) {
      _unlockAchievement('speed_demon');
    }

    // Explorer
    if (totalQuizzesCompleted >= 10) {
      _unlockAchievement('explorer');
    }

    // Master
    if (totalQuizzesCompleted >= 50) {
      _unlockAchievement('master');
    }

    // Streak achievements
    if (_bestStreak >= 5) {
      _unlockAchievement('streak_5');
    }
    if (_bestStreak >= 10) {
      _unlockAchievement('streak_10');
    }

    // Survivor
    if (_lives == 3 && !_isQuizActive && _correctAnswers == _questions.length) {
      _unlockAchievement('survivor');
    }
  }

  void _unlockAchievement(String id) {
    final index = _achievements.indexWhere((a) => a.id == id);
    if (index != -1 && !_achievements[index].isUnlocked) {
      _achievements[index] = Achievement(
        id: _achievements[index].id,
        title: _achievements[index].title,
        description: _achievements[index].description,
        emoji: _achievements[index].emoji,
        isUnlocked: true,
        unlockedAt: DateTime.now(),
      );
      _saveAchievements();
      notifyListeners();
    }
  }

  Future<void> loadQuizHistory() async {
    _isLoadingHistory = true;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString('quiz_history');
      if (historyJson != null) {
        final List<dynamic> decoded = json.decode(historyJson);
        _quizHistory = decoded.map((item) => QuizResult.fromJson(item)).toList();
        if (_quizHistory.length > 50) {
          _quizHistory = _quizHistory.sublist(_quizHistory.length - 50);
        }
      }

      final achievementsJson = prefs.getString('achievements');
      if (achievementsJson != null) {
        final List<dynamic> decoded = json.decode(achievementsJson);
        _achievements = decoded.map((item) => Achievement.fromJson(item)).toList();
      } else {
        _initializeAchievements();
      }
      
      _isLoadingHistory = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading quiz data: $e');
      _initializeAchievements();
      _isLoadingHistory = false;
      notifyListeners();
    }
  }

  Future<void> _saveQuizHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = json.encode(_quizHistory.map((r) => r.toJson()).toList());
      await prefs.setString('quiz_history', encoded);
    } catch (e) {
      debugPrint('Error saving quiz history: $e');
    }
  }

  Future<void> _saveAchievements() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = json.encode(_achievements.map((a) => a.toJson()).toList());
      await prefs.setString('achievements', encoded);
    } catch (e) {
      debugPrint('Error saving achievements: $e');
    }
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}