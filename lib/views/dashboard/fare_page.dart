import 'package:flutter/material.dart';

import 'package:routo/core/theme/app_colors.dart';
import 'package:routo/views/widgets/field.dart';
import 'package:routo/views/widgets/heading.dart';
import 'package:routo/views/widgets/panel.dart';
import 'package:routo/views/widgets/primary_action.dart';
import 'package:routo/views/widgets/screen.dart';

class FarePage extends StatefulWidget {
  const FarePage({super.key, required this.offering, required this.suggested});
  final bool offering;
  final double suggested;

  @override
  State<FarePage> createState() => _FarePageState();
}

class _FarePageState extends State<FarePage> {
  final form = GlobalKey<FormState>();
  final amount = TextEditingController();
  bool contribute = false;

  @override
  void dispose() {
    amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Screen(
    background: lilac,
    children: [
      const SizedBox(height: 44),
      Heading(
        widget.offering
            ? 'Set a Fare Contribution'
            : 'How would you like to travel?',
        null,
        forest,
        true,
      ),
      if (widget.suggested > 0)
        Panel(
          border: sand,
          child: Center(
            child: Heading(
              'Rs. ${widget.suggested.toStringAsFixed(2)}',
              'Suggested fare',
              teal,
              true,
            ),
          ),
        ),
      Panel(
        border: sand,
        color: lilac,
        child: Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                widget.offering
                    ? 'Offer the ride for free'
                    : 'I’d like to travel for free',
              ),
              leading: Icon(
                contribute
                    ? Icons.radio_button_unchecked
                    : Icons.radio_button_checked,
              ),
              onTap: () => setState(() => contribute = false),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                widget.offering ? 'Suggest a contribution' : 'I’ll contribute',
              ),
              leading: Icon(
                contribute
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
              ),
              onTap: () => setState(() => contribute = true),
            ),
            if (contribute)
              Form(
                key: form,
                child: Field(
                  'Amount (Rs.)',
                  amount,
                  keyboard: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    final parsed = double.tryParse(text);
                    return !RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(text) ||
                        parsed == null ||
                        !parsed.isFinite ||
                        parsed <= 0
                        ? 'Enter a positive amount with up to two decimal places'
                        : null;
                  },
                ),
              ),
          ],
        ),
      ),
      PrimaryAction('Continue', () {
        if (contribute && !form.currentState!.validate()) return;
        Navigator.of(context)
            .pop(contribute ? double.parse(amount.text.trim()) : 0.0);
      }),
    ],
  );
}