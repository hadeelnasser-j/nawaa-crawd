import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_state.dart';
import '../extensions/localization_extension.dart';
import '../widgets/premium_feature_tile.dart';

/* ===== Screen ===== */

class PlaceDetailsScreen extends StatefulWidget {
  const PlaceDetailsScreen({super.key});

  @override
  State<PlaceDetailsScreen> createState() => _PlaceDetailsScreenState();
}

class _PlaceDetailsScreenState extends State<PlaceDetailsScreen> {
  bool notifySet = false;

  static const Map<String, List<double>> placeCoordinates = {
    'starbucks-salamah': [21.5740, 39.1575],
    'costa-salamah': [21.5762, 39.1538],
    'aziz-mall': [21.5655, 39.1843],
    'albaik-faisaliyah': [21.5674, 39.1840],
    'king-fahd-hospital': [21.5608, 39.1904],
    'starbucks-obhur-mall': [21.7178, 39.1060],
    'costa-red-sea-mall': [21.6278, 39.1116],
    'red-sea-mall': [21.6274, 39.1112],
    'albaik-shati': [21.6040, 39.1150],
    'fakeeh-hospital': [21.5292, 39.1826],
  };

  Future<void> openPlaceInGoogleMaps(Place place) async {
    final coords = placeCoordinates[place.id];

    final url = coords != null
        ? Uri.parse(
            'https://www.google.com/maps/search/?api=1&query=${coords[0]},${coords[1]}',
          )
        : Uri.parse(
            'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(place.name)}',
          );

    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  Color levelColor(CrowdLevel level) {
    switch (level) {
      case CrowdLevel.low:
        return AppState.lowCrowdColor;
      case CrowdLevel.medium:
        return AppState.mediumCrowdColor;
      case CrowdLevel.high:
        return AppState.highCrowdColor;
    }
  }

  String levelLabel(CrowdLevel level) {
    switch (level) {
      case CrowdLevel.low:
        return context.getString('lowCrowd');
      case CrowdLevel.medium:
        return context.getString('mediumCrowd');
      case CrowdLevel.high:
        return context.getString('highCrowd');
    }
  }

  String liveStatusLabel(CrowdLevel level) {
    switch (level) {
      case CrowdLevel.low:
        return context.getString('quietNow');
      case CrowdLevel.medium:
        return context.getString('moderateNow');
      case CrowdLevel.high:
        return context.getString('busyNow');
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final locale = appState.locale;
    final place = appState.selectedPlace;

    if (place == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        appState.goTo(AppScreen.home);
      });
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    onPressed: () {
                      appState.goTo(AppScreen.home);
                    },
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.getString('placeDetails'),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 18,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          place.localizedName(locale),
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_pin,
                              size: 16,
                              color: Theme.of(context)
                                  .iconTheme
                                  .color
                                  ?.withValues(alpha: 0.6),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                place.localizedAddress(locale),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color
                                          ?.withValues(alpha: 0.6),
                                    ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: levelColor(place.crowdLevel)
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                levelLabel(place.crowdLevel),
                                style: TextStyle(
                                  color: levelColor(place.crowdLevel),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 16,
                                  color: Theme.of(context)
                                      .iconTheme
                                      .color
                                      ?.withValues(alpha: 0.6),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  place.localizedWaitTime(locale),
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 16,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  place.rating.toString(),
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.getString('basicInfoFree'),
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _InfoValue(
                                label: context.getString('crowdInfo'),
                                value: levelLabel(place.crowdLevel),
                              ),
                            ),
                            Expanded(
                              child: _InfoValue(
                                label: context.getString('liveStatus'),
                                value: liveStatusLabel(place.crowdLevel),
                              ),
                            ),
                            Icon(
                              Icons.monitor_heart_outlined,
                              color: levelColor(place.crowdLevel),
                              size: 34,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.getString('premiumFeatures'),
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.amber,
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        PremiumFeatureTile(
                          title: context.getString('bestTimeToVisitFeature'),
                          icon: Icons.alarm_rounded,
                          isLocked: !appState.isPremiumUser,
                          value: place.localizedBestTimeToVisit(locale),
                          onTap: appState.isPremiumUser
                              ? null
                              : appState.openPremium,
                        ),
                        const Divider(height: 1),
                        PremiumFeatureTile(
                          title: context.getString('estimatedWaitTime'),
                          icon: Icons.timer_outlined,
                          isLocked: !appState.isPremiumUser,
                          value: place.localizedWaitTime(locale),
                          onTap: appState.isPremiumUser
                              ? null
                              : appState.openPremium,
                        ),
                        const Divider(height: 1),
                        PremiumFeatureTile(
                          title: context.getString('aiPredictionShort'),
                          icon: Icons.psychology_alt_outlined,
                          isLocked: !appState.isPremiumUser,
                          onTap: appState.isPremiumUser
                              ? () => appState.goTo(AppScreen.aiPrediction)
                              : appState.openPremium,
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => openPlaceInGoogleMaps(place),
                          icon: const Icon(Icons.navigation),
                          label: Text(context.getString('directions')),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            minimumSize: const Size.fromHeight(48),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            if (!appState.isPremiumUser) {
                              appState.openPremium();
                              return;
                            }
                            setState(() => notifySet = true);
                            appState.addPlaceNotification(
                              place: place,
                              message: 'greatTimeToVisit',
                              type: NotificationType.success,
                              time: 'now',
                            );
                          },
                          icon: Icon(
                            appState.isPremiumUser
                                ? Icons.notifications
                                : Icons.lock_outline_rounded,
                          ),
                          label: Text(
                            context.getString(
                              notifySet ? 'notified' : 'notifyMe',
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: notifySet
                                ? Colors.green
                                : Theme.of(context).iconTheme.color,
                            side: BorderSide(
                              color: notifySet
                                  ? Colors.green
                                  : Theme.of(context).dividerColor,
                            ),
                            minimumSize: const Size.fromHeight(48),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: child,
    );
  }
}

class _InfoValue extends StatelessWidget {
  final String label;
  final String value;

  const _InfoValue({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}