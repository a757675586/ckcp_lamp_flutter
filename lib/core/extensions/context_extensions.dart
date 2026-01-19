import 'package:flutter/material.dart';
import '../localization/app_localizations.dart';

extension LocalizedContext on BuildContext {
  /// Get localized string manually
  /// Usage: context.tr('key')
  String tr(String key) {
    return AppLocalizations.of(this).get(key);
  }

  /// Get AppLocalizations instance
  AppLocalizations get loc => AppLocalizations.of(this);
}
