import 'package:flutter/material.dart';
import 'app_en.dart';
import 'app_fr.dart';
import 'app_es.dart';

abstract class AppLocalizations {
  static AppLocalizations of(BuildContext context) {
    final localizations = Localizations.of<AppLocalizations>(context, AppLocalizations);
    // Fallback to English if localization not found
    return localizations ?? AppLocalizationsEn();
  }

  // App Name & Tagline
  String get appName;
  String get appTagline;

  // Home Screen
  String get searchCountries;
  String get noCountriesFound;
  String get tryDifferentSearch;
  String get somethingWentWrong;
  String get pleaseTryAgain;
  String get retry;
  String get all;

  // Country Details
  String get capital;
  String get population;
  String get area;
  String get region;
  String get languages;
  String get currencies;
  String get continents;
  String get timezones;
  String get compareWithAnotherCountry;

  // Quiz
  String get quizMode;
  String get chooseQuizMode;
  String get quizType;
  String get guessTheFlag;
  String get guessTheCapital;
  String get guessTheRegion;
  String get difficulty;
  String get easy;
  String get medium;
  String get hard;
  String get questions;
  String get question;
  String get nextQuestion;
  String get finishQuiz;
  String get exitQuiz;
  String get yourProgressWillBeLost;
  String get areYouSure;
  String get cancel;
  String get exit;
  String get score;
  String get time;
  String get highScore;
  String get bestStreak;
  String get speedBonus;
  String get finalScore;
  String get playAgain;
  String get backToHome;

  // Quiz History
  String get quizHistory;
  String get noQuizHistory;
  String get completeQuizToSeeHistory;
  String get total;
  String get loadingHistory;

  // Achievements
  String get achievements;
  String get achievementsUnlocked;
  String get loadingAchievements;
  String get unlocked;

  // Comparison
  String get compare;
  String get compareCountries;
  String get selectTwoCountries;
  String get tapToSelect;
  String get landArea;
  String get sameRegion;

  // Power-ups
  String get fiftyFifty;
  String get skip;
  String get hint;

  // Regions
  String get africa;
  String get americas;
  String get asia;
  String get europe;
  String get oceania;

  // Messages
  String get waitForCountriesToLoad;
  String get preparingQuiz;

  // Factory method to get correct translation
  static AppLocalizations load(Locale locale) {
    switch (locale.languageCode) {
      case 'fr':
        return AppLocalizationsFr();
      case 'es':
        return AppLocalizationsEs();
      case 'en':
      default:
        return AppLocalizationsEn();
    }
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'fr', 'es'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    // Return synchronously using SynchronousFuture for better performance
    return Future.value(AppLocalizations.load(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}