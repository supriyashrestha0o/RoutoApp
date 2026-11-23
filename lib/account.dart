import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'design.dart';
import 'dashboard.dart';
import 'journeys.dart';
import 'ride_model.dart';

String? collegeEmail(String? value) {
  if (!RegExp(
    r'^[^@\s]+@patancollege\.edu\.np$',
    caseSensitive: false,
  ).hasMatch(value?.trim() ?? '')) {
    return 'Enter your Patan College email address';
  }
  return null;
}

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
        showPage(context, EmailPreview(email: email.text.trim(), reset: widget.reset));
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

class PreviewSetup extends StatefulWidget {
  const PreviewSetup({super.key, this.profile});
  final StudentProfile? profile;

  @override
  State<PreviewSetup> createState() => _PreviewSetupState();
}

class _PreviewSetupState extends State<PreviewSetup> {
  final form = GlobalKey<FormState>();
  late final name = TextEditingController(text: widget.profile?.name);
  late final age = TextEditingController(text: widget.profile?.age.toString());
  late String section = (widget.profile?.section.isEmpty ?? true)
      ? 'Section A'
      : widget.profile!.section;

  late String gender = (widget.profile?.gender.isEmpty ?? true)
      ? 'Prefer not to say'
      : widget.profile!.gender;
  late Uint8List? photo = widget.profile?.photo;

  @override
  void dispose() {
    name.dispose();
    age.dispose();
    super.dispose();
  }

  Future<void> pickPhoto() async {
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 900,
      );
      final bytes = await file?.readAsBytes();
      if (mounted && bytes != null) setState(() => photo = bytes);
    } catch (_) {
      if (mounted) notice(context, 'Could not open photos. Please try again.');
    }
  }

  void save() {
    if (!form.currentState!.validate()) return;
    final profile = widget.profile ?? StudentProfile();
    profile
      ..name = name.text.trim()
      ..age = int.parse(age.text.trim())
      ..section = section
      ..gender = gender
      ..photo = photo;
    if (widget.profile != null) {
      Navigator.of(context).pop();
      return;
    }
    showPage(context, JourneySetup(profile: profile));
  }

  @override
  Widget build(BuildContext context) => Screen(
    background: mint,
    steps: widget.profile == null ? 1 : null,
    children: [
      Heading(
        widget.profile == null ? 'Create Your Profile' : 'Edit Profile',
        'Frontend preview. Profile changes last for this session.',
      ),
      Center(
        child: InkWell(
          onTap: pickPhoto,
          child: Column(
            children: [
              ProfileAvatar(
                photo: photo,
                radius: 51,
                fallback: Icons.camera_alt_outlined,
              ),
              const SizedBox(height: 8),
              Text(photo == null ? 'Add Photo' : 'Change Photo'),
            ],
          ),
        ),
      ),
      const SizedBox(height: 24),
      Form(
        key: form,
        child: Column(
          children: [
            Field(
              'Full Name',
              name,
              icon: Icons.person_outline,
              validator: requiredField,
            ),
            DropdownButtonFormField<String>(
              initialValue: section,
              decoration: const InputDecoration(labelText: 'Section'),
              items: [
                'Section A',
                'Section B',
                'Section C',
                'Other',
              ].map(option).toList(),
              onChanged: (value) => setState(() => section = value!),
            ),
            const SizedBox(height: 14),
            Field(
              'Age',
              age,
              icon: Icons.calendar_today_outlined,
              keyboard: TextInputType.number,
              validator: (value) {
                final number = int.tryParse(value?.trim() ?? '');
                return number == null || number < 1 || number > 120
                    ? 'Enter a valid age'
                    : null;
              },
            ),
            DropdownButtonFormField<String>(
              initialValue: gender,
              decoration: const InputDecoration(labelText: 'Gender'),
              items: [
                'Male',
                'Female',
                'Other',
                'Prefer not to say',
              ].map(option).toList(),
              onChanged: (value) => setState(() => gender = value!),
            ),
          ],
        ),
      ),
      PrimaryAction(widget.profile == null ? 'Continue' : 'Save Profile', save),
    ],
  );
}

DropdownMenuItem<String> option(String value) =>
    DropdownMenuItem(value: value, child: Text(value));

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    this.photo,
    this.radius = 24,
    this.fallback = Icons.person_outline,
  });
  final Uint8List? photo;
  final double radius;
  final IconData fallback;

  @override
  Widget build(BuildContext context) => CircleAvatar(
    radius: radius,
    backgroundColor: sand,
    foregroundImage: photo == null ? null : MemoryImage(photo!),
    child: Icon(fallback, color: Colors.white, size: radius),
  );
}

class StudentProfile {
  String name = '';
  int age = 18;
  String gender = '';
  String section = '';
  Uint8List? photo;
  bool driver = false;
  String vehicle = '';
  String model = '';
  int capacity = 1;
  Journey? journey;
}

class GooglePreview extends StatelessWidget {
  const GooglePreview({super.key});

  @override
  Widget build(BuildContext context) => Screen(children: [
    const SizedBox(height: 24),
    const Text('G', textAlign: TextAlign.center, style: TextStyle(
      color: Color(0xff4285f4), fontSize: 76, fontWeight: FontWeight.w900)),
    const Heading('Sign in with Google', 'Choose a sample account to continue to Routo.', Colors.black, true),
    const SizedBox(height: 12),
    for (final account in ['Supriya Shrestha', 'Sunita Shrestha'])
      ListTile(
        leading: CircleAvatar(child: Text(account[0])),
        title: Text(account),
        subtitle: const Text('Sample college account'),
        onTap: () => showPage(context, const GoogleLoadingPreview()),
      ),
    const Divider(),
    ListTile(
      leading: const Icon(Icons.account_circle_outlined),
      title: const Text('Use another account'),
      onTap: () => showPage(context, const RegisterPage()),
    ),
  ]);
}

class GoogleLoadingPreview extends StatefulWidget {
  const GoogleLoadingPreview({super.key});

  @override
  State<GoogleLoadingPreview> createState() => _GoogleLoadingPreviewState();
}

class _GoogleLoadingPreviewState extends State<GoogleLoadingPreview> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 1100), () {
      if (mounted && ModalRoute.of(context)?.isCurrent == true) {
        Navigator.of(context).pushReplacement(MaterialPageRoute<void>(
          builder: (_) => const PreviewSetup(),
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) => const Screen(children: [
    SizedBox(height: 130),
    Text('G', textAlign: TextAlign.center, style: TextStyle(
      color: Color(0xff4285f4), fontSize: 76, fontWeight: FontWeight.w900)),
    Heading('Signing you in…', 'Opening the frontend preview.', Colors.black, true),
    Center(child: CircularProgressIndicator()),
  ]);
}

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
