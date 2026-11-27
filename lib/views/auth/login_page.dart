import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:routo/controllers/auth_controller.dart';
import 'package:routo/controllers/validators.dart';
import 'package:routo/core/theme/app_colors.dart';
import 'package:routo/core/utils/ui_helpers.dart';
import 'package:routo/views/auth/google_loading_preview.dart';
import 'package:routo/views/auth/google_preview.dart';
import 'package:routo/views/auth/register_page.dart';
import 'package:routo/views/setup/preview_setup.dart';
import 'package:routo/views/setup/setup_complete.dart';

// Colours taken from the Figma login frame.
const _mapDark = Color(0xff373d36); // same tone as the top of the map image
const _sheetTop = Color(0xfffaf3e8);
const _fieldFill = Color(0xfffdf9f2);
const _fieldBorder = Color(0xffd9cdbb);
const _googleFill = Color(0xffe3e9ee);
const _mutedText = Color(0xff9c917f);

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

  void login() {
    if (!form.currentState!.validate()) return;

    final account = AuthController.login(email.text, password.text);
    if (account == null) {
      notice(context, 'Incorrect email or password.');
      return;
    }

    final profile = account.profile;
    if (profile == null || profile.journey == null) {
      notice(context, 'Please finish setting up your profile.');
      showPage(context, const PreviewSetup());
      return;
    }

    showPage(
      context,
      GoogleLoadingPreview(next: (_) => SetupComplete(profile: profile)),
    );
  }

  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
    value: SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent,
    ),
    child: Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, box) {
          final width = box.maxWidth > 540 ? 540.0 : box.maxWidth;
          // login-route.webp is 421 x 396: show it whole so the
          // "PCPS College" label is no longer cropped.
          final imageHeight = width * 396 / 421;
          final statusBar = MediaQuery.paddingOf(context).top;
          const overlap = 24.0;

          return Center(
            child: SizedBox(
              width: width,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      color: _mapDark,
                      padding: EdgeInsets.only(top: statusBar),
                      child: Stack(
                        children: [
                          Image.asset(
                            'assets/login-route.webp',
                            width: width,
                            height: imageHeight,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            top: 4,
                            left: 8,
                            child: IconButton(
                              tooltip: 'Back',
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.black38,
                                foregroundColor: Colors.white,
                              ),
                              icon: const Icon(Icons.arrow_back),
                              onPressed: () => Navigator.of(context).maybePop(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // The white sheet slides up over the bottom of the map.
                    Transform.translate(
                      offset: const Offset(0, -overlap),
                      child: Container(
                        width: double.infinity,
                        constraints: BoxConstraints(
                          minHeight: box.maxHeight - imageHeight - statusBar,
                        ),
                        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [_sheetTop, Colors.white],
                          ),
                          borderRadius:
                          BorderRadius.vertical(top: Radius.circular(28)),
                        ),
                        child: Form(
                          key: form,
                          child: Column(
                            children: [
                              _LoginField(
                                label: 'College Email',
                                controller: email,
                                icon: Icons.mail_outline,
                                keyboard: TextInputType.emailAddress,
                                validator: collegeEmail,
                              ),
                              _LoginField(
                                label: 'Password',
                                controller: password,
                                icon: Icons.lock_outline,
                                obscure: hidden,
                                validator: requiredField,
                                suffix: IconButton(
                                  tooltip:
                                  hidden ? 'Show password' : 'Hide password',
                                  icon: Icon(
                                    hidden
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: Colors.black87,
                                  ),
                                  onPressed: () =>
                                      setState(() => hidden = !hidden),
                                ),
                              ),
                              const SizedBox(height: 6),
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: FilledButton(
                                  style: FilledButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: login,
                                  child: const Text('Login'),
                                ),
                              ),
                              TextButton(
                                onPressed: () => showPage(
                                  context,
                                  const RegisterPage(reset: true),
                                ),
                                child: const Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    color: teal,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    decoration: TextDecoration.underline,
                                    decorationColor: teal,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Row(
                                children: [
                                  Expanded(child: Divider()),
                                  Padding(
                                    padding:
                                    EdgeInsets.symmetric(horizontal: 14),
                                    child: Text(
                                      'OR',
                                      style: TextStyle(
                                        color: _mutedText,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Expanded(child: Divider()),
                                ],
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: FilledButton(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: _googleFill,
                                    foregroundColor: Colors.black87,
                                    textStyle: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () =>
                                      showPage(context, const GooglePreview()),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox.square(
                                        dimension: 20,
                                        child: GoogleLogo(size: 20),
                                      ),
                                      SizedBox(width: 10),
                                      Text('Continue with Google'),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Don’t have an account?',
                                    style: TextStyle(
                                      color: _mutedText,
                                      fontSize: 13,
                                    ),
                                  ),
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                      ),
                                      minimumSize: const Size(0, 36),
                                    ),
                                    onPressed: () =>
                                        showPage(context, const RegisterPage()),
                                    child: const Text(
                                      'Sign up',
                                      style: TextStyle(
                                        color: teal,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        decoration: TextDecoration.underline,
                                        decorationColor: teal,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
}

OutlineInputBorder _border(Color color) => OutlineInputBorder(
  borderRadius: BorderRadius.circular(10),
  borderSide: BorderSide(color: color),
);

/// Text field styled like the Figma login frame (used only on this page,
/// so the shared Field widget and the other screens are not affected).
class _LoginField extends StatelessWidget {
  const _LoginField({
    required this.label,
    required this.controller,
    required this.icon,
    this.keyboard,
    this.obscure = false,
    this.validator,
    this.suffix,
  });

  final String label;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType? keyboard;
  final bool obscure;
  final FormFieldValidator<String>? validator;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TextFormField(
      controller: controller,
      keyboardType: keyboard,
      obscureText: obscure,
      validator: validator,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xff3d4a49)),
        prefixIcon: Icon(icon, color: teal),
        suffixIcon: suffix,
        filled: true,
        fillColor: _fieldFill,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: _border(_fieldBorder),
        enabledBorder: _border(_fieldBorder),
        focusedBorder: _border(teal),
        errorBorder: _border(Colors.red),
        focusedErrorBorder: _border(Colors.red),
      ),
    ),
  );
}
