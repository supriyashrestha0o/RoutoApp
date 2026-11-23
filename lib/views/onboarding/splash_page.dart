import 'package:flutter/material.dart';

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
      if (mounted)
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(builder: (_) => const OnboardingPage()),
        );
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xff353c34),
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              Image.asset(
                'assets/splash-brand.webp',
                height: 240,
                semanticLabel: 'Routo student ride sharing',
              ),
              const SizedBox(height: 24),
              const Text(
                'Your Route. Your Match.\nYour Journey.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 23,
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 28),
              Image.asset(
                'assets/splash-route.webp',
                height: 275,
                excludeFromSemantics: true,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}