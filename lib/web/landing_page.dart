import 'package:flutter/material.dart';
import '../config/theme.dart';
import 'privacy_page.dart';
import 'features_page.dart';

class WebLandingPage extends StatelessWidget {
  const WebLandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildNavBar(context),
            _buildHeroSection(context),
            _buildFeaturesSection(context),
            _buildScreenshotsSection(context),
            _buildDownloadSection(context),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildNavBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          Row(
            children: [
              Image.asset(
                'assets/images/logo.png',
                width: 50,
                height: 50,
                errorBuilder: (context, error, stackTrace) {
                  return const Text('🗺️', style: TextStyle(fontSize: 40));
                },
              ),
              const SizedBox(width: 16),
              Text(
                'GlobeHop',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.sunsetOrange,
                ),
              ),
            ],
          ),
          // Nav items
          Row(
            children: [
              _buildNavItem(context, 'Features', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FeaturesPage()),
                );
              }),
              const SizedBox(width: 32),
              _buildNavItem(context, 'Privacy', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PrivacyPage()),
                );
              }),
              const SizedBox(width: 32),
              _buildNavItem(context, 'Contact', () {
                // Scroll to footer
              }),
              const SizedBox(width: 32),
              ElevatedButton(
                onPressed: () {
                  // Scroll to download section
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  backgroundColor: AppTheme.sunsetOrange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('Download App'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppTheme.charcoal,
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 100),
      decoration: BoxDecoration(
        gradient: AppTheme.sunsetGradient,
      ),
      child: Row(
        children: [
          // Left side - Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Explore the World,',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 56,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                Text(
                  'One Hop at a Time! 🌍',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 56,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Learn about 250+ countries through fun quizzes, interactive exploration, and exciting challenges. Perfect for students, travelers, and curious minds!',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white.withOpacity(0.95),
                    fontSize: 20,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 48),
                Row(
                  children: [
                    _buildDownloadButton(
                      'Download on Play Store',
                      Icons.android,
                      () {
                        // Open Play Store link
                      },
                    ),
                    const SizedBox(width: 16),
                    _buildDownloadButton(
                      'Coming to App Store',
                      Icons.apple,
                      null, // Disabled
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 80),
          // Right side - Phone mockup (or image)
          Expanded(
            child: Center(
              child: Container(
                width: 300,
                height: 600,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 40,
                      spreadRadius: 10,
                      offset: const Offset(0, 20),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: Image.asset(
                    'assets/images/app_screenshot.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.phone_android, size: 100, color: AppTheme.midGray),
                            const SizedBox(height: 16),
                            Text(
                              'App Screenshot',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppTheme.midGray,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadButton(String text, IconData icon, VoidCallback? onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 24),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        backgroundColor: onPressed != null ? Colors.white : Colors.white.withOpacity(0.5),
        foregroundColor: AppTheme.sunsetOrange,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }

  Widget _buildFeaturesSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 100),
      color: AppTheme.cream,
      child: Column(
        children: [
          Text(
            'Everything You Need to Explore',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Packed with features to make learning geography fun and engaging',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.midGray,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 60),
          Wrap(
            spacing: 40,
            runSpacing: 40,
            alignment: WrapAlignment.center,
            children: [
              _buildFeatureCard(
                context,
                '🌍',
                'Country Explorer',
                'Browse 250+ countries with detailed information including capitals, populations, languages, and more.',
              ),
              _buildFeatureCard(
                context,
                '🎮',
                'Interactive Quizzes',
                '3 quiz modes: Guess the Flag, Capital, or Region. Multiple difficulties and exciting gameplay.',
              ),
              _buildFeatureCard(
                context,
                '🏆',
                'Achievements',
                'Unlock 8 unique badges as you master world geography. Track your progress and high scores.',
              ),
              _buildFeatureCard(
                context,
                '📊',
                'Compare Countries',
                'Side-by-side comparison of any two countries with visual charts and detailed statistics.',
              ),
              _buildFeatureCard(
                context,
                '⚡',
                'Power-ups',
                '50/50, Skip, and Hint power-ups to help you succeed in challenging quizzes.',
              ),
              _buildFeatureCard(
                context,
                '🌐',
                'Multi-Language',
                'Available in English, French, and Spanish. Automatically detects your language.',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, String emoji, String title, String description) {
    return Container(
      width: 350,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 64)),
          const SizedBox(height: 20),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.midGray,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildScreenshotsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 100),
      color: Colors.white,
      child: Column(
        children: [
          Text(
            'Beautiful Design, Powerful Features',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 60),
          // Add screenshots here
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildScreenshot(context, 'Home'),
              const SizedBox(width: 40),
              _buildScreenshot(context, 'Quiz'),
              const SizedBox(width: 40),
              _buildScreenshot(context, 'Achievements'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScreenshot(BuildContext context, String label) {
    return Column(
      children: [
        Container(
          width: 250,
          height: 500,
          decoration: BoxDecoration(
            color: AppTheme.softGray,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: AppTheme.midGray, width: 2),
          ),
          child: Center(
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.midGray,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildDownloadSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 100),
      decoration: BoxDecoration(
        gradient: AppTheme.candyGradient,
      ),
      child: Column(
        children: [
          Text(
            'Ready to Start Exploring?',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(
            'Download GlobeHop now and begin your journey around the world!',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white.withOpacity(0.95),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDownloadButton(
                'Download on Play Store',
                Icons.android,
                () {
                  // Open Play Store link
                },
              ),
              const SizedBox(width: 16),
              _buildDownloadButton(
                'Coming to App Store',
                Icons.apple,
                null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 60),
      color: AppTheme.charcoal,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo and tagline
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/logo.png',
                          width: 40,
                          height: 40,
                          errorBuilder: (context, error, stackTrace) {
                            return const Text('🗺️', style: TextStyle(fontSize: 32));
                          },
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'GlobeHop',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Explore the world, one hop at a time!',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              // Links
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Links',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildFooterLink(context, 'Features'),
                    _buildFooterLink(context, 'Privacy Policy'),
                    _buildFooterLink(context, 'Terms of Service'),
                  ],
                ),
              ),
              // Contact
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contact',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'your.email@example.com',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'GitHub: @yourusername',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Divider(color: Colors.white.withOpacity(0.2)),
          const SizedBox(height: 20),
          Text(
            '© 2025 GlobeHop. All rights reserved. Made with ❤️ and Flutter',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFooterLink(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {},
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ),
    );
  }
}