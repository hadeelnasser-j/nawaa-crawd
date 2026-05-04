import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../extensions/localization_extension.dart';
import '../widgets/app_top_bar.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String searchQuery = '';
  String? activeCollection;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final places = appState.placesByCrowd;
    final locale = appState.locale;

    // Featured collections
    final collections = [
      {
        'id': 'quiet',
        'label': context.getString('quietPlaces'),
        'icon': Icons.spa_rounded,
        'description': context.getString('quietPlacesDesc'),
        'color': const Color(0xFF4CA8DA),
        'filter': (Place p) => p.crowdLevel == CrowdLevel.low,
      },
      {
        'id': 'trending',
        'label': context.getString('trendingPlaces'),
        'icon': Icons.local_fire_department_rounded,
        'description': context.getString('trendingPlacesDesc'),
        'color': const Color(0xFFE44E02),
        'filter': (Place p) =>
            p.crowdLevel == CrowdLevel.high ||
            p.crowdLevel == CrowdLevel.medium,
      },
      {
        'id': 'cafes',
        'label': context.getString('bestCafes'),
        'icon': Icons.local_cafe_rounded,
        'description': context.getString('bestCafesDesc'),
        'color': const Color(0xFF7076EB),
        'filter': (Place p) => p.category == 'cafe',
      },
    ];

    // Filter places by search or active collection
    final displayedPlaces = places.where((place) {
      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        return place.localizedName(locale).toLowerCase().contains(q) ||
            place.localizedAddress(locale).toLowerCase().contains(q);
      }
      if (activeCollection != null) {
        final col = collections.firstWhere((c) => c['id'] == activeCollection,
            orElse: () => {});
        if (col.isEmpty) return true;
        return (col['filter'] as bool Function(Place))(place);
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            AppTopBar(
              title: context.getString('exploreTitle'),
              subtitle: context.getString('exploreSubtitle'),
            ),

            // Search field
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: TextField(
                onChanged: (v) => setState(() => searchQuery = v),
                style: Theme.of(context).textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: context.getString('searchAreas'),
                  hintStyle: Theme.of(context).inputDecorationTheme.hintStyle,
                  prefixIcon: Icon(Icons.search,
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color
                          ?.withValues(alpha: 0.5)),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Colors.transparent),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Colors.transparent),
                  ),
                ),
              ),
            ),

            // Main content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 112),
                children: [
                  // Collections section
                  if (searchQuery.isEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.getString('collections'),
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        ...collections.map((c) {
                          final isActive = activeCollection == c['id'];
                          final color = c['color'] as Color;
                          return GestureDetector(
                            onTap: () => setState(() {
                              activeCollection =
                                  isActive ? null : c['id'] as String?;
                            }),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? color.withValues(alpha: 0.15)
                                    : Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isActive
                                      ? color.withValues(alpha: 0.4)
                                      : Colors.transparent,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    c['icon'] as IconData,
                                    color: color,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          c['label'] as String,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        Text(
                                          c['description'] as String,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                fontSize: 12,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      places
                                          .where((p) => (c['filter'] as bool
                                              Function(Place))(p))
                                          .length
                                          .toString(),
                                      style: TextStyle(
                                        color: color,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.sort_rounded,
                            color: Theme.of(context).primaryColor,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            context.getString('allPlaces'),
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (displayedPlaces.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Center(
                            child: Text(
                              context.getString('noResults'),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        )
                      else
                        ...displayedPlaces.map(
                          (place) => _PlaceTile(
                            place: place,
                            onTap: () {
                              appState.setSelectedPlace(place);
                              appState.goTo(AppScreen.placeDetails);
                            },
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceTile extends StatelessWidget {
  final Place place;
  final VoidCallback onTap;

  const _PlaceTile({
    required this.place,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = crowdColors(context, place.crowdLevel);
    final locale = context.watch<AppState>().locale;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.transparent),
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: colors.dot,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.localizedName(locale),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  Text(
                    place.localizedAddress(locale),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 12,
                        ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  crowdLabel(context, place.crowdLevel),
                  style: TextStyle(
                    color: colors.text,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  place.localizedWaitTime(locale),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                      ),
                ),
              ],
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.chevron_right,
              size: 18,
              color: Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}

// Helper to convert crowd level to Arabic label
String crowdLabel(BuildContext context, CrowdLevel level) {
  switch (level) {
    case CrowdLevel.low:
      return context.getString('lowCrowd');
    case CrowdLevel.medium:
      return context.getString('mediumCrowd');
    case CrowdLevel.high:
      return context.getString('highCrowd');
  }
}

// Helper model for crowd colors
class CrowdColors {
  final Color dot;
  final Color text;
  const CrowdColors(this.dot, this.text);
}

// Returns colors based on crowd level
CrowdColors crowdColors(BuildContext context, CrowdLevel level) {
  switch (level) {
    case CrowdLevel.low:
      return const CrowdColors(
        AppState.lowCrowdColor,
        AppState.lowCrowdColor,
      );
    case CrowdLevel.medium:
      return const CrowdColors(
        AppState.mediumCrowdColor,
        AppState.mediumCrowdColor,
      );
    case CrowdLevel.high:
      return const CrowdColors(
        AppState.highCrowdColor,
        AppState.highCrowdColor,
      );
  }
}
