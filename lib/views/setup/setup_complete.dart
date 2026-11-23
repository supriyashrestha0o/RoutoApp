import 'package:flutter/material.dart';

import 'package:routo/core/theme/app_colors.dart';
import 'package:routo/core/utils/ui_helpers.dart';
import 'package:routo/models/student_profile.dart';
import 'package:routo/views/dashboard/dashboard.dart';
import 'package:routo/views/widgets/heading.dart';
import 'package:routo/views/widgets/primary_action.dart';
import 'package:routo/views/widgets/screen.dart';
class SetupComplete extends StatelessWidget {
  const SetupComplete({super.key, required this.profile});
  final StudentProfile profile;

  @override
  Widget build(BuildContext context) => Screen(
    children: [
      const SizedBox(height: 30),
      const Icon(Icons.check_circle, color: forest, size: 104),
      const SizedBox(height: 24),
      const Heading(
        'You’re all set!',
        'Your preview profile and journey are ready.',
        forest,
        true,
      ),
      Image.asset(
        'assets/setup-campus.webp',
        height: 220,
        excludeFromSemantics: true,
      ),
      PrimaryAction(
        'Continue',
            () => showPage(context, Dashboard(profile: profile)),
      ),
    ],
  );
}
