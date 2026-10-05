import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/theme/app_theme.dart';
import '../core/utils/preferences_service.dart';
import '../l10n/app_localizations.dart';
import 'app_router.dart';

class PoultryGuardApp extends StatelessWidget {
  const PoultryGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: PreferencesService.languageNotifier,
      builder: (context, languageCode, _) {
        return MaterialApp(
          title: 'PoultryGuard',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,

          locale: Locale(languageCode),

          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          supportedLocales: const [Locale('en'), Locale('ur')],

          initialRoute: AppRouter.splash,
          onGenerateRoute: AppRouter.onGenerateRoute,
        );
      },
    );
  }
}
