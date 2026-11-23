import 'package:flutter/material.dart';

import 'package:routo/controllers/validators.dart';
import 'package:routo/core/theme/app_colors.dart';
import 'package:routo/core/utils/ui_helpers.dart';
import 'package:routo/models/student_profile.dart';
import 'package:routo/views/setup/verification_page.dart';
import 'package:routo/views/widgets/field.dart';
import 'package:routo/views/widgets/heading.dart';
import 'package:routo/views/widgets/primary_action.dart';
import 'package:routo/views/widgets/screen.dart';

class VehiclePage extends StatefulWidget {
  const VehiclePage({super.key, required this.profile});
  final StudentProfile profile;

  @override
  State<VehiclePage> createState() => _VehiclePageState();
}

class _VehiclePageState extends State<VehiclePage> {
  final form = GlobalKey<FormState>();
  final model = TextEditingController();
  final number = TextEditingController();
  String type = 'Bike';
  int seats = 1;

  @override
  void dispose() {
    model.dispose();
    number.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Screen(
    background: mint,
    steps: 3,
    children: [
      const Heading('Vehicle Information', 'Tell us about your vehicle'),
      Row(
        spacing: 10,
        children: [
          for (final entry in const {
            'Bike': Icons.two_wheeler,
            'Scooter': Icons.moped,
            'Car': Icons.directions_car_outlined,
          }.entries)
            Expanded(
              child: ChoiceChip(
                selected: type == entry.key,
                showCheckmark: false,
                selectedColor: cream,
                backgroundColor: mint,
                side: BorderSide(
                  color: type == entry.key ? sand : Colors.black26,
                  width: 2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                labelPadding: const EdgeInsets.symmetric(horizontal: 2),
                label: SizedBox(
                  width: double.infinity,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(entry.value, size: 34, color: Colors.black),
                      const SizedBox(height: 12),
                      Text(
                        entry.key,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: forest,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                onSelected: (_) => setState(() {
                  type = entry.key;
                  if (type != 'Car') seats = 1;
                }),
              ),
            ),
        ],
      ),
      const SizedBox(height: 24),
      Form(
        key: form,
        child: Column(
          children: [
            Field('Vehicle Model', model, validator: requiredField),
            Field('Vehicle Number', number, validator: requiredField),
            if (type == 'Car')
              DropdownButtonFormField<int>(
                initialValue: seats,
                decoration: const InputDecoration(labelText: 'Passenger seats'),
                items: [1, 2, 3]
                    .map(
                      (value) =>
                      DropdownMenuItem(value: value, child: Text('$value')),
                )
                    .toList(),
                onChanged: (value) => setState(() => seats = value!),
              ),
          ],
        ),
      ),
      PrimaryAction('Continue', () {
        if (!form.currentState!.validate()) return;
        widget.profile
          ..vehicle = type
          ..model = model.text.trim()
          ..capacity = seats;
        showPage(context, VerificationPage(profile: widget.profile));
      }),
    ],
  );
}