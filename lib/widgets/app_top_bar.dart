import 'package:flutter/material.dart';

import 'nawaa_logo.dart';
import 'settings_button.dart';

class AppTopBar extends StatelessWidget {
  final String? title;
  final String? subtitle;

  const AppTopBar({
    super.key,
    this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 62,
            child: Row(
              textDirection: TextDirection.ltr,
              children: const [
                SizedBox(width: 56),
                Expanded(
                  child: Center(
                    child: NawaaLogo(size: 90),
                  ),
                ),
                SizedBox(
                  width: 56,
                  child: Align(
                    alignment: Alignment.center,
                    child: SettingsButton(),
                  ),
                ),
              ],
            ),
          ),
          if (title != null) ...[
            const SizedBox(height: 18),
            Text(
              title!,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 22,
                    height: 1.1,
                  ),
            ),
          ],
          if (subtitle != null) ...[
            const SizedBox(height: 5),
            Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}
