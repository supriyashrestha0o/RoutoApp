import 'package:flutter/material.dart';

import 'package:routo/core/theme/app_colors.dart';
import 'package:routo/core/utils/ui_helpers.dart';
import 'package:routo/models/student_profile.dart';
import 'package:routo/views/setup/setup_complete.dart';
import 'package:routo/views/widgets/heading.dart';
import 'package:routo/views/widgets/panel.dart';
import 'package:routo/views/widgets/primary_action.dart';
import 'package:routo/views/widgets/screen.dart';

class VerificationPage extends StatefulWidget {
  const VerificationPage({super.key, required this.profile});
  final StudentProfile profile;

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  final selected = <String>{};

  @override
  Widget build(BuildContext context) => Screen(
    background: mint,
    steps: 4,
    children: [
      const Heading(
        'Verification Documents',
        'Try the verification screen with sample documents.',
      ),
      for (final title in ['Driving License', 'Citizenship'])
        Panel(
          border: sand,
          color: mint,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.description_outlined),
            title: Text(title),
            subtitle: Text(selected.contains(title) ? 'Sample selected' : 'Front & back'),
            trailing: TextButton(
              onPressed: () => setState(() {
                if (!selected.add(title)) selected.remove(title);
              }),
              child: Text(selected.contains(title) ? 'Remove' : 'Choose sample'),
            ),
          ),
        ),
      PrimaryAction(
        'Submit for Verification',
        selected.length == 2 ? () => showPage(context, SetupComplete(profile: widget.profile)) : null,
      ),
      PrimaryAction(
        'Maybe Later',
            () => showPage(context, SetupComplete(profile: widget.profile)),
        secondary: true,
      ),
    ],
  );
}