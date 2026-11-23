import 'package:flutter/material.dart';

import 'package:routo/core/theme/app_colors.dart';
import 'package:routo/core/utils/ui_helpers.dart';
import 'package:routo/models/student_profile.dart';
import 'package:routo/views/setup/setup_complete.dart';
import 'package:routo/views/setup/vehicle_page.dart';
import 'package:routo/views/widgets/heading.dart';
import 'package:routo/views/widgets/panel.dart';
import 'package:routo/views/widgets/primary_action.dart';
import 'package:routo/views/widgets/screen.dart';

class RolePage extends StatefulWidget {
  const RolePage({super.key, required this.profile});
  final StudentProfile profile;

  @override
  State<RolePage> createState() => _RolePageState();
}

class _RolePageState extends State<RolePage> {
  bool driver = false;

  @override
  Widget build(BuildContext context) => Screen(
    background: mint,
    steps: 3,
    children: [
      const Heading('How do you Travel?', 'How would you like to use Routo?'),
      for (final offer in [false, true])
        Panel(
          color: mint,
          border: driver == offer ? sand : Colors.black26,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor: sand,
              child: Icon(
                offer ? Icons.directions_car_outlined : Icons.person_outline,
                color: Colors.black,
              ),
            ),
            title: Text(
              offer ? 'Offer a Ride' : 'Find a Ride',
              style: const TextStyle(
                color: forest,
                fontWeight: FontWeight.w800,
              ),
            ),
            subtitle: Text(
              offer
                  ? 'Share your ride with other students'
                  : 'Find students traveling along your route',
            ),
            trailing: Icon(
              driver == offer
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: driver == offer ? sand : teal,
            ),
            onTap: () => setState(() => driver = offer),
          ),
        ),
      const SizedBox(height: 16),
      PrimaryAction('Continue', () {
        widget.profile.driver = driver;
        showPage(
          context,
          driver
              ? VehiclePage(profile: widget.profile)
              : SetupComplete(profile: widget.profile),
        );
      }),
    ],
  );
}
