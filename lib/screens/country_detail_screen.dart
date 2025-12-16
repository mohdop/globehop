import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../models/country.dart';
import '../providers/countries_provider.dart';
import 'comparison_screen.dart';

class CountryDetailScreen extends StatelessWidget {
  final Country country;

  const CountryDetailScreen({
    super.key,
    required this.country,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar with flag
          _buildSliverAppBar(context),
          
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCountryName(context),
                  const SizedBox(height: 24),
                  _buildInfoSection(context),
                  const SizedBox(height: 24),
                  _buildLanguagesSection(context),
                  const SizedBox(height: 24),
                  _buildAdditionalInfo(context),
                  const SizedBox(height: 24),
                  _buildCompareButton(context),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompareButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          _showCountrySelector(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.grapePurple,
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: const Icon(Icons.compare_arrows),
        label: const Text('Compare with Another Country'),
      ),
    );
  }

  void _showCountrySelector(BuildContext context) {
    final countriesProvider = context.read<CountriesProvider>();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.cream,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.midGray,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Compare ${country.name} with...',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: countriesProvider.allCountries.length,
                  itemBuilder: (context, index) {
                    final otherCountry = countriesProvider.allCountries[index];
                    if (otherCountry.cca3 == country.cca3) {
                      return const SizedBox.shrink();
                    }
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Text(
                          otherCountry.flag,
                          style: const TextStyle(fontSize: 32),
                        ),
                        title: Text(otherCountry.name),
                        subtitle: Text(otherCountry.capital),
                        trailing: const Icon(Icons.arrow_forward),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ComparisonScreen(
                                country1: country,
                                country2: otherCountry,
                              ),
                            ),
                          );
                        },
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

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: country.flagPng,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: AppTheme.softGray,
                child: Center(
                  child: Text(
                    country.flag,
                    style: const TextStyle(fontSize: 120),
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: AppTheme.softGray,
                child: Center(
                  child: Text(
                    country.flag,
                    style: const TextStyle(fontSize: 120),
                  ),
                ),
              ),
            ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        Consumer<CountriesProvider>(
          builder: (context, provider, child) {
            final isFav = provider.isFavorite(country.cca3);
            return IconButton(
              icon: Icon(
                isFav ? Icons.favorite : Icons.favorite_border,
                color: isFav ? AppTheme.bubblegumPink : Colors.white,
              ),
              onPressed: () {
                provider.toggleFavorite(country.cca3);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildCountryName(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          country.name,
          style: Theme.of(context).textTheme.displayLarge,
        ),
        const SizedBox(height: 4),
        Text(
          country.officialName,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppTheme.midGray,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.sunsetGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.sunsetOrange.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(
            context,
            Icons.location_city,
            'Capital',
            country.capital,
          ),
          const Divider(color: Colors.white54, height: 24),
          _buildInfoRow(
            context,
            Icons.people,
            'Population',
            country.formattedPopulation,
          ),
          const Divider(color: Colors.white54, height: 24),
          _buildInfoRow(
            context,
            Icons.landscape,
            'Area',
            country.formattedArea,
          ),
          const Divider(color: Colors.white54, height: 24),
          _buildInfoRow(
            context,
            Icons.public,
            'Region',
            '${country.region} - ${country.subregion}',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppTheme.cream, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppTheme.cream.withOpacity(0.8),
                ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.cream,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLanguagesSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.language, color: AppTheme.grapePurple),
              const SizedBox(width: 8),
              Text(
                'Languages',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: country.languages.map((language) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  gradient: AppTheme.candyGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  language,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.cream,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfo(BuildContext context) {
    return Column(
      children: [
        _buildInfoCard(
          context,
          'Currencies',
          Icons.monetization_on,
          country.currencies.join(', '),
          AppTheme.limeZest,
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          context,
          'Continents',
          Icons.map,
          country.continents.join(', '),
          AppTheme.mangoYellow,
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          context,
          'Timezones',
          Icons.access_time,
          country.timezones.first,
          AppTheme.coralBlush,
        ),
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, IconData icon, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}