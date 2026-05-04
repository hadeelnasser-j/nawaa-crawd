import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../extensions/localization_extension.dart';

// ====== Mock Data ======
final List<HourlyPrediction> defaultPredictions = [
  HourlyPrediction(hour: '12 PM', level: CrowdLevel.medium, value: 55),
  HourlyPrediction(hour: '1 PM', level: CrowdLevel.high, value: 88),
  HourlyPrediction(hour: '2 PM', level: CrowdLevel.high, value: 92),
  HourlyPrediction(hour: '3 PM', level: CrowdLevel.medium, value: 60),
  HourlyPrediction(hour: '4 PM', level: CrowdLevel.low, value: 28),
  HourlyPrediction(hour: '5 PM', level: CrowdLevel.low, value: 35),
];

// ====== Screen ======
class AIPredictionScreen extends StatelessWidget {
  const AIPredictionScreen({super.key});

  Color levelColor(BuildContext context, CrowdLevel level) {
    switch (level) {
      case CrowdLevel.low:
        return AppState.lowCrowdColor;
      case CrowdLevel.medium:
        return AppState.mediumCrowdColor;
      case CrowdLevel.high:
        return AppState.highCrowdColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final place = appState.selectedPlace;
    final predictions = place?.predictions ?? defaultPredictions;
    final locale = appState.locale;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            appState.goTo(AppScreen.home);
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.getString('aiPrediction'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              place == null
                  ? context.getString('appTitle')
                  : '${place.localizedName(locale)} - ${place.localizedAddress(locale)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                  ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // AI Disclaimer
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.indigo.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.indigo.withValues(alpha: 0.3)),
            ),
            child: Text(
              context.getString('aiPredictionDetails'),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                  ),
            ),
          ),
          const SizedBox(height: 20),

          // Simple Bar Chart (بديل SVG)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.getString('predictions'),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: predictions.map((pred) {
                    return Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '${pred.value}%',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontSize: 10,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: pred.value.toDouble(),
                            decoration: BoxDecoration(
                              color: levelColor(context, pred.level),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            pred.hour,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontSize: 10,
                                ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
