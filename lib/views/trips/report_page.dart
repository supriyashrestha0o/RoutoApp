import 'package:flutter/material.dart';

import 'package:routo/core/theme/app_colors.dart';
import 'package:routo/core/utils/ui_helpers.dart';
import 'package:routo/views/widgets/field.dart';
import 'package:routo/views/widgets/heading.dart';
import 'package:routo/views/widgets/primary_action.dart';
import 'package:routo/views/widgets/screen.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key, required this.name});
  final String name;

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final details = TextEditingController();
  String? reason;

  @override
  void dispose() {
    details.dispose();
    super.dispose();
  }

  Future<void> confirm(bool block) async {
    if (!block &&
        (reason == null ||
            (reason == 'Other' && details.text.trim().isEmpty))) {
      notice(context, 'Select a reason and add details if you choose Other.');
      return;
    }
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.error_outline, color: Colors.red, size: 48),
        title: Text(block ? 'Block this User?' : 'Submit this Report?'),
        content: const Text('This action applies to your preview session.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(block ? 'Confirm' : 'Submit'),
          ),
        ],
      ),
    );
    if (mounted && accepted == true)
      Navigator.of(context).pop(block ? 'block' : 'report');
  }

  @override
  Widget build(BuildContext context) => Screen(
    title: 'Report ${widget.name}',
    background: cream,
    children: [
      const Heading('What happened?'),
      for (final value in [
        'Unsafe Driving',
        'Harassment',
        'Inappropriate Behavior',
        'Fake Information',
        'Other',
      ])
        ListTile(
          leading: Icon(
            reason == value
                ? Icons.radio_button_checked
                : Icons.radio_button_unchecked,
            color: Colors.red.shade800,
          ),
          title: Text(value),
          onTap: () => setState(() => reason = value),
        ),
      const SizedBox(height: 12),
      Field('Additional Details', details, lines: 3),
      PrimaryAction('Submit Report', () => confirm(false)),
      PrimaryAction(
        'Block ${widget.name}',
            () => confirm(true),
        secondary: true,
      ),
    ],
  );
}
