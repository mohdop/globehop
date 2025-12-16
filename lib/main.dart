import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'providers/countries_provider.dart';
import 'providers/quiz_provider.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const GlobeHopApp());
}

class GlobeHopApp extends StatelessWidget {
  const GlobeHopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => CountriesProvider()..loadCountries(),
        ),
        ChangeNotifierProvider(
          create: (context) => QuizProvider()..loadQuizHistory(),
        ),
      ],
      child: MaterialApp(
        title: 'GlobeHop',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(), // Changed from HomeScreen
      ),
    );
  }
}