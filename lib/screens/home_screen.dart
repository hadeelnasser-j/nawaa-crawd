import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../widgets/map_preview.dart';
import '../extensions/localization_extension.dart';
import '../widgets/app_top_bar.dart';

final categories = [
  'all',
  'cafe',
  'restaurant',
  'hospital',
  'mall',
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String searchQuery = '';
  String activeCategory = 'all';

  Color crowdColor(CrowdLevel level) {
    switch (level) {
      case CrowdLevel.low:
        return AppState.lowCrowdColor;
      case CrowdLevel.medium:
        return AppState.mediumCrowdColor;
      case CrowdLevel.high:
        return AppState.highCrowdColor;
    }
  }

  String crowdLabel(CrowdLevel level) {
    switch (level) {
      case CrowdLevel.low:
        return context.getString('lowCrowd');
      case CrowdLevel.medium:
        return context.getString('mediumCrowd');
      case CrowdLevel.high:
        return context.getString('highCrowd');
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final locale = appState.locale;

    // 🔥 فلترة احترافية (بحث + كاتيجوري)
    final filteredPlaces = appState.places.where((place) {
      final name = place.localizedName(locale).toLowerCase();
      final address = place.localizedAddress(locale).toLowerCase();
      final query = searchQuery.toLowerCase();

      final matchesSearch =
          searchQuery.isEmpty || name.contains(query) || address.contains(query);

      final matchesCategory =
          activeCategory == 'all' || place.category == activeCategory;

      return matchesSearch && matchesCategory;
    }).toList();

    final bestPlace = appState.nawaaSuggestion;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTopBar(
              title: context.formatString(
                'greetingUser',
                {'name': appState.userName},
              ),
            ),

            /* ===== Search ===== */
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                onChanged: (v) {
                  setState(() => searchQuery = v);
                },
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: context.getString('searchPlaces'),
                ),
              ),
            ),
            const SizedBox(height: 12),

            /* ===== Categories ===== */
            SizedBox(
              height: 36,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final cat = categories[i];
                  final isActive = cat == activeCategory;

                  return ChoiceChip(
                    label: Text(context.getString(cat)),
                    selected: isActive,
                    onSelected: (_) {
                      setState(() => activeCategory = cat);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            /* ===== AI Suggestion ===== */
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GestureDetector(
                onTap: () {
                  appState.setSelectedPlace(bestPlace);
                  appState.goTo(AppScreen.placeDetails);
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      Colors.indigo.withOpacity(0.2),
                      Colors.blue.withOpacity(0.2),
                    ]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.flash_on, color: Colors.indigo),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${context.getString('aiSuggestion')}: ${bestPlace.localizedName(locale)}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            /* ===== MAP (🔥 هنا السحر) ===== */
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: MapPreview(
                places: filteredPlaces, // 🔥 أهم سطر
              ),
            ),

            /* ===== List ===== */
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 112),
                itemCount: filteredPlaces.length,
                itemBuilder: (_, i) {
                  final place = filteredPlaces[i];

                  return GestureDetector(
                    onTap: () {
                      appState.setSelectedPlace(place);
                      appState.goTo(AppScreen.placeDetails);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: crowdColor(place.crowdLevel),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  place.localizedName(locale),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(fontSize: 14),
                                ),
                                Text(
                                  place.localizedAddress(locale),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(fontSize: 12),
                                ),
                              ],
                            ),
                          ),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                crowdLabel(place.crowdLevel),
                                style: TextStyle(
                                  color: crowdColor(place.crowdLevel),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                place.localizedWaitTime(locale),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(fontSize: 11),
                              ),
                            ],
                          ),

                          const Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}