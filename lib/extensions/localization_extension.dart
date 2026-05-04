import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../app_state.dart';

extension LocalizationExtension on BuildContext {
  String getString(String key) {
    final appState = read<AppState>();
    final localizations = AppLocalizations(appState.locale);
    return localizations.getString(key);
  }

  String formatString(String key, Map<String, String> values) {
    var text = getString(key);
    for (final entry in values.entries) {
      text = text.replaceAll('{${entry.key}}', entry.value);
    }
    return text;
  }

  bool get isArabic {
    return read<AppState>().locale == 'ar';
  }

  TextDirection get textDirection {
    return isArabic ? TextDirection.rtl : TextDirection.ltr;
  }
}
