import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../l10n/app_localizations.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    _controller.forward();

    // Navigate to home after animation
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.sunsetGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Logo
              ScaleTransition(
                scale: _scaleAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/GLOBEHOP_NO_BG512.png',
                      width: 120,
                      height: 120,
                      errorBuilder: (context, error, stackTrace) {
                        return const Text(
                          '🗺️',
                          style: TextStyle(fontSize: 80),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              
              // App Name
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'GlobeHop',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Tagline
              FadeTransition(
                opacity: _fadeAnimation,
                child: Builder(
                  builder: (context) {
                    // Safely get localization with fallback
                    try {
                      final l10n = AppLocalizations.of(context);
                      return Text(
                        l10n.appTagline,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      );
                    } catch (e) {
                      // Fallback if localization not ready
                      return Text(
                        'Explore the world, one hop at a time!',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 60),
              
              // Loading Indicator
              FadeTransition(
                opacity: _fadeAnimation,
                child: const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}