import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../extensions/localization_extension.dart';

class SettingsWidget extends StatelessWidget {
  const SettingsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withValues(
                            alpha: 0.16,
                          ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.tune_rounded,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.getString('settings'),
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontSize: 22,
                                  ),
                        ),
                        Text(
                          context.getString('preferences'),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _SectionTitle(context.getString('appearance')),
              _SettingsPanel(
                children: [
                  _OptionRow(
                    icon: Icons.language_rounded,
                    title: context.getString('language'),
                    trailing: SegmentedButton<String>(
                      showSelectedIcon: false,
                      segments: const [
                        ButtonSegment<String>(
                          value: 'ar',
                          label: Text('عربي'),
                        ),
                        ButtonSegment<String>(
                          value: 'en',
                          label: Text('EN'),
                        ),
                      ],
                      selected: {appState.locale},
                      onSelectionChanged: (selection) {
                        appState.setLocale(selection.first);
                      },
                    ),
                  ),
                  const _PanelDivider(),
                  _OptionRow(
                    icon: appState.isDarkMode
                        ? Icons.dark_mode_rounded
                        : Icons.light_mode_rounded,
                    title: context.getString(
                      appState.isDarkMode ? 'darkMode' : 'lightMode',
                    ),
                    trailing: Switch(
                      value: appState.isDarkMode,
                      onChanged: appState.setTheme,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _SectionTitle(context.getString('account')),
              _SettingsPanel(
                children: [
                  _NavRow(
                    icon: Icons.person_rounded,
                    title: context.getString('profile'),
                    subtitle: appState.userName,
                    onTap: () => _showProfileSheet(context),
                  ),
                  const _PanelDivider(),
                  _NavRow(
                    icon: Icons.workspace_premium_rounded,
                    title: context.getString('premium'),
                    subtitle: context.getString('premiumDetails'),
                    badge: appState.isPremiumUser
                        ? context.getString('subscribed')
                        : null,
                    onTap: () {
                      Navigator.pop(context);
                      appState.openPremium();
                    },
                  ),
                  const _PanelDivider(),
                  _NavRow(
                    icon: Icons.logout_rounded,
                    title: context.getString('logout'),
                    subtitle: context.getString('logoutDetails'),
                    danger: true,
                    onTap: () {
                      Navigator.pop(context);
                      appState.logout();
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

void _showProfileSheet(BuildContext context) {
  final appState = context.read<AppState>();
  final controller = TextEditingController(text: appState.userName);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).cardColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            MediaQuery.of(sheetContext).viewInsets.bottom + 20,
          ),
          child: Consumer<AppState>(
            builder: (context, appState, _) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.getString('profile'),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 22,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.getString('profileSubtitle'),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        labelText: context.getString('fullName'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _ReadonlyProfileRow(
                      icon: Icons.email_rounded,
                      title: context.getString('email'),
                      value: appState.userEmail,
                    ),
                    _ReadonlyProfileRow(
                      icon: Icons.location_on_rounded,
                      title: context.getString('location'),
                      value: appState.userLocation,
                    ),
                    _ReadonlyProfileRow(
                      icon: Icons.workspace_premium_rounded,
                      title: context.getString('memberStatus'),
                      value: appState.isPremiumUser
                          ? context.getString('premiumMember')
                          : context.getString('freeMember'),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        appState.setUserName(controller.text);
                        Navigator.pop(sheetContext);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(context.getString('saveName')),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
    },
  ).whenComplete(controller.dispose);
}

class _ReadonlyProfileRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _ReadonlyProfileRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          _IconBox(icon: icon),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                      ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.lock_outline_rounded,
            size: 18,
            color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.45),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 4, bottom: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _SettingsPanel extends StatelessWidget {
  final List<Widget> children;

  const _SettingsPanel({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(children: children),
    );
  }
}

class _OptionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget trailing;

  const _OptionRow({
    required this.icon,
    required this.title,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          _IconBox(icon: icon),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? badge;
  final bool danger;
  final VoidCallback? onTap;

  const _NavRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.badge,
    this.danger = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger ? Colors.redAccent : Theme.of(context).primaryColor;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      leading: _IconBox(icon: icon, color: color),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: danger ? color : null,
            ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
      ),
      trailing: badge == null
          ? Icon(
              Icons.chevron_right_rounded,
              color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.45),
            )
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                badge!,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
    );
  }
}

class _IconBox extends StatelessWidget {
  final IconData icon;
  final Color? color;

  const _IconBox({
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).primaryColor;

    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: effectiveColor.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: effectiveColor, size: 20),
    );
  }
}

class _PanelDivider extends StatelessWidget {
  const _PanelDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 62,
      color: Theme.of(context).dividerColor,
    );
  }
}
