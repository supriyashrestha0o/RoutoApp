import 'package:flutter/material.dart';

import 'package:routo/core/theme/app_colors.dart';
import 'package:routo/core/utils/ui_helpers.dart';
import 'package:routo/views/auth/otp_preview.dart';
import 'package:routo/views/auth/reset_password_preview.dart';
import 'package:routo/views/widgets/heading.dart';
import 'package:routo/views/widgets/panel.dart';
import 'package:routo/views/widgets/primary_action.dart';
import 'package:routo/views/widgets/screen.dart';

class EmailPreview extends StatelessWidget {
  const EmailPreview({super.key, required this.email, required this.reset});
  final String email;
  final bool reset;

  @override
  Widget build(BuildContext context) => Screen(background: reset ? cream : Colors.white, children: [
    const SizedBox(height: 20),
    Image.asset(reset ? 'assets/reset-mail.webp' : 'assets/verified-mail.webp', height: 215),
    const SizedBox(height: 28),
    Heading(reset ? 'Check Your Email' : 'Verify Your College Email', email, Colors.black, true),
    Panel(color: lilac, child: ListTile(
      leading: const Icon(Icons.info_outline, color: forest),
      title: Text(reset ? 'Preview of the password reset email step.' : 'Preview code: 123456'),
      subtitle: const Text('This frontend preview does not send email.'),
    )),
    PrimaryAction(reset ? 'Open Preview Reset Link' : 'Verify by OTP',
            () => showPage(context, reset ? const ResetPasswordPreview() : OtpPreview(email: email))),
  ]);
}