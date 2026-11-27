// import 'package:flutter/material.dart';
//
// import 'package:routo/core/theme/app_colors.dart';
// import 'package:routo/core/utils/ui_helpers.dart';
// import 'package:routo/views/auth/otp_preview.dart';
// import 'package:routo/views/auth/reset_password_preview.dart';
// import 'package:routo/views/widgets/heading.dart';
// import 'package:routo/views/widgets/panel.dart';
// import 'package:routo/views/widgets/primary_action.dart';
// import 'package:routo/views/widgets/screen.dart';
//
// class EmailPreview extends StatelessWidget {
//   const EmailPreview({super.key, required this.email, required this.reset});
//   final String email;
//   final bool reset;
//
//   @override
//   Widget build(BuildContext context) => Screen(background: reset ? cream : Colors.white, children: [
//     const SizedBox(height: 20),
//     Image.asset(reset ? 'assets/reset-mail.webp' : 'assets/verified-mail.webp', height: 215),
//     const SizedBox(height: 28),
//     Heading(reset ? 'Check Your Email' : 'Verify Your College Email', email, Colors.black, true),
//     Panel(color: lilac, child: ListTile(
//       leading: const Icon(Icons.info_outline, color: forest),
//       title: Text(reset ? 'Preview of the password reset email step.' : 'Preview code: 123456'),
//       subtitle: const Text('This frontend preview does not send email.'),
//     )),
//     PrimaryAction(reset ? 'Open Preview Reset Link' : 'Verify by OTP',
//             () => showPage(context, reset ? const ResetPasswordPreview() : OtpPreview(email: email))),
//   ]);
// }

import 'package:flutter/material.dart';

import 'package:routo/core/theme/app_colors.dart';
import 'package:routo/core/utils/ui_helpers.dart';
import 'package:routo/services/email_code_service.dart';
import 'package:routo/views/auth/otp_preview.dart';
import 'package:routo/views/auth/reset_password_preview.dart';
import 'package:routo/views/widgets/heading.dart';
import 'package:routo/views/widgets/panel.dart';
import 'package:routo/views/widgets/primary_action.dart';
import 'package:routo/views/widgets/screen.dart';

class EmailPreview extends StatefulWidget {
  const EmailPreview({super.key, required this.email, required this.reset});
  final String email;
  final bool reset;

  @override
  State<EmailPreview> createState() => _EmailPreviewState();
}

class _EmailPreviewState extends State<EmailPreview> {
  final _service = EmailCodeService();
  bool _sending = false;

  Future<void> _sendAndContinue() async {
    if (_sending) return;
    setState(() => _sending = true);
    try {
      await _service.sendCode(widget.email);
      if (!mounted) return;
      showPage(context, OtpPreview(email: widget.email));
    } catch (e) {
  debugPrint('SEND CODE ERROR: $e');
  if (mounted) {
    notice(context, 'ERROR: $e');
  }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reset = widget.reset;
    return Screen(background: reset ? cream : Colors.white, children: [
      const SizedBox(height: 20),
      Image.asset(reset ? 'assets/reset-mail.webp' : 'assets/verified-mail.webp', height: 215),
      const SizedBox(height: 28),
      Heading(reset ? 'Check Your Email' : 'Verify Your College Email', widget.email, Colors.black, true),
      Panel(color: lilac, child: ListTile(
        leading: const Icon(Icons.info_outline, color: forest),
        title: Text(reset
            ? 'Preview of the password reset email step.'
            : "We'll email a 6-digit code to this address."),
        subtitle: Text(reset
            ? 'This frontend preview does not send email.'
            : 'The code expires in 5 minutes.'),
      )),
      PrimaryAction(
        reset ? 'Open Preview Reset Link' : (_sending ? 'Sending...' : 'Verify by OTP'),
            () => reset ? showPage(context, const ResetPasswordPreview()) : _sendAndContinue(),
      ),
    ]);
  }
}