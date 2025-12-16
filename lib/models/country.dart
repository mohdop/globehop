class Country {
  final String name;
  final String officialName;
  final String capital;
  final String region;
  final String subregion;
  final int population;
  final double area;
  final String flag; // Emoji flag
  final String flagPng; // PNG image URL
  final String flagSvg; // SVG image URL
  final List<String> languages;
  final List<String> currencies;
  final Map<String, dynamic> coatOfArms;
  final String? googleMaps;
  final List<String> timezones;
  final Map<String, String> translations;
  final List<String> continents;
  final String cca2; // 2-letter country code
  final String cca3; // 3-letter country code

  Country({
    required this.name,
    required this.officialName,
    required this.capital,
    required this.region,
    required this.subregion,
    required this.population,
    required this.area,
    required this.flag,
    required this.flagPng,
    required this.flagSvg,
    required this.languages,
    required this.currencies,
    required this.coatOfArms,
    this.googleMaps,
    required this.timezones,
    required this.translations,
    required this.continents,
    required this.cca2,
    required this.cca3,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    // Extract languages
    List<String> languagesList = [];
    if (json['languages'] != null) {
      Map<String, dynamic> langs = json['languages'];
      languagesList = langs.values.cast<String>().toList();
    }

    // Extract currencies
    List<String> currenciesList = [];
    if (json['currencies'] != null) {
      Map<String, dynamic> currs = json['currencies'];
      currenciesList = currs.keys.toList();
    }

    // Extract capital (can be multiple)
    String capital = 'N/A';
    if (json['capital'] != null && json['capital'].isNotEmpty) {
      capital = json['capital'][0];
    }

    // Extract translations
    Map<String, String> translationsMap = {};
    if (json['translations'] != null) {
      Map<String, dynamic> trans = json['translations'];
      trans.forEach((key, value) {
        if (value['common'] != null) {
          translationsMap[key] = value['common'];
        }
      });
    }

    return Country(
      name: json['name']['common'] ?? 'Unknown',
      officialName: json['name']['official'] ?? 'Unknown',
      capital: capital,
      region: json['region'] ?? 'Unknown',
      subregion: json['subregion'] ?? 'Unknown',
      population: json['population'] ?? 0,
      area: (json['area'] ?? 0).toDouble(),
      flag: json['flag'] ?? '🏳️',
      flagPng: json['flags']['png'] ?? '',
      flagSvg: json['flags']['svg'] ?? '',
      languages: languagesList,
      currencies: currenciesList,
      coatOfArms: json['coatOfArms'] ?? {},
      googleMaps: json['maps']?['googleMaps'],
      timezones: List<String>.from(json['timezones'] ?? []),
      translations: translationsMap,
      continents: List<String>.from(json['continents'] ?? []),
      cca2: json['cca2'] ?? '',
      cca3: json['cca3'] ?? '',
    );
  }

  // Helper method to format population
  String get formattedPopulation {
    if (population >= 1000000) {
      return '${(population / 1000000).toStringAsFixed(1)}M';
    } else if (population >= 1000) {
      return '${(population / 1000).toStringAsFixed(1)}K';
    }
    return population.toString();
  }

  // Helper method to format area
  String get formattedArea {
    return '${area.toStringAsFixed(0)} km²';
  }

  // Get primary language
  String get primaryLanguage {
    return languages.isNotEmpty ? languages.first : 'N/A';
  }

  // Get all languages as string
  String get languagesString {
    return languages.join(', ');
  }
}