import 'package:flutter/material.dart';

import 'package:routo/controllers/validators.dart';
import 'package:routo/core/theme/app_colors.dart';
import 'package:routo/core/utils/ui_helpers.dart';
import 'package:routo/views/auth/email_preview.dart';
import 'package:routo/views/auth/login_page.dart';
import 'package:routo/views/widgets/field.dart';
import 'package:routo/views/widgets/heading.dart';
import 'package:routo/views/widgets/primary_action.dart';
import 'package:routo/views/widgets/screen.dart';
import 'package:routo/controllers/auth_controller.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key, this.reset = false});
  final bool reset;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final form = GlobalKey<FormState>();
  final email = TextEditingController();

  @override
  void dispose() {
    email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Screen(
    background: widget.reset ? cream : Colors.white,
    children: [
      Heading(
        widget.reset ? 'Forgot Password' : 'Create Your Account',
        widget.reset
            ? 'Enter your email to request a password reset link.'
            : 'Use your Patan College email to join Routo.',
      ),
      const SizedBox(height: 24),
      Form(
        key: form,
        child: Field(
          'College Email',
          email,
          icon: Icons.mail_outline,
          keyboard: TextInputType.emailAddress,
          validator: collegeEmail,
        ),
      ),
      PrimaryAction(widget.reset ? 'Send Reset Link' : 'Send Verification', () {
        if (!form.currentState!.validate()) return;
        final address = email.text.trim();
        if (!widget.reset && AuthController.exists(address)) {
          notice(context, 'An account with this email already exists. Please login.');
          return;
        }
        showPage(context, EmailPreview(email: address, reset: widget.reset));
      }),
      const SizedBox(height: 28),
      Center(child: TextButton(
        onPressed: () => showPage(context, const LoginPage()),
        child: Text(widget.reset ? 'Remember your password?  Login' : 'Already have an account?  Login'),
      )),
      if (!widget.reset) Image.asset('assets/register-campus.webp', fit: BoxFit.contain),
    ],
  );
}