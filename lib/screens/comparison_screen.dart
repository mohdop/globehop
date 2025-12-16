import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../config/theme.dart';
import '../models/country.dart';
import 'dart:math' as math;

class ComparisonScreen extends StatelessWidget {
  final Country country1;
  final Country country2;

  const ComparisonScreen({
    super.key,
    required this.country1,
    required this.country2,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Country Comparison'),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ComparisonScreen(
                    country1: country2,
                    country2: country1,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeaderComparison(context),
            _buildPopulationComparison(context),
            _buildAreaComparison(context),
            _buildInfoGrid(context),
            _buildLanguagesComparison(context),
            _buildCurrenciesComparison(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderComparison(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildCountryHeader(context, country1, AppTheme.sunsetOrange),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: AppTheme.candyGradient,
              shape: BoxShape.circle,
            ),
            child: const Text(
              'VS',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          Expanded(
            child: _buildCountryHeader(context, country2, AppTheme.bubblegumPink),
          ),
        ],
      ),
    );
  }

  Widget _buildCountryHeader(BuildContext context, Country country, Color accentColor) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: CachedNetworkImage(
              imageUrl: country.flagPng,
              height: 100,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 100,
                color: AppTheme.softGray,
                child: Center(
                  child: Text(country.flag, style: const TextStyle(fontSize: 48)),
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              border: Border(
                top: BorderSide(color: accentColor, width: 3),
              ),
            ),
            child: Column(
              children: [
                Text(
                  country.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  country.capital,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.midGray,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopulationComparison(BuildContext context) {
    final max = math.max(country1.population, country2.population).toDouble();
    final ratio1 = country1.population / max;
    final ratio2 = country2.population / max;
    
    return _buildComparisonSection(
      context,
      title: 'Population',
      emoji: '👥',
      leftValue: country1.formattedPopulation,
      rightValue: country2.formattedPopulation,
      leftRatio: ratio1,
      rightRatio: ratio2,
      leftColor: AppTheme.sunsetOrange,
      rightColor: AppTheme.bubblegumPink,
      winner: country1.population > country2.population ? 'left' : 'right',
    );
  }

  Widget _buildAreaComparison(BuildContext context) {
    final max = math.max(country1.area, country2.area);
    final ratio1 = country1.area / max;
    final ratio2 = country2.area / max;
    
    return _buildComparisonSection(
      context,
      title: 'Land Area',
      emoji: '🗺️',
      leftValue: country1.formattedArea,
      rightValue: country2.formattedArea,
      leftRatio: ratio1,
      rightRatio: ratio2,
      leftColor: AppTheme.mangoYellow,
      rightColor: AppTheme.grapePurple,
      winner: country1.area > country2.area ? 'left' : 'right',
    );
  }

  Widget _buildComparisonSection(
    BuildContext context, {
    required String title,
    required String emoji,
    required String leftValue,
    required String rightValue,
    required double leftRatio,
    required double rightRatio,
    required Color leftColor,
    required Color rightColor,
    required String winner,
  }) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      leftValue,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: leftColor,
                      ),
                    ),
                    if (winner == 'left')
                      const Text('👑', style: TextStyle(fontSize: 20)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      rightValue,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: rightColor,
                      ),
                    ),
                    if (winner == 'right')
                      const Text('👑', style: TextStyle(fontSize: 20)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: (leftRatio * 100).round(),
                child: Container(
                  height: 30,
                  decoration: BoxDecoration(
                    color: leftColor,
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(15),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${(leftRatio * 100).round()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: (rightRatio * 100).round(),
                child: Container(
                  height: 30,
                  decoration: BoxDecoration(
                    color: rightColor,
                    borderRadius: const BorderRadius.horizontal(
                      right: Radius.circular(15),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${(rightRatio * 100).round()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoGrid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  context,
                  '🌍',
                  'Region',
                  country1.region,
                  country2.region,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoCard(
                  context,
                  '🗺️',
                  'Subregion',
                  country1.subregion,
                  country2.subregion,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  context,
                  '🌐',
                  'Continents',
                  country1.continents.join(', '),
                  country2.continents.join(', '),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String emoji,
    String title,
    String value1,
    String value2,
  ) {
    final isSame = value1 == value2;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (isSame) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.limeZest.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.limeZest, width: 2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle, color: AppTheme.limeZest, size: 16),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        value1,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Text(
                value1,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              const Text('vs', style: TextStyle(color: AppTheme.midGray, fontSize: 10)),
              const SizedBox(height: 4),
              Text(
                value2,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLanguagesComparison(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('💬', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Text(
                'Languages',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  alignment: WrapAlignment.center,
                  children: country1.languages.map((lang) {
                    final isCommon = country2.languages.contains(lang);
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isCommon 
                            ? AppTheme.limeZest.withOpacity(0.2)
                            : AppTheme.sunsetOrange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isCommon ? AppTheme.limeZest : AppTheme.sunsetOrange,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        lang,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  alignment: WrapAlignment.center,
                  children: country2.languages.map((lang) {
                    final isCommon = country1.languages.contains(lang);
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isCommon 
                            ? AppTheme.limeZest.withOpacity(0.2)
                            : AppTheme.bubblegumPink.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isCommon ? AppTheme.limeZest : AppTheme.bubblegumPink,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        lang,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrenciesComparison(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('💰', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Text(
                'Currencies',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: country1.currencies.map((curr) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: AppTheme.sunsetGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        curr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: country2.currencies.map((curr) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: AppTheme.candyGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        curr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}