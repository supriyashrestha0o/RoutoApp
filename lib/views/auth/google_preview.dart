import 'package:flutter/material.dart';

import 'package:routo/core/utils/ui_helpers.dart';
import 'package:routo/views/auth/google_loading_preview.dart';
import 'package:routo/views/auth/register_page.dart';
import 'package:routo/views/widgets/heading.dart';
import 'package:routo/views/widgets/screen.dart';
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