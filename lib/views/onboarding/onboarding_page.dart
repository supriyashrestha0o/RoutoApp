import 'package:flutter/material.dart';

import 'package:routo/core/theme/app_colors.dart';
import 'package:routo/views/onboarding/welcome_page.dart';
import 'package:routo/views/widgets/heading.dart';
import 'package:routo/views/widgets/primary_action.dart';
import 'package:routo/views/widgets/screen.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  static const headings = [
    'Find Students Going Your Way',
    'Share More Than a Ride',
    'Ride With People You Can Trust',
    'Ride Confirmed!',
  ];

  static const descriptions = [
    'Discover verified students traveling along similar routes and schedules.',
    'Request to join, chat with your journey partner, and plan your pickup.',
    'Connect with verified college students through profiles, journey history, ratings and reviews.',
    'View your meeting point and coordinate with your journey partner.',
  ];

  int step = 0;

  @override
  Widget build(BuildContext context) => Screen(
    children: [
      Image.asset(
        'assets/design-intro-$step.webp',
        height: 325,
        excludeFromSemantics: true,
      ),
      const SizedBox(height: 26),
      Heading(headings[step], descriptions[step], teal),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          4,
              (i) => IconButton(
            tooltip: 'Onboarding page ${i + 1}',
            onPressed: () => setState(() => step = i),
            icon: Icon(
              Icons.circle,
              size: 8,
              color: i == step ? teal : Colors.black26,
            ),
          ),
        ),
      ),
      PrimaryAction(step == 3 ? 'Get Started' : 'Next', () {
        if (step == 3) {
          Navigator.of(context).pushReplacement(MaterialPageRoute<void>(
            builder: (_) => const WelcomePage(),
          ));
        } else {
          setState(() => step++);
        }
      }),
    ],
  );
}