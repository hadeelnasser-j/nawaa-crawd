import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../extensions/localization_extension.dart';
import '../widgets/nawaa_logo.dart';
import '../widgets/settings_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isSignUp = false;
  bool notificationsEnabled = true;

  String name = '';
  String email = '';
  String password = '';
  String location = '';

  void handleSubmit(BuildContext context) {
  // 🔥 أول شيء: تحقق الحقول
  if (email.trim().isEmpty || password.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
  content: Text(context.getString('fillRequiredFields')),
),
    );
    return;
  }

  // 🔥 ثاني شيء: تحقق الإيميل
  if (!email.contains('@')) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('البريد الالكتروني غير صحيح'),
      ),
    );
    return;
  }

  // 👇 هنا يبدأ كودك الأصلي
  final appState = context.read<AppState>();

  if (name.trim().isNotEmpty) {
    appState.setUserName(name);
  } else {
    appState.setUserName(email.split('@').first);
  }

  appState.setUserEmail(email);

  if (location.trim().isNotEmpty) {
    appState.setUserLocation(location);
  }

  appState.goTo(AppScreen.onboarding);
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            children: [
              const SizedBox(height: 20),

              Row(
                textDirection: TextDirection.ltr,
                children: [
                  IconButton(
                    onPressed: () {
                      context.read<AppState>().goTo(AppScreen.login);
                    },
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const Spacer(),
                  const SettingsButton(),
                ],
              ),

              const NawaaLogo(size: 112),

              const SizedBox(height: 20),

              Text(
                context.getString('welcomeTitle'),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 6),

              Text(
                context.getString('welcomeSubtitle'),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                        ) ??
                    TextStyle(color: Colors.white60, fontSize: 14),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 28),

              // ===== Toggle Sign In / Sign Up =====
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    _toggleButton(
                        context.getString('signIn'), !isSignUp, false),
                    _toggleButton(context.getString('signUp'), isSignUp, true),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ===== Form =====
              if (isSignUp)
                _inputField(
                  label: context.getString('fullName'),
                  onChanged: (v) => name = v,
                  placeholder: 'سارة العتيبي',
                ),

              _inputField(
                label: context.getString('email'),
                onChanged: (v) => email = v,
                placeholder: 'example@email.com',
              ),

              _inputField(
                label: context.getString('password'),
                onChanged: (v) => password = v,
                placeholder: 'ثمانية أحرف على الأقل',
                obscure: true,
              ),

              if (isSignUp)
                _inputField(
                  label: context.getString('location'),
                  onChanged: (v) => location = v,
                  placeholder: 'أبحر، جدة',
                ),

              if (!isSignUp)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: Text(context.getString('forgotPassword')),
                  ),
                ),

              if (isSignUp) _notificationToggle(),

              const SizedBox(height: 10),

              // ===== Primary Button =====
              ElevatedButton(
                onPressed: () => handleSubmit(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  context.getString(isSignUp ? 'signUp' : 'signIn'),
                  style: const TextStyle(fontSize: 16),
                ),
              ),

              const SizedBox(height: 20),

              // ===== Footer toggle =====
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    context.getString(
                      isSignUp ? 'alreadyHaveAccount' : 'dontHaveAccount',
                    ),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() => isSignUp = !isSignUp);
                    },
                    child: Text(
                      context.getString(isSignUp ? 'signIn' : 'signUp'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===== Helpers =====
  Widget _toggleButton(String text, bool active, bool isSignUpButton) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => isSignUp = isSignUpButton);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? Theme.of(context).primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: active
                  ? Colors.white
                  : Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField({
    required String label,
    required Function(String) onChanged,
    required String placeholder,
    bool obscure = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withValues(alpha: 0.7),
                  )),
          const SizedBox(height: 6),
          TextField(
            onChanged: onChanged,
            obscureText: obscure,
            style: Theme.of(context).textTheme.bodyLarge,
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: Theme.of(context).inputDecorationTheme.hintStyle,
              filled: true,
              fillColor: Theme.of(context).cardColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _notificationToggle() {
    return GestureDetector(
      onTap: () {
        setState(() => notificationsEnabled = !notificationsEnabled);
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Checkbox(
              value: notificationsEnabled,
              onChanged: (_) {
                setState(() => notificationsEnabled = !notificationsEnabled);
              },
            ),
            Icon(Icons.notifications, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(context.getString('enableCrowdNotifications'),
                  style: Theme.of(context).textTheme.bodyLarge),
            ),
          ],
        ),
      ),
    );
  }
}
