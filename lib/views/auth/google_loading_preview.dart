import 'package:flutter/material.dart';

import 'package:routo/views/setup/preview_setup.dart';
import 'package:routo/views/widgets/heading.dart';
import 'package:routo/views/widgets/screen.dart';

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