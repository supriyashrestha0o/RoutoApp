import 'package:flutter/material.dart';

import 'package:routo/core/theme/app_colors.dart';
import 'package:routo/core/utils/ui_helpers.dart';
import 'package:routo/views/widgets/field.dart';
import 'package:routo/views/widgets/heading.dart';
import 'package:routo/views/widgets/primary_action.dart';
import 'package:routo/views/widgets/screen.dart';

class ResetPasswordPreview extends StatefulWidget {
  const ResetPasswordPreview({super.key});

  @override
  State<ResetPasswordPreview> createState() => _ResetPasswordPreviewState();
}

class _ResetPasswordPreviewState extends State<ResetPasswordPreview> {
  final form = GlobalKey<FormState>();
  final password = TextEditingController();
  final confirmation = TextEditingController();
  bool obscure = true;

  @override
  void dispose() {
    password.dispose();
    confirmation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Screen(background: cream, children: [
    const Heading('Create New Password', 'Choose a strong password to keep your account secure.'),
    Form(key: form, child: Column(children: [
      Field('New password', password, icon: Icons.lock_outline, obscure: obscure,
          onChanged: (_) => setState(() {}),
          validator: (value) => goodPassword ? null : 'Meet all three password requirements',
          suffix: IconButton(
              tooltip: obscure ? 'Show passwords' : 'Hide passwords',
              icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined),
              onPressed: () => setState(() => obscure = !obscure))),
      Field('Confirm new password', confirmation, icon: Icons.lock_outline, obscure: obscure,
          validator: (value) => value == password.text ? null : 'Passwords do not match'),
    ])),
    requirement('At least 8 characters', password.text.length >= 8),
    requirement('One uppercase letter', RegExp(r'[A-Z]').hasMatch(password.text)),
    requirement('One number', RegExp(r'[0-9]').hasMatch(password.text)),
    const SizedBox(height: 20),
    PrimaryAction('Reset Password', () {
      if (!form.currentState!.validate()) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
      notice(context, 'Password reset preview complete. No account was changed.');
    }),
  ]);

  bool get goodPassword => password.text.length >= 8 &&
      RegExp(r'[A-Z]').hasMatch(password.text) && RegExp(r'[0-9]').hasMatch(password.text);

  Widget requirement(String label, bool met) => ListTile(
    leading: Icon(met ? Icons.check_circle : Icons.circle_outlined, color: forest),
    title: Text(label, style: const TextStyle(color: forest)),
  );
}
