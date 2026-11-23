import 'package:flutter/material.dart';

import 'package:routo/core/theme/app_colors.dart';

class Heading extends StatelessWidget {
  const Heading(
      this.title, [
        this.subtitle,
        this.color = Colors.black,
        this.center = false,
      ]);
  final String title;
  final String? subtitle;
  final Color color;
  final bool center;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 22),
    child: Column(
      crossAxisAlignment: center
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          textAlign: center ? TextAlign.center : TextAlign.start,
          style: TextStyle(
            fontSize: 30,
            height: 1.13,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            textAlign: center ? TextAlign.center : TextAlign.start,
            style: const TextStyle(fontSize: 16, height: 1.45, color: forest),
          ),
        ],
      ],
    ),
  );
}