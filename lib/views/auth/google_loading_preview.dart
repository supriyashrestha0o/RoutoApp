import 'package:flutter/material.dart';

import 'package:routo/views/setup/preview_setup.dart';
import 'package:routo/views/widgets/heading.dart';
import 'package:routo/views/widgets/screen.dart';
import 'package:routo/views/auth/google_preview.dart';

class GoogleLoadingPreview extends StatefulWidget {
  const GoogleLoadingPreview({super.key, this.next});
  final WidgetBuilder? next;

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
          builder: widget.next ?? (_) => const PreviewSetup(),
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) => const Screen(children: [
    SizedBox(height: 130),
    const GoogleLogo(size: 40),
    const SizedBox(height: 16),
    const Heading('Signing you in…', 'Opening the frontend preview.', Colors.black, true),
    Center(child: CircularProgressIndicator()),
  ]);
}