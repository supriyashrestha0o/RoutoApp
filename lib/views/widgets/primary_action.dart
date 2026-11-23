import 'package:flutter/material.dart';

class PrimaryAction extends StatelessWidget {
  const PrimaryAction(
      this.label,
      this.onPressed, {
        super.key,
        this.secondary = false,
      });
  final String label;
  final VoidCallback? onPressed;
  final bool secondary;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 12),
    child: SizedBox(
      width: double.infinity,
      height: 52,
      child: secondary
          ? OutlinedButton(onPressed: onPressed, child: Text(label))
          : FilledButton(onPressed: onPressed, child: Text(label)),
    ),
  );
}
