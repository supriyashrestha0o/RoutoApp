import 'package:flutter/material.dart';

import 'package:routo/core/theme/app_theme.dart';
import 'package:routo/views/onboarding/splash_page.dart';

class RoutoApp extends StatelessWidget {
  const RoutoApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Routo',
    debugShowCheckedModeBanner: false,
    theme: routoTheme(),
    home: const SplashPage(),
  );
}
