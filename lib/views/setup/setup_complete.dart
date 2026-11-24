import 'package:flutter/material.dart';

import 'package:routo/core/theme/app_colors.dart';
import 'package:routo/models/student_profile.dart';
import 'package:routo/views/dashboard/dashboard.dart';
import 'package:routo/views/widgets/heading.dart';
import 'package:routo/views/widgets/primary_action.dart';
import 'package:routo/views/widgets/screen.dart';
import 'package:routo/controllers/auth_controller.dart';


class SetupComplete extends StatelessWidget {
  const SetupComplete({super.key, required this.profile});
  final StudentProfile profile;

  void openDashboard(BuildContext context) {
    AuthController.attachProfile(profile);
    // TODO: save profile.toMap() to your backend here before continuing.
    // Clears the setup pages so Back can't return to them. The first route is
    // kept so the dashboard's Logout (popUntil first) still works.
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => Dashboard(profile: profile)),
          (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false, // no going back after finishing setup
    child: Screen(
      children: [
        const SizedBox(height: 30),
        const Icon(Icons.check_circle, color: forest, size: 104),
        const SizedBox(height: 24),
        const Heading(
          'You’re all set!',
          'Your profile and journey are ready.',
          forest,
          true,
        ),
        Image.asset(
          'assets/setup-campus.webp',
          height: 220,
          excludeFromSemantics: true,
        ),
        PrimaryAction('Continue', () => openDashboard(context)),
      ],
    ),
  );
}
