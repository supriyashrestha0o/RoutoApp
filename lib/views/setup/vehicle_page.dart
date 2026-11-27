import 'package:flutter/material.dart';

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
  String? selectedModel;

  static const otherModel = 'Others';

  static const Map<String, List<String>> modelsByType = {
    'Bike': [
      'Bajaj Pulsar 150',
      'Yamaha FZ-S',
      'TVS Apache RTR 160',
      'Royal Enfield Classic 350',
    ],
    'Scooter': [
      'Honda Dio',
      'Honda Activa',
      'TVS Ntorq 125',
      'Yamaha RayZR 125',
    ],
    'Car': [
      'Maruti Suzuki Swift',
      'Hyundai i10',
      'Tata Nexon',
      'BYD Atto 3',
      'Kia Sonet',
    ],
  };

  String? validateVehicleModel(String? value) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return 'Please enter your vehicle model.';
    }

    if (!RegExp(r'\p{L}', unicode: true).hasMatch(text)) {
      return 'Enter a model name, for example Honda Dio or Pulsar 150.';
    }

    return null;
  }

  String? validateVehicleNumber(String? value) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return 'Please enter your vehicle number.';
    }

    if (!RegExp(r'^[0-9०-९]{1,4}$').hasMatch(text)) {
      return 'Enter the last 1 to 4 digits, for example 7 or 0042.';
    }

    if (RegExp(r'^[0०]+$').hasMatch(text)) {
      return 'Vehicle number must be greater than zero.';
    }

    return null;
  }

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
                onSelected: (_) {
                  if (type == entry.key) return;

                  setState(() {
                    type = entry.key;
                    selectedModel = null;
                    model.clear();

                    if (type != 'Car') seats = 1;
                  });
                },
              ),
            ),
        ],
      ),
      const SizedBox(height: 24),
      Form(
        key: form,
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              key: ValueKey(type),
              initialValue: selectedModel,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Vehicle Model',
              ),
              hint: const Text('Select your vehicle model'),
              items: [
                for (final name in modelsByType[type]!)
                  DropdownMenuItem<String>(
                    value: name,
                    child: Text(name),
                  ),
                const DropdownMenuItem<String>(
                  value: otherModel,
                  child: Text(otherModel),
                ),
              ],
              validator: (value) =>
              value == null ? 'Please select your vehicle model.' : null,
              onChanged: (value) {
                setState(() {
                  selectedModel = value;
                  model.text = value == otherModel ? '' : (value ?? '');
                });
              },
            ),
            const SizedBox(height: 16),
            if (selectedModel == otherModel)
              Field(
                'Enter your vehicle model',
                model,
                keyboard: TextInputType.text,
                validator: validateVehicleModel,
              ),
            Field(
              'Vehicle Number (last 1–4 digits)',
              number,
              keyboard: TextInputType.number,
              validator: validateVehicleNumber,
            ),
            if (type == 'Car')
              DropdownButtonFormField<int>(
                initialValue: seats,
                decoration: const InputDecoration(
                  labelText: 'Passenger seats',
                ),
                items: [1, 2, 3]
                    .map(
                      (value) => DropdownMenuItem<int>(
                    value: value,
                    child: Text('$value'),
                  ),
                )
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => seats = value);
                },
              ),
          ],
        ),
      ),
      PrimaryAction('Continue', () {
        if (!form.currentState!.validate()) return;

        widget.profile
          ..vehicle = type
          ..model = model.text.trim()
          ..vehicleNumber = number.text.trim()
          ..capacity = seats;

        showPage(context, VerificationPage(profile: widget.profile));
      }),
    ],
  );
}