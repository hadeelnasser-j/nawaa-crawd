import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../extensions/localization_extension.dart';

class BottomNav extends StatelessWidget {
  const BottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navGradient = LinearGradient(
      begin: AlignmentDirectional.topStart,
      end: AlignmentDirectional.bottomEnd,
      colors: isDark
          ? [
              const Color(0xFF1A1042).withValues(alpha: 0.86),
              const Color(0xFF10082F).withValues(alpha: 0.78),
            ]
          : [
              Colors.white.withValues(alpha: 0.82),
              const Color(0xFFF7F4FF).withValues(alpha: 0.72),
            ],
    );

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(18, 0, 18, 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(34),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            decoration: BoxDecoration(
              gradient: navGradient,
              borderRadius: BorderRadius.circular(34),
              border: Border.all(
                color: Colors.white.withValues(alpha: isDark ? 0.14 : 0.56),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7076EB)
                      .withValues(alpha: isDark ? 0.22 : 0.18),
                  blurRadius: 28,
                  spreadRadius: 1,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.30 : 0.08),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: _NavItem(
                    icon: Icons.home_rounded,
                    label: context.getString('home'),
                    isActive: appState.activeTab == AppTab.home,
                    notificationCount: 0,
                    onTap: () => appState.setActiveTab(AppTab.home),
                  ),
                ),
                Expanded(
                  child: _NavItem(
                    icon: Icons.explore_rounded,
                    label: context.getString('explore'),
                    isActive: appState.activeTab == AppTab.explore,
                    notificationCount: 0,
                    onTap: () => appState.setActiveTab(AppTab.explore),
                  ),
                ),
                Expanded(
                  child: _NavItem(
                    icon: Icons.event_note_rounded,
                    label: context.getString('appointments'),
                    isActive: appState.activeTab == AppTab.appointments,
                    notificationCount: 0,
                    onTap: () => appState.setActiveTab(AppTab.appointments),
                  ),
                ),
                Expanded(
                  child: _NavItem(
                    icon: Icons.notifications_rounded,
                    label: context.getString('notifications'),
                    isActive: appState.activeTab == AppTab.notifications,
                    notificationCount: appState.notificationCount,
                    onTap: () => appState.setActiveTab(AppTab.notifications),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final int notificationCount;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.notificationCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const activeColor = Color(0xFF7076EB);
    final inactiveColor =
        (isDark ? Colors.white : const Color(0xFF10082F)).withValues(
      alpha: 0.42,
    );

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            decoration: BoxDecoration(
              color: isActive
                  ? activeColor.withValues(alpha: isDark ? 0.24 : 0.18)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(26),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: activeColor.withValues(alpha: 0.24),
                        blurRadius: 18,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 34,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: isActive
                        ? const LinearGradient(
                            colors: [Color(0xFF7076EB), Color(0xFF4CA8DA)],
                          )
                        : null,
                  ),
                  child: Icon(
                    icon,
                    size: 21,
                    color: isActive ? Colors.white : inactiveColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                    color: isActive
                        ? (isDark ? Colors.white : const Color(0xFF10082F))
                        : inactiveColor,
                  ),
                ),
              ],
            ),
          ),
          if (notificationCount > 0)
            PositionedDirectional(
              top: -1,
              end: 14,
              child: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: Color(0xFFE44E02),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$notificationCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
