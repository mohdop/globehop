import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/countries_provider.dart';
import '../providers/quiz_provider.dart';
import '../services/api_service.dart';
import '../widgets/country_card.dart';
import '../widgets/loading_shimmer.dart';
import '../models/quiz_question.dart';
import '../l10n/app_localizations.dart';
import 'country_detail_screen.dart';
import 'quiz_screen.dart';
import 'quiz_history_screen.dart';
import 'achievements_screen.dart';
import 'country_selector_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  QuizType _selectedQuizType = QuizType.flag; // Initialize here

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header with logo and title
            _buildHeader(),
            
            // Search bar
            _buildSearchBar(),
            
            // Region filters
            _buildRegionFilters(),
            
            // Countries list
            Expanded(
              child: _buildCountriesList(),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: 'compare',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CountrySelectorScreen(),
                ),
              );
            },
            backgroundColor: AppTheme.grapePurple,
            icon: const Icon(Icons.compare_arrows),
            label: const Text('Compare'),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'quiz',
            onPressed: () => _startQuiz(context),
            backgroundColor: AppTheme.bubblegumPink,
            icon: const Icon(Icons.quiz),
            label: const Text('Quiz Mode'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.sunsetGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // History button
              IconButton(
                icon: const Icon(Icons.history, color: AppTheme.cream),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const QuizHistoryScreen(),
                    ),
                  );
                },
              ),
              // Logo and title
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Your actual logo
                    Image.asset(
                      'assets/images/GLOBEHOP_NO_BG512.png',
                      width: 40,
                      height: 40,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback to emoji if logo not found
                        return const Text(
                          '🗺️',
                          style: TextStyle(fontSize: 32),
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'GlobeHop',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: AppTheme.cream,
                        fontSize: 32,
                      ),
                    ),
                  ],
                ),
              ),
              // Achievements button
              IconButton(
                icon: const Icon(Icons.emoji_events, color: AppTheme.cream),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AchievementsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Explore the world, one hop at a time!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.cream,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          context.read<CountriesProvider>().searchCountries(value);
        },
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context).searchCountries,
          prefixIcon: const Icon(Icons.search, color: AppTheme.midGray),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    context.read<CountriesProvider>().searchCountries('');
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildRegionFilters() {
    return Consumer<CountriesProvider>(
      builder: (context, provider, child) {
        return SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: ApiService.regions.length,
            itemBuilder: (context, index) {
              final region = ApiService.regions[index];
              final isSelected = provider.selectedRegion == region;
              
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(region),
                  selected: isSelected,
                  onSelected: (selected) {
                    provider.filterByRegion(region);
                  },
                  backgroundColor: AppTheme.cream,
                  selectedColor: AppTheme.sunsetOrange,
                  labelStyle: TextStyle(
                    color: isSelected ? AppTheme.cream : AppTheme.charcoal,
                    fontWeight: FontWeight.w600,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected ? AppTheme.sunsetOrange : AppTheme.softGray,
                      width: 2,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCountriesList() {
    return Consumer<CountriesProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const LoadingShimmer();
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppTheme.midGray,
                ),
                const SizedBox(height: 16),
                Text(
                  'Oops! Something went wrong',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    provider.error ?? 'Unknown error',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please try again',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => provider.loadCountries(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (provider.displayedCountries.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '🔍',
                  style: const TextStyle(fontSize: 64),
                ),
                const SizedBox(height: 16),
                Text(
                  'No countries found',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Try a different search',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: provider.displayedCountries.length,
          itemBuilder: (context, index) {
            final country = provider.displayedCountries[index];
            return CountryCard(
              country: country,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CountryDetailScreen(country: country),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _startQuiz(BuildContext context) {
    final countriesProvider = context.read<CountriesProvider>();

    if (countriesProvider.allCountries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please wait for countries to load...'),
          backgroundColor: AppTheme.sunsetOrange,
        ),
      );
      return;
    }

    // Reset quiz type selection when dialog opens
    setState(() {
      _selectedQuizType = QuizType.flag;
    });

    // Show quiz type and difficulty selection
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                const Text('🎯'),
                const SizedBox(width: 8),
                const Text('Choose Quiz Mode'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quiz Type:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildQuizTypeOption(context, setDialogState, '🏁', 'Guess the Flag', QuizType.flag),
                  const SizedBox(height: 8),
                  _buildQuizTypeOption(context, setDialogState, '🏛️', 'Guess the Capital', QuizType.capital),
                  const SizedBox(height: 8),
                  _buildQuizTypeOption(context, setDialogState, '🌍', 'Guess the Region', QuizType.region),
                  const SizedBox(height: 16),
                  Text(
                    'Difficulty:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDifficultyOption(
                    context,
                    '🌱 Easy',
                    '5 questions',
                    5,
                    AppTheme.limeZest,
                  ),
                  const SizedBox(height: 8),
                  _buildDifficultyOption(
                    context,
                    '⚡ Medium',
                    '10 questions',
                    10,
                    AppTheme.mangoYellow,
                  ),
                  const SizedBox(height: 8),
                  _buildDifficultyOption(
                    context,
                    '🔥 Hard',
                    '15 questions',
                    15,
                    AppTheme.sunsetOrange,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuizTypeOption(
    BuildContext context, 
    StateSetter setDialogState,
    String emoji, 
    String title, 
    QuizType type,
  ) {
    final isSelected = _selectedQuizType == type;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedQuizType = type;
        });
        setDialogState(() {
          _selectedQuizType = type;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.sunsetOrange.withOpacity(0.1) : null,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.sunsetOrange : AppTheme.softGray,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppTheme.sunsetOrange),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyOption(
    BuildContext context,
    String title,
    String subtitle,
    int questions,
    Color color,
  ) {
    return InkWell(
      onTap: () {
        final countriesProvider = context.read<CountriesProvider>();
        final quizProvider = context.read<QuizProvider>();
        
        // Close difficulty dialog
        Navigator.pop(context);
        
        // Generate quiz immediately with selected type
        quizProvider.generateQuiz(
          countriesProvider.allCountries,
          numberOfQuestions: questions,
          type: _selectedQuizType,
          difficulty: title,
        );
        
        // Navigate to quiz screen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const QuizScreen()),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.midGray,
              ),
            ),
          ],
        ),
      ),
    );
  }
}