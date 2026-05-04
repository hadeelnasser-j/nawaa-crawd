import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../extensions/localization_extension.dart';

class OnboardingSlide {
  final IconData icon;
  final String titleKey;
  final String subtitleKey;
  final Color color;

  const OnboardingSlide({
    required this.icon,
    required this.titleKey,
    required this.subtitleKey,
    required this.color,
  });
}

const List<OnboardingSlide> slides = [
  OnboardingSlide(
    icon: Icons.people_alt_rounded,
    titleKey: 'onboardingCrowdTitle',
    subtitleKey: 'onboardingCrowdSubtitle',
    color: Color(0xFF7076EB),
  ),
  OnboardingSlide(
    icon: Icons.trending_up_rounded,
    titleKey: 'onboardingAiTitle',
    subtitleKey: 'onboardingAiSubtitle',
    color: Color(0xFF4CA8DA),
  ),
  OnboardingSlide(
    icon: Icons.star_rounded,
    titleKey: 'onboardingSmartTitle',
    subtitleKey: 'onboardingSmartSubtitle',
    color: Color(0xFFE44E02),
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int currentIndex = 0;
  final PageController controller = PageController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void next(BuildContext context) {
    if (currentIndex < slides.length - 1) {
      controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      return;
    }

    context.read<AppState>().goTo(AppScreen.home);
  }

  void skip(BuildContext context) {
    context.read<AppState>().goTo(AppScreen.home);
  }

  @override
  Widget build(BuildContext context) {
    final slide = slides[currentIndex];
    final isLast = currentIndex == slides.length - 1;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 56),
                  TextButton(
                    onPressed: () => skip(context),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(end: 44),
                      child: Text(context.getString('skip')),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: controller,
                itemCount: slides.length,
                onPageChanged: (i) => setState(() => currentIndex = i),
                itemBuilder: (_, i) {
                  final item = slides[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: item.color.withValues(alpha: 0.15),
                          ),
                          child: Icon(item.icon, color: item.color, size: 80),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          context.getString(item.titleKey),
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontSize: 26,
                                  ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          context.getString(item.subtitleKey),
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontSize: 16,
                                  ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(slides.length, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: i == currentIndex ? 16 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == currentIndex
                        ? slide.color
                        : Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color
                            ?.withValues(alpha: 0.38),
                    borderRadius: BorderRadius.circular(99),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () => next(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: slide.color,
                      minimumSize: const Size.fromHeight(54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      context.getString(isLast ? 'start' : 'next'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (!isLast)
                    TextButton(
                      onPressed: () => skip(context),
                      child: Text(context.getString('skip')),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
