import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'screens/auth_choice_screen.dart';
import 'screens/company_access_screen.dart';
import 'screens/terms_screen.dart';
import 'screens/premium_screen.dart';
import 'screens/payment_screen.dart';
import 'screens/login_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'screens/explore_screen.dart';
import 'screens/place_details_screen.dart';
import 'screens/ai_prediction_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/appointments_screen.dart';
import 'components/bottom_nav.dart';

class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    Widget screen;

    switch (appState.currentScreen) {
      case AppScreen.login:
        screen = const AuthChoiceScreen();
        break;

      case AppScreen.userLogin:
        screen = const LoginScreen();
        break;

      case AppScreen.companyAccess:
        screen = const CompanyAccessScreen();
        break;

      case AppScreen.terms:
        screen = const TermsScreen();
        break;

      case AppScreen.premium:
        screen = const PremiumScreen();
        break;

      case AppScreen.payment:
        screen = const PaymentScreen();
        break;

      case AppScreen.onboarding:
        screen = const OnboardingScreen();
        break;

      case AppScreen.home:
        screen = const HomeScreen();
        break;

      case AppScreen.explore:
        screen = const ExploreScreen();
        break;

      case AppScreen.placeDetails:
        screen = const PlaceDetailsScreen();
        break;

      case AppScreen.aiPrediction:
        screen = const AIPredictionScreen();
        break;

      case AppScreen.notifications:
        screen = const NotificationsScreen();
        break;

      case AppScreen.appointments:
        screen = const AppointmentsScreen();
        break;
    }

    return Scaffold(
      extendBody: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: screen,
      ),
      bottomNavigationBar: appState.showBottomNav ? const BottomNav() : null,
    );
  }
}
