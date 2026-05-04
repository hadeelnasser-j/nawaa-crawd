import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF09051F) : const Color(0xFFF8F7FF),
              image: DecorationImage(
                image: AssetImage(
                  isDark
                      ? 'assets/images/دارك مود.png'
                      : 'assets/images/لايت مود.png',
                ),
                opacity: isDark ? 0.30 :1.72,
                repeat: ImageRepeat.repeat,
                fit: BoxFit.none,
                scale: isDark ? 1.7 :1.95,
                alignment: Alignment.topCenter,
              ),
            ),
          ),
        ),
        Positioned.fill(child: child),
      ],
    );
  }
}
