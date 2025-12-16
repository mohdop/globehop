import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../config/theme.dart';
import '../providers/countries_provider.dart';
import '../models/country.dart';
import 'comparison_screen.dart';

class CountrySelectorScreen extends StatefulWidget {
  const CountrySelectorScreen({super.key});

  @override
  State<CountrySelectorScreen> createState() => _CountrySelectorScreenState();
}

class _CountrySelectorScreenState extends State<CountrySelectorScreen> {
  Country? _selectedCountry1;
  Country? _selectedCountry2;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compare Countries'),
      ),
      body: Consumer<CountriesProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final filteredCountries = provider.allCountries.where((country) {
            return _searchQuery.isEmpty ||
                country.name.toLowerCase().contains(_searchQuery.toLowerCase());
          }).toList();

          return Column(
            children: [
              // Selection Header
              _buildSelectionHeader(),
              
              // Search bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search countries...',
                    prefixIcon: const Icon(Icons.search, color: AppTheme.midGray),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                  ),
                ),
              ),

              // Country list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredCountries.length,
                  itemBuilder: (context, index) {
                    final country = filteredCountries[index];
                    final isSelected1 = _selectedCountry1?.cca3 == country.cca3;
                    final isSelected2 = _selectedCountry2?.cca3 == country.cca3;
                    final isDisabled = (_selectedCountry1?.cca3 == country.cca3 && _selectedCountry2 != null) ||
                                      (_selectedCountry2?.cca3 == country.cca3 && _selectedCountry1 != null);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      color: isSelected1 
                          ? AppTheme.sunsetOrange.withOpacity(0.1)
                          : isSelected2
                              ? AppTheme.bubblegumPink.withOpacity(0.1)
                              : null,
                      child: ListTile(
                        enabled: !isDisabled,
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: country.flagPng,
                            width: 60,
                            height: 40,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              width: 60,
                              height: 40,
                              color: AppTheme.softGray,
                              child: Center(
                                child: Text(
                                  country.flag,
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          country.name,
                          style: TextStyle(
                            fontWeight: (isSelected1 || isSelected2) 
                                ? FontWeight.bold 
                                : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(country.capital),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isSelected1)
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.sunsetOrange,
                                  shape: BoxShape.circle,
                                ),
                                child: const Text(
                                  '1',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            if (isSelected2)
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.bubblegumPink,
                                  shape: BoxShape.circle,
                                ),
                                child: const Text(
                                  '2',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        onTap: () {
                          setState(() {
                            if (_selectedCountry1 == null) {
                              _selectedCountry1 = country;
                            } else if (_selectedCountry2 == null && 
                                      _selectedCountry1?.cca3 != country.cca3) {
                              _selectedCountry2 = country;
                            } else if (_selectedCountry1?.cca3 == country.cca3) {
                              _selectedCountry1 = _selectedCountry2;
                              _selectedCountry2 = null;
                            } else if (_selectedCountry2?.cca3 == country.cca3) {
                              _selectedCountry2 = null;
                            }
                          });
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
      floatingActionButton: _selectedCountry1 != null && _selectedCountry2 != null
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ComparisonScreen(
                      country1: _selectedCountry1!,
                      country2: _selectedCountry2!,
                    ),
                  ),
                );
              },
              backgroundColor: AppTheme.grapePurple,
              icon: const Icon(Icons.compare_arrows),
              label: const Text('Compare'),
            )
          : null,
    );
  }

  Widget _buildSelectionHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.candyGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Text(
            'Select 2 Countries',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSelectionBox(
                  context,
                  '1',
                  _selectedCountry1,
                  AppTheme.sunsetOrange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSelectionBox(
                  context,
                  '2',
                  _selectedCountry2,
                  AppTheme.bubblegumPink,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionBox(
    BuildContext context,
    String number,
    Country? country,
    Color color,
  ) {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 3),
      ),
      child: country == null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    number,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap to select',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.midGray,
                  ),
                ),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  country.flag,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(height: 4),
                Text(
                  country.name,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
    );
  }
}