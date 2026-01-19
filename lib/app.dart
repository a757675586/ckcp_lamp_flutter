import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'presentation/themes/app_theme.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/providers/preferences_provider.dart';
import 'core/localization/app_localizations.dart';

import 'core/constants/app_info.dart';

/// CKCP LAMP 应用根组件
class CkcpLampApp extends ConsumerWidget {
  const CkcpLampApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(preferencesProvider);

    return MaterialApp(
      title: AppInfo.appName,
      debugShowCheckedModeBanner: false,

      // Theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: prefs.themeMode,

      // Localization
      locale: prefs.locale,
      supportedLocales: const [
        Locale('en'),
        Locale('zh'),
      ],
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      home: const HomePage(),
    );
  }
}
