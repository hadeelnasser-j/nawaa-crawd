import 'package:flutter/material.dart';

class PremiumFeatureTile extends StatelessWidget {
  final String title;
  final bool isLocked;
  final VoidCallback? onTap;
  final IconData icon;
  final String? value;

  const PremiumFeatureTile({
    super.key,
    required this.title,
    required this.isLocked,
    this.onTap,
    this.icon = Icons.auto_awesome_rounded,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    final contentColor = isLocked
        ? Theme.of(context).textTheme.bodyMedium?.color
        : Theme.of(context).textTheme.bodyLarge?.color;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Row(
          children: [
            Icon(
              icon,
              color: isLocked
                  ? Theme.of(context).iconTheme.color?.withValues(alpha: 0.55)
                  : Theme.of(context).primaryColor,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: contentColor,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            if (value != null && !isLocked)
              Text(
                value!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              )
            else if (isLocked)
              Icon(
                Icons.lock_outline_rounded,
                color:
                    Theme.of(context).iconTheme.color?.withValues(alpha: 0.65),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
