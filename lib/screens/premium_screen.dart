import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../extensions/localization_extension.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final features = [
      context.getString('bestTimeToVisitFeature'),
      context.getString('estimatedWaitTime'),
      context.getString('aiPredictions'),
      context.getString('smartNotifications'),
      context.getString('noAds'),
    ];

    final comparison = [
      _ComparisonRow(context.getString('crowdInfo'), true, true),
      _ComparisonRow(context.getString('basicMap'), true, true),
      _ComparisonRow(context.getString('bestTime'), false, true),
      _ComparisonRow(context.getString('waitTime'), false, true),
      _ComparisonRow(context.getString('aiPredictionShort'), false, true),
      _ComparisonRow(context.getString('notifications'), false, true),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: appState.goBackFromPremium,
        ),
        title: Text(context.getString('premium')),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          children: [
            Row(
              children: [
                const Icon(
                  Icons.workspace_premium_rounded,
                  color: Colors.amber,
                  size: 34,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.getString('upgradeToPremium'),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontSize: 26,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        context.getString('premiumDescription'),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            _Panel(
              child: Column(
                children: [
                  ...features.map(
                    (feature) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_rounded,
                            color: Colors.amber,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              feature,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _Panel(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _TableHeader(
                    freeLabel: context.getString('free'),
                    premiumLabel: context.getString('premium'),
                  ),
                  ...comparison.map((row) => _TableRow(row: row)),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _Panel(
              child: Column(
                children: [
                  Text(
                    appState.isPremiumUser
                        ? context.getString('subscribed')
                        : context.getString('sarMonthly'),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 26,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    appState.isPremiumUser
                        ? context.getString('subscriptionActive')
                        : context.getString('cancelAnytime'),
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: appState.isPremiumUser
                  ? appState.cancelPremium
                  : appState.openPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: appState.isPremiumUser
                    ? Colors.redAccent
                    : Theme.of(context).primaryColor,
                minimumSize: const Size.fromHeight(54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                context.getString(
                  appState.isPremiumUser
                      ? 'cancelSubscription'
                      : 'subscribeNow',
                ),
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: appState.goBackFromPremium,
              child: Text(
                context.getString('maybeLater'),
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _Panel({
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: child,
    );
  }
}

class _ComparisonRow {
  final String title;
  final bool free;
  final bool premium;

  const _ComparisonRow(this.title, this.free, this.premium);
}

class _TableHeader extends StatelessWidget {
  final String freeLabel;
  final String premiumLabel;

  const _TableHeader({
    required this.freeLabel,
    required this.premiumLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        border:
            Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        children: [
          const Expanded(flex: 2, child: SizedBox.shrink()),
          Expanded(child: _HeaderText(freeLabel)),
          Expanded(child: _HeaderText(premiumLabel, premium: true)),
        ],
      ),
    );
  }
}

class _HeaderText extends StatelessWidget {
  final String text;
  final bool premium;

  const _HeaderText(this.text, {this.premium = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: premium ? Theme.of(context).primaryColor : null,
            fontWeight: FontWeight.w800,
          ),
    );
  }
}

class _TableRow extends StatelessWidget {
  final _ComparisonRow row;

  const _TableRow({required this.row});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        border:
            Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              row.title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          Expanded(child: _AvailabilityIcon(available: row.free)),
          Expanded(child: _AvailabilityIcon(available: row.premium)),
        ],
      ),
    );
  }
}

class _AvailabilityIcon extends StatelessWidget {
  final bool available;

  const _AvailabilityIcon({required this.available});

  @override
  Widget build(BuildContext context) {
    return Icon(
      available ? Icons.check_rounded : Icons.remove_rounded,
      color: available
          ? Colors.green
          : Theme.of(context).iconTheme.color?.withValues(alpha: 0.35),
    );
  }
}
