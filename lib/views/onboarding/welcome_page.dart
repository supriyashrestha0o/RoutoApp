import 'package:flutter/material.dart';

import 'package:routo/core/theme/app_colors.dart';
import 'package:routo/core/utils/ui_helpers.dart';
import 'package:routo/views/auth/login_page.dart';
import 'package:routo/views/auth/register_page.dart';
import 'package:routo/views/setup/preview_setup.dart';
import 'package:routo/views/widgets/heading.dart';
import 'package:routo/views/widgets/primary_action.dart';
import 'package:routo/views/widgets/screen.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) => Screen(
    children: [
      const SizedBox(height: 10),
      const Text(
        'яouto',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: forest,
          fontWeight: FontWeight.w900,
          fontSize: 50,
        ),
      ),
      const SizedBox(height: 24),
      const Heading(
        'Your Journey. Shared Smarter',
        'Find students traveling the same route and share your journey together.',
      ),
      Image.asset(
        'assets/welcome-ride.webp',
        height: 230,
        excludeFromSemantics: true,
      ),
      PrimaryAction(
        'Get Started',
            () => showPage(context, const RegisterPage()),
      ),
      OutlinedButtonTheme(
        data: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        child: PrimaryAction(
          'Login',
              () => showPage(context, const LoginPage()),
          secondary: true,
        ),
      ),
      TextButton(
        onPressed: () => showPage(context, const PreviewSetup()),
        child: const Text('Explore frontend preview'),
      ),
    ],
  );
}