import 'package:flutter/material.dart';

import 'package:routo/core/theme/app_colors.dart';
import 'package:routo/views/onboarding/welcome_page.dart';
import 'package:routo/views/widgets/heading.dart';
import 'package:routo/views/widgets/primary_action.dart';

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
  Widget build(BuildContext context) {
    final isLastPage = step == headings.length - 1;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 3,
                child: Transform.scale(
                  scale: step < 2 ? 0.85 : 1.0,
                  child: Image.asset(
                    'assets/design-intro-$step.webp',
                    width: double.infinity,
                    fit: BoxFit.contain,
                    excludeFromSemantics: true,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.topLeft,
                      child: SizedBox(
                        width: constraints.maxWidth,
                        child: Heading(
                          headings[step],
                          descriptions[step],
                          teal,
                        ),
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  headings.length,
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
              const SizedBox(height: 4),
              PrimaryAction(isLastPage ? 'Get Started' : 'Next', () {
                if (isLastPage) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute<void>(
                      builder: (_) => const WelcomePage(),
                    ),
                  );
                } else {
                  setState(() => step++);
                }
              }),
            ],
          ),
        ),
      ),
    );
  }
}