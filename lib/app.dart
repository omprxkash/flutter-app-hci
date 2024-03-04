import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class MedQuizApp extends ConsumerWidget {
  const MedQuizApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GoRouterConfig router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'MedQuiz',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: router.config,
      localizationsDelegates: const <LocalizationsDelegate<Object>>[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const <Locale>[
        Locale('en'),
        Locale('ta'),
        Locale('hi'),
      ],
      builder: (BuildContext context, Widget? child) {
        // Clamp text scaling so very large system font sizes don't break layouts,
        // but still allow a meaningful accessibility boost (1.3x cap).
        final MediaQueryData mq = MediaQuery.of(context);
        final TextScaler clamped = mq.textScaler.clamp(
          minScaleFactor: 0.9,
          maxScaleFactor: 1.3,
        );
        return MediaQuery(
          data: mq.copyWith(textScaler: clamped),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
