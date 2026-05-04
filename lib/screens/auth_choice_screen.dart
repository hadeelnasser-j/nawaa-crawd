import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../extensions/localization_extension.dart';
import '../widgets/app_background.dart';
import '../widgets/nawaa_logo.dart';
import '../widgets/settings_button.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthChoiceScreen extends StatefulWidget {
  const AuthChoiceScreen({super.key});

  @override
  State<AuthChoiceScreen> createState() => _AuthChoiceScreenState();
}

class _AuthChoiceScreenState extends State<AuthChoiceScreen> {
  bool acceptedTerms = false;

  void continueTo(AppScreen screen) {
    if (!acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.getString('acceptTermsFirst')),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    context.read<AppState>().goTo(screen);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: AppBackground(
        child: SafeArea(
          child: Stack(
            children: [
              const Positioned(
                top: 4,
                right: 10,
                child: SettingsButton(),
              ),
              Center(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 64),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        const NawaaLogo(size: 280),
                        const SizedBox(height: 0),
                        
                        Text(
                          context.getString('appTitle'),
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontSize: 40,
                                    fontWeight: FontWeight.w700,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          context.getString('welcomeSubtitle'),
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontSize: 15,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 50),
                        const SizedBox(height: 40),
                        ElevatedButton.icon(
                          onPressed: () => continueTo(AppScreen.userLogin),
                          icon: const Icon(Icons.person_rounded),
                          label: Text(context.getString('continueAsUser')),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            minimumSize: const Size.fromHeight(52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        OutlinedButton.icon(
      onPressed: () async {
           final url = Uri.parse("https://nawaa-phi.vercel.app"); 

  await launchUrl(url);
},                          icon: const Icon(Icons.business_center_rounded),
                          label: Text(context.getString('continueAsCompany')),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Theme.of(context).primaryColor,
                            backgroundColor: Theme.of(context)
                                .cardColor,
                                
                            side: BorderSide(
                                color: Theme.of(context).dividerColor),
                            minimumSize: const Size.fromHeight(52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Checkbox(
                              value: acceptedTerms,
                              onChanged: (value) {
                                setState(() => acceptedTerms = value ?? false);
                              },
                            ),
                            Expanded(
                              child: InkWell(
                                borderRadius: BorderRadius.circular(8),
                                onTap: () {
                                  context
                                      .read<AppState>()
                                      .goTo(AppScreen.terms);
                                },
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: Text(
                                    context.getString('termsHint'),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontSize: 13,
                                          decoration: TextDecoration.underline,
                                        ),
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
