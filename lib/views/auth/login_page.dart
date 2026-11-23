import 'package:flutter/material.dart';

import 'package:routo/controllers/validators.dart';
import 'package:routo/core/theme/app_colors.dart';
import 'package:routo/core/utils/ui_helpers.dart';
import 'package:routo/models/journey.dart';
import 'package:routo/models/student_profile.dart';
import 'package:routo/views/auth/google_preview.dart';
import 'package:routo/views/auth/register_page.dart';
import 'package:routo/views/dashboard/dashboard.dart';
import 'package:routo/views/widgets/field.dart';
import 'package:routo/views/widgets/panel.dart';
import 'package:routo/views/widgets/primary_action.dart';
import 'package:routo/views/widgets/screen.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final form = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();
  bool hidden = true;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Screen(
    background: cream,
    children: [
      const Center(child: Text('Frontend preview · Use sample details')),
      ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Image.asset('assets/login-route.webp', height: 282, fit: BoxFit.cover),
      ),
      Panel(
        child: Form(
          key: form,
          child: Column(
            children: [
              Field(
                'College Email',
                email,
                icon: Icons.mail_outline,
                keyboard: TextInputType.emailAddress,
                validator: collegeEmail,
              ),
              Field(
                'Password',
                password,
                icon: Icons.lock_outline,
                obscure: hidden,
                validator: requiredField,
                suffix: IconButton(
                  tooltip: hidden ? 'Show password' : 'Hide password',
                  icon: Icon(
                    hidden
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  onPressed: () => setState(() => hidden = !hidden),
                ),
              ),
              PrimaryAction('Login', () {
                if (!form.currentState!.validate()) return;

                final profile = StudentProfile()
                  ..name = email.text.trim().split('@').first
                  ..journey = Journey(
                    'Kalanki',
                    'PCPS College',
                    DateTime.now().add(const Duration(minutes: 30)),
                    'Everyone',
                  );

                showPage(context, Dashboard(profile: profile));
              }),
              TextButton(
                onPressed: () =>
                    showPage(context, const RegisterPage(reset: true)),
                child: const Text('Forgot Password?'),
              ),
              const Divider(),
              PrimaryAction(
                'Continue with Google',
                    () => showPage(context, const GooglePreview()),
                secondary: true,
              ),
              TextButton(
                onPressed: () => showPage(context, const RegisterPage()),
                child: const Text('Sign up'),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}