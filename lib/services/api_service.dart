import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/country.dart';

class ApiService {
  static const String baseUrl = 'https://restcountries.com/v3.1';

  // Fetch all countries
  Future<List<Country>> getAllCountries() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/all'),
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      print('📡 Response Status: ${response.statusCode}');
      print('📡 Response Body Length: ${response.body.length}');
      
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        print('✅ Loaded ${data.length} countries');
        return data.map((json) => Country.fromJson(json)).toList();
      } else {
        print('❌ Status ${response.statusCode}: ${response.body}');
        throw Exception('Failed to load countries: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 Exception: $e');
      throw Exception('Error fetching countries: $e');
    }
  }

  // Fetch countries by region
  Future<List<Country>> getCountriesByRegion(String region) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/region/$region'),
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Country.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load countries by region');
      }
    } catch (e) {
      throw Exception('Error fetching countries by region: $e');
    }
  }

  // Search countries by name
  Future<List<Country>> searchCountries(String query) async {
    if (query.isEmpty) {
      return getAllCountries();
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/name/$query'),
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Country.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        return []; // No countries found
      } else {
        throw Exception('Failed to search countries');
      }
    } catch (e) {
      if (e.toString().contains('404')) {
        return [];
      }
      throw Exception('Error searching countries: $e');
    }
  }

  // Get country by code
  Future<Country> getCountryByCode(String code) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/alpha/$code'),
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return Country.fromJson(data[0]);
      } else {
        throw Exception('Failed to load country');
      }
    } catch (e) {
      throw Exception('Error fetching country: $e');
    }
  }

  // Available regions
  static List<String> get regions => [
        'All',
        'Africa',
        'Americas',
        'Asia',
        'Europe',
        'Oceania',
      ];
}