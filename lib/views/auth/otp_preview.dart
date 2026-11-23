import 'package:flutter/material.dart';

import 'package:routo/core/utils/ui_helpers.dart';
import 'package:routo/views/setup/preview_setup.dart';
import 'package:routo/views/widgets/field.dart';
import 'package:routo/views/widgets/heading.dart';
import 'package:routo/views/widgets/primary_action.dart';
import 'package:routo/views/widgets/screen.dart';

class OtpPreview extends StatefulWidget {
  const OtpPreview({super.key, required this.email});
  final String email;

  @override
  State<OtpPreview> createState() => _OtpPreviewState();
}

class _OtpPreviewState extends State<OtpPreview> {
  final code = TextEditingController();
  final form = GlobalKey<FormState>();

  @override
  void dispose() {
    code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Screen(children: [
    Heading('Enter OTP', 'Use the 6-digit preview code for ${widget.email}.'),
    const SizedBox(height: 24),
    Form(key: form, child: Field('6-digit code', code, keyboard: TextInputType.number,
        validator: (value) => value?.trim() == '123456' ? null : 'Enter the preview code 123456')),
    Center(child: TextButton(onPressed: () => notice(context, 'Preview code: 123456'),
        child: const Text('Resend OTP'))),
    const SizedBox(height: 28),
    PrimaryAction('Continue', () {
      if (form.currentState!.validate()) showPage(context, const PreviewSetup());
    }),
    Center(child: TextButton(onPressed: () {
      Navigator.of(context)..pop()..pop();
    },
        child: const Text('Change email'))),
  ]);
}
