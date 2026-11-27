import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:routo/views/onboarding/onboarding_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();

    Future<void>.delayed(const Duration(milliseconds: 2100), () {
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => const OnboardingPage(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF383E36);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: backgroundColor,
      ),
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: FractionallySizedBox(
            widthFactor: 0.56,
            child: Image.asset(
              'assets/splash-brand.webp',
              fit: BoxFit.contain,
              semanticLabel: 'Routo student ride sharing',
            ),
          ),
        ),
      ),
    );
  }
}