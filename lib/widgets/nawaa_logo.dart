import 'package:flutter/material.dart';

class NawaaLogo extends StatelessWidget {
  final double size;

  const NawaaLogo({
    super.key,
    this.size = 96,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.2),
      child: Image.asset(
        'assets/images/nawaa_logo.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
      ),
    );
  }
}
