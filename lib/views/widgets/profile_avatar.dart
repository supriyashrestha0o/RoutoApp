import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:routo/core/theme/app_colors.dart';

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