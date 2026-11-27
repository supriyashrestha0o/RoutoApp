// import 'package:flutter/material.dart';
//
// import 'package:routo/core/utils/ui_helpers.dart';
// import 'package:routo/views/auth/create_account_page.dart';
// import 'package:routo/views/widgets/field.dart';
// import 'package:routo/views/widgets/heading.dart';
// import 'package:routo/views/widgets/primary_action.dart';
// import 'package:routo/views/widgets/screen.dart';
//
// class OtpPreview extends StatefulWidget {
//   const OtpPreview({super.key, required this.email});
//   final String email;
//
//   @override
//   State<OtpPreview> createState() => _OtpPreviewState();
// }
//
// class _OtpPreviewState extends State<OtpPreview> {
//   final code = TextEditingController();
//   final form = GlobalKey<FormState>();
//
//   @override
//   void dispose() {
//     code.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) => Screen(children: [
//     Heading('Enter OTP', 'Use the 6-digit preview code for ${widget.email}.'),
//     const SizedBox(height: 24),
//     Form(key: form, child: Field('6-digit code', code, keyboard: TextInputType.number,
//         validator: (value) => value?.trim() == '123456' ? null : 'Enter the preview code 123456')),
//     Center(child: TextButton(onPressed: () => notice(context, 'Preview code: 123456'),
//         child: const Text('Resend OTP'))),
//     const SizedBox(height: 28),
//     PrimaryAction('Continue', () {
//       if (form.currentState!.validate()) {
//         showPage(context, CreateAccountPage(email: widget.email));
//       }
//     }),
//     Center(child: TextButton(onPressed: () {
//       Navigator.of(context)..pop()..pop();
//     },
//         child: const Text('Change email'))),
//   ]);}

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:routo/core/utils/ui_helpers.dart';
import 'package:routo/services/email_code_service.dart';
import 'package:routo/views/auth/create_account_page.dart';
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
  final _service = EmailCodeService();

  Timer? _timer;
  int _cooldown = 30; // a code was just sent, so start the cooldown
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _startCooldown();
  }

  void _startCooldown() {
    _timer?.cancel();
    _cooldown = 30;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => _cooldown--);
      if (_cooldown <= 0) t.cancel();
    });
  }

  Future<void> _resend() async {
    if (_cooldown > 0 || _busy) return;
    setState(() => _busy = true);
    try {
      await _service.sendCode(widget.email);
      if (!mounted) return;
      setState(_startCooldown);
      notice(context, 'A new code has been sent.');
    } catch (_) {
      if (mounted) notice(context, 'Could not send the code. Try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _continue() async {
    if (_busy || !form.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      final ok = await _service.verifyCode(widget.email, code.text);
      if (!mounted) return;
      if (ok) {
        showPage(context, CreateAccountPage(email: widget.email));
      } else {
        notice(context, 'Invalid or expired code.');
      }
    } catch (_) {
      if (mounted) notice(context, 'Could not verify the code. Try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Screen(children: [
    Heading('Enter OTP', 'Enter the 6-digit code sent to ${widget.email}.'),
    const SizedBox(height: 24),
    Form(
      key: form,
      child: Field('6-digit code', code,
          keyboard: TextInputType.number,
          validator: (value) =>
          RegExp(r'^\d{6}$').hasMatch(value?.trim() ?? '') ? null : 'Enter the 6-digit code'),
    ),
    Center(
      child: TextButton(
        onPressed: _cooldown > 0 ? null : _resend,
        child: Text(_cooldown > 0 ? 'Resend OTP in ${_cooldown}s' : 'Resend OTP'),
      ),
    ),
    const SizedBox(height: 28),
    PrimaryAction(_busy ? 'Please wait...' : 'Continue', _continue),
    Center(
      child: TextButton(
        onPressed: () => Navigator.of(context)..pop()..pop(),
        child: const Text('Change email'),
      ),
    ),
  ]);
}
