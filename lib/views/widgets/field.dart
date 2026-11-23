import 'package:flutter/material.dart';

class Field extends StatelessWidget {
  const Field(
      this.label,
      this.controller, {
        super.key,
        this.icon,
        this.keyboard,
        this.onChanged,
        this.validator,
        this.obscure = false,
        this.suffix,
        this.lines = 1,
      });
  final String label;
  final TextEditingController controller;
  final IconData? icon;
  final Widget? suffix;
  final TextInputType? keyboard;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final bool obscure;
  final int lines;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TextFormField(
      controller: controller,
      keyboardType: keyboard,
      obscureText: obscure,
      maxLines: lines,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon == null ? null : Icon(icon),
        suffixIcon: suffix,
      ),
    ),
  );
}

DropdownMenuItem<String> option(String value) =>
    DropdownMenuItem(value: value, child: Text(value));
