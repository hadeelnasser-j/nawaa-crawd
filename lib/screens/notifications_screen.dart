import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../extensions/localization_extension.dart';
import '../widgets/app_top_bar.dart';

class NotificationStyle {
  final Color bg;
  final Color border;
  final Color icon;
  final Color dot;

  const NotificationStyle(this.bg, this.border, this.icon, this.dot);
}

Map<NotificationType, NotificationStyle> notificationStyles() {
  return {
    NotificationType.alert: NotificationStyle(
      Colors.deepOrange.withValues(alpha: 0.1),
      Colors.deepOrange.withValues(alpha: 0.3),
      Colors.deepOrange,
      Colors.deepOrange,
    ),
    NotificationType.success: NotificationStyle(
      Colors.green.withValues(alpha: 0.1),
      Colors.green.withValues(alpha: 0.3),
      Colors.green,
      Colors.green,
    ),
    NotificationType.info: NotificationStyle(
      Colors.blue.withValues(alpha: 0.1),
      Colors.blue.withValues(alpha: 0.3),
      Colors.blue,
      Colors.blue,
    ),
  };
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final notifs = appState.notifications;
    final unreadCount = appState.unreadNotificationsCount;

    if (!appState.isPremiumUser) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        appState.openPremium();
      });
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            AppTopBar(
              title: context.getString('notifications'),
              subtitle: unreadCount > 0
                  ? unreadCount == 1
                      ? context.getString('unreadOne')
                      : context.formatString(
                          'unreadMany',
                          {'count': unreadCount.toString()},
                        )
                  : context.getString('noNewNotifications'),
            ),
            if (unreadCount > 0)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: IconButton(
                    onPressed: appState.markAllNotificationsRead,
                    icon: const Icon(Icons.done_all_rounded),
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            Expanded(
              child: notifs.isEmpty
                  ? const _EmptyState()
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 112),
                      children: [
                        if (notifs.any((n) => !n.read))
                          _SectionLabel(context.getString('new')),
                        ...notifs.where((n) => !n.read).map(
                              (n) => NotificationCard(notif: n),
                            ),
                        if (notifs.any((n) => n.read))
                          _SectionLabel(context.getString('previous')),
                        ...notifs.where((n) => n.read).map(
                              (n) => NotificationCard(notif: n),
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

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 48,
            color: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.color
                ?.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 12),
          Text(
            context.getString('allCaughtUp'),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            context.getString('noNewNotifications'),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final AppNotification notif;

  const NotificationCard({
    super.key,
    required this.notif,
  });

  @override
  Widget build(BuildContext context) {
    final style = notificationStyles()[notif.type]!;
    final appState = context.watch<AppState>();
    final place = appState.findPlaceById(notif.placeId);
    final placeName = place?.localizedName(appState.locale) ?? notif.placeName;

    return GestureDetector(
      onTap: () {
        appState.markNotificationRead(notif.id);
        appState.setSelectedPlace(place);
        appState.goTo(AppScreen.placeDetails);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: style.bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: style.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _iconForType(notif.type),
                color: style.icon,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    placeName,
                    style: TextStyle(
                      color: style.icon,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _localizedValue(context, notif.message),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _localizedValue(context, notif.time),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 12,
                        ),
                  ),
                ],
              ),
            ),
            if (!notif.read)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: style.dot,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _localizedValue(BuildContext context, String value) {
    if (value.startsWith('minutesAgo:')) {
      final count = value.split(':').last;
      return context.formatString('minutesAgo', {'count': count});
    }

    final translated = context.getString(value);
    return translated == value ? value : translated;
  }

  IconData _iconForType(NotificationType type) {
    switch (type) {
      case NotificationType.alert:
        return Icons.warning_amber_rounded;
      case NotificationType.success:
        return Icons.check_circle_outline;
      case NotificationType.info:
        return Icons.info_outline;
    }
  }
}
