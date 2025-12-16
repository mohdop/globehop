import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/country.dart';
import '../services/api_service.dart';

class CountriesProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Country> _allCountries = [];
  List<Country> _displayedCountries = [];
  List<String> _favoriteCountryCodes = [];
  
  bool _isLoading = false;
  String? _error;
  String _selectedRegion = 'All';
  String _searchQuery = '';

  // Getters
  List<Country> get allCountries => _allCountries;
  List<Country> get displayedCountries => _displayedCountries;
  List<Country> get favoriteCountries => _allCountries
      .where((country) => _favoriteCountryCodes.contains(country.cca3))
      .toList();
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedRegion => _selectedRegion;
  String get searchQuery => _searchQuery;
  
  bool isFavorite(String countryCode) {
    return _favoriteCountryCodes.contains(countryCode);
  }

  // Initialize and load countries
  Future<void> loadCountries() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Fetch countries from all regions (API /all endpoint has restrictions)
      final regions = ['Africa', 'Americas', 'Asia', 'Europe', 'Oceania'];
      List<Country> allCountries = [];
      
      for (String region in regions) {
        final countries = await _apiService.getCountriesByRegion(region);
        allCountries.addAll(countries);
      }
      
      _allCountries = allCountries;
      // Sort alphabetically by default
      _allCountries.sort((a, b) => a.name.compareTo(b.name));
      _displayedCountries = List.from(_allCountries);
      await _loadFavorites();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      debugPrint('❌ ERROR LOADING COUNTRIES: $e');
      notifyListeners();
    }
  }

  // Filter by region
  void filterByRegion(String region) {
    _selectedRegion = region;
    _applyFilters();
  }

  // Search countries
  void searchCountries(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
  }

  // Apply both search and region filters
  void _applyFilters() {
    _displayedCountries = _allCountries.where((country) {
      bool matchesRegion = _selectedRegion == 'All' || 
                          country.region == _selectedRegion;
      bool matchesSearch = _searchQuery.isEmpty ||
                          country.name.toLowerCase().contains(_searchQuery) ||
                          country.capital.toLowerCase().contains(_searchQuery);
      return matchesRegion && matchesSearch;
    }).toList();
    notifyListeners();
  }

  // Toggle favorite
  Future<void> toggleFavorite(String countryCode) async {
    if (_favoriteCountryCodes.contains(countryCode)) {
      _favoriteCountryCodes.remove(countryCode);
    } else {
      _favoriteCountryCodes.add(countryCode);
    }
    await _saveFavorites();
    notifyListeners();
  }

  // Load favorites from local storage
  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getString('favorites');
      if (favoritesJson != null) {
        _favoriteCountryCodes = List<String>.from(json.decode(favoritesJson));
      }
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    }
  }

  // Save favorites to local storage
  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('favorites', json.encode(_favoriteCountryCodes));
    } catch (e) {
      debugPrint('Error saving favorites: $e');
    }
  }

  // Sort countries
  void sortCountries(String sortBy) {
    switch (sortBy) {
      case 'name':
        _displayedCountries.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'population':
        _displayedCountries.sort((a, b) => b.population.compareTo(a.population));
        break;
      case 'area':
        _displayedCountries.sort((a, b) => b.area.compareTo(a.area));
        break;
    }
    notifyListeners();
  }

  // Reset filters
  void resetFilters() {
    _selectedRegion = 'All';
    _searchQuery = '';
    _displayedCountries = List.from(_allCountries);
    notifyListeners();
  }
}