import 'package:flutter/material.dart';

import 'package:routo/controllers/auth_controller.dart';
import 'package:routo/core/theme/app_colors.dart';
import 'package:routo/core/utils/ui_helpers.dart';
import 'package:routo/views/setup/preview_setup.dart';
import 'package:routo/views/widgets/field.dart';
import 'package:routo/views/widgets/heading.dart';
import 'package:routo/views/widgets/panel.dart';
import 'package:routo/views/widgets/primary_action.dart';
import 'package:routo/views/widgets/screen.dart';

/// "Create Your Account" step: the verified email + a new password.
/// These become the credentials the Login screen checks.
class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key, required this.email});
  final String email;

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final form = GlobalKey<FormState>();
  final password = TextEditingController();
  final confirmation = TextEditingController();
  bool hidden = true;

  @override
  void dispose() {
    password.dispose();
    confirmation.dispose();
    super.dispose();
  }

  bool get hasLength => password.text.length >= 8;
  bool get hasUppercase => RegExp(r'[A-Z]').hasMatch(password.text);
  bool get hasNumber => RegExp(r'[0-9]').hasMatch(password.text);

  void createAccount() {
    if (!form.currentState!.validate()) return;
    AuthController.register(widget.email, password.text);
    showPage(context, const PreviewSetup());
  }

  @override
  Widget build(BuildContext context) => Screen(
    children: [
      const Heading(
        'Create Your Account',
        'Choose a password for your Routo account.',
      ),
      Panel(
        color: lilac,
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.mail_outline, color: forest),
          title: Text(widget.email),
          subtitle: const Text('Verified college email'),
        ),
      ),
      Form(
        key: form,
        child: Column(
          children: [
            Field(
              'Password',
              password,
              icon: Icons.lock_outline,
              obscure: hidden,
              onChanged: (_) => setState(() {}),
              validator: (_) => hasLength && hasUppercase && hasNumber
                  ? null
                  : 'Meet all three password requirements',
              suffix: IconButton(
                tooltip: hidden ? 'Show passwords' : 'Hide passwords',
                icon: Icon(
                  hidden
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                onPressed: () => setState(() => hidden = !hidden),
              ),
            ),
            Field(
              'Confirm password',
              confirmation,
              icon: Icons.lock_outline,
              obscure: hidden,
              validator: (value) =>
              value == password.text ? null : 'Passwords do not match',
            ),
          ],
        ),
      ),
      requirement('At least 8 characters', hasLength),
      requirement('One uppercase letter', hasUppercase),
      requirement('One number', hasNumber),
      const SizedBox(height: 12),
      PrimaryAction('Create Account', createAccount),
    ],
  );

  Widget requirement(String label, bool met) => ListTile(
    dense: true,
    leading: Icon(
      met ? Icons.check_circle : Icons.circle_outlined,
      color: forest,
    ),
    title: Text(label, style: const TextStyle(color: forest)),
  );
}
