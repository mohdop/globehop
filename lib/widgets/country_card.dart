import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../models/country.dart';
import '../providers/countries_provider.dart';

class CountryCard extends StatelessWidget {
  final Country country;
  final VoidCallback onTap;

  const CountryCard({
    super.key,
    required this.country,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Flag image
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  // Flag
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppTheme.softGray,
                    ),
                    child: CachedNetworkImage(
                      imageUrl: country.flagPng,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppTheme.softGray,
                        child: Center(
                          child: Text(
                            country.flag,
                            style: const TextStyle(fontSize: 48),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppTheme.softGray,
                        child: Center(
                          child: Text(
                            country.flag,
                            style: const TextStyle(fontSize: 48),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Favorite button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Consumer<CountriesProvider>(
                      builder: (context, provider, child) {
                        final isFav = provider.isFavorite(country.cca3);
                        return GestureDetector(
                          onTap: () {
                            provider.toggleFavorite(country.cca3);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              color: isFav ? AppTheme.bubblegumPink : AppTheme.midGray,
                              size: 20,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Country info
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Country name
                    Text(
                      country.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 14,
                        height: 1.1,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    // Capital and Population
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Capital
                        Row(
                          children: [
                            const Icon(
                              Icons.location_city,
                              size: 11,
                              color: AppTheme.midGray,
                            ),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                country.capital,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.midGray,
                                  fontSize: 10,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 1),
                        // Population
                        Row(
                          children: [
                            const Icon(
                              Icons.people,
                              size: 11,
                              color: AppTheme.midGray,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              country.formattedPopulation,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.midGray,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}