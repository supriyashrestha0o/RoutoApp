import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:routo/core/theme/app_colors.dart';
import 'package:routo/core/utils/ui_helpers.dart';
import 'package:routo/models/journey.dart';
import 'package:routo/models/student_profile.dart';
import 'package:routo/views/auth/register_page.dart';
import 'package:routo/views/dashboard/dashboard.dart';
import 'package:routo/views/widgets/panel.dart';
import 'package:routo/views/widgets/screen.dart';

const _googleBlue = Color(0xff1a73e8);
const _appName = 'яouto.com';

/// A sample Google account shown in the chooser (frontend preview only).
class GoogleAccount {
  const GoogleAccount(this.name, this.email, this.color);
  final String name;
  final String email;
  final Color color;
}

const _accounts = [
  GoogleAccount(
    'Supriya Shrestha',
    'supriya.shrestha@patancollege.edu.np',
    Color(0xff1565c0),
  ),
  GoogleAccount(
    'Armita Thapa Magar',
    'armita.magar@patancollege.edu.np',
    Color(0xff7e57c2),
  ),
  GoogleAccount(
    'Shreya Maharjan',
    'shreya.maharjan@patancollege.edu.np',
    Color(0xff00897b),
  ),
  GoogleAccount(
    'Loren Gurung',
    'loren.gurung@patancollege.edu.np',
    Color(0xff78909c),
  ),
];

/// Screen 1: "Choose an account".
class GooglePreview extends StatelessWidget {
  const GooglePreview({super.key});

  @override
  Widget build(BuildContext context) => Screen(
    background: mint,
    children: [
      Panel(
        padding: 20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _GoogleHeader(),
            const SizedBox(height: 20),
            const Text(
              'Choose an account',
              style: TextStyle(fontSize: 26, height: 1.2, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            const Text.rich(
              TextSpan(
                text: 'to continue to ',
                style: TextStyle(fontSize: 14, color: Colors.black87),
                children: [
                  TextSpan(
                    text: _appName,
                    style: TextStyle(
                      color: _googleBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            for (final account in _accounts) ...[
              const Divider(height: 1),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: _Initial(account),
                title: Text(
                  account.name,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  account.email,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
                onTap: () =>
                    showPage(context, GoogleConsentPreview(account: account)),
              ),
            ],
            const Divider(height: 1),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.account_circle_outlined),
              title: const Text('Use another account'),
              onTap: () => showPage(context, const RegisterPage()),
            ),
          ],
        ),
      ),
    ],
  );
}

/// Screen 2: "Sign in to яouto.com" permissions page.
class GoogleConsentPreview extends StatelessWidget {
  const GoogleConsentPreview({super.key, required this.account});
  final GoogleAccount account;

  void _continue(BuildContext context) {
    final profile = StudentProfile()
      ..name = account.name
      ..journey = Journey(
        'Kalanki',
        'PCPS College',
        DateTime.now().add(const Duration(minutes: 30)),
        'Everyone',
      );

    // Clears the sign-in pages. The first route is kept so the
    // dashboard's Logout (popUntil first) still works.
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => Dashboard(profile: profile)),
          (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) => Screen(
    background: mint,
    children: [
      Panel(
        padding: 20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _GoogleHeader(),
            const SizedBox(height: 20),
            const Text(
              'Sign in to $_appName',
              style: TextStyle(fontSize: 26, height: 1.2, color: Colors.black87),
            ),
            const SizedBox(height: 20),
            InkWell(
              borderRadius: BorderRadius.circular(40),
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.fromLTRB(6, 6, 12, 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(color: Colors.black26),
                ),
                child: Row(
                  children: [
                    _Initial(account, radius: 14),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        account.email,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down, color: Colors.black54),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'You’ll share this info about you',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const _ShareRow(Icons.account_circle_outlined, 'Name and profile picture'),
            const _ShareRow(Icons.mail_outline, 'Email address'),
            const SizedBox(height: 12),
            const Text(
              'Before using this app, you can review яouto’s privacy policy and terms of service.',
              style: TextStyle(fontSize: 12, height: 1.5, color: Colors.black54),
            ),
            const SizedBox(height: 10),
            const Text.rich(
              TextSpan(
                text: 'To make changes at any time, go to your ',
                style: TextStyle(fontSize: 12, height: 1.5, color: Colors.black54),
                children: [
                  TextSpan(
                    text: 'Google Account',
                    style: TextStyle(color: _googleBlue),
                  ),
                  TextSpan(text: '. Learn more about '),
                  TextSpan(
                    text: 'Sign in with Google',
                    style: TextStyle(color: _googleBlue),
                  ),
                  TextSpan(text: '.'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: const StadiumBorder(),
                      minimumSize: const Size(0, 52),
                    ),
                    onPressed: () {
                      // Back to the Login page.
                      Navigator.of(context)
                        ..pop()
                        ..pop();
                    },
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(shape: const StadiumBorder()),
                    onPressed: () => _continue(context),
                    child: const Text('Continue'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ],
  );
}

/// "G  Sign in with Google" with a divider underneath.
class _GoogleHeader extends StatelessWidget {
  const _GoogleHeader();

  @override
  Widget build(BuildContext context) => const Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          SizedBox.square(dimension: 22, child: GoogleLogo(size: 22)),
          SizedBox(width: 12),
          Text(
            'Sign in with Google',
            style: TextStyle(fontSize: 15, color: Colors.black87),
          ),
        ],
      ),
      SizedBox(height: 14),
      Divider(height: 1),
    ],
  );
}

/// Round avatar showing the first letter of the account name.
class _Initial extends StatelessWidget {
  const _Initial(this.account, {this.radius = 16});
  final GoogleAccount account;
  final double radius;

  @override
  Widget build(BuildContext context) => CircleAvatar(
    radius: radius,
    backgroundColor: account.color,
    child: Text(
      account.name[0],
      style: TextStyle(
        color: Colors.white,
        fontSize: radius,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}

/// One row of the "You’ll share this info" list.
class _ShareRow extends StatelessWidget {
  const _ShareRow(this.icon, this.label);
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      children: [
        Icon(icon, color: Colors.black54),
        const SizedBox(width: 16),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
      ],
    ),
  );
}

/// The official four-colour Google "G" (red, yellow, green, blue).
class GoogleLogo extends StatelessWidget {
  const GoogleLogo({super.key, this.size = 76});
  final double size;

  static const String _svg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48">
  <path fill="#EA4335" d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5z"/>
  <path fill="#4285F4" d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z"/>
  <path fill="#FBBC05" d="M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.27-3.14.76-4.59l-7.98-6.19C.92 16.46 0 20.12 0 24c0 3.88.92 7.54 2.56 10.78l7.97-6.19z"/>
  <path fill="#34A853" d="M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.15 1.45-4.92 2.3-8.16 2.3-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z"/>
</svg>
''';

  @override
  Widget build(BuildContext context) => Center(
    child: SvgPicture.string(
      _svg,
      width: size,
      height: size,
      semanticsLabel: 'Google',
    ),
  );
}
