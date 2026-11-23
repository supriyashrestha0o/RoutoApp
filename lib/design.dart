import 'package:flutter/material.dart';

const teal = Color(0xff087f81);
const forest = Color(0xff006f60);
const mint = Color(0xffebf2ee);
const cream = Color(0xfff7eee2);
const sand = Color(0xffc49e70);
const lilac = Color(0xfff3f0f9);

Future<T?> showPage<T>(BuildContext context, Widget page) =>
    Navigator.of(context).push<T>(MaterialPageRoute(builder: (_) => page));

void notice(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
}

ThemeData routoTheme() => ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: teal, primary: teal),
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    titleTextStyle: TextStyle(
      color: Colors.black,
      fontSize: 21,
      fontWeight: FontWeight.w800,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white.withValues(alpha: .65),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      minimumSize: const Size(0, 52),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
    ),
  ),
);

class Screen extends StatelessWidget {
  const Screen({
    super.key,
    required this.children,
    this.title,
    this.background = Colors.white,
    this.steps,
    this.footer,
    this.actions,
    this.headerColor,
    this.drawer,
  });
  final List<Widget> children;
  final String? title;
  final Color background;
  final int? steps;
  final Widget? footer;
  final List<Widget>? actions;
  final Color? headerColor;
  final Widget? drawer;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: background,
    drawer: drawer,
    appBar: AppBar(
      backgroundColor: headerColor,
      foregroundColor: headerColor == null ? null : Colors.white,
      title: title == null ? null : Text(title!, style: TextStyle(
        color: headerColor == null ? null : Colors.white,
      )),
      actions: actions,
    ),
    bottomNavigationBar: footer,
    body: SafeArea(
      top: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            children: [
              if (steps != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      4,
                      (i) => Container(
                        width: 34,
                        height: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          color: i < steps! ? teal : const Color(0xffd3dbda),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
              ...children,
            ],
          ),
        ),
      ),
    ),
  );
}

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

class Panel extends StatelessWidget {
  const Panel({
    super.key,
    required this.child,
    this.color = Colors.white,
    this.border,
    this.padding = 16,
  });
  final Widget child;
  final Color color;
  final Color? border;
  final double padding;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: EdgeInsets.all(padding),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(16),
      border: border == null ? null : Border.all(color: border!),
    ),
    child: child,
  );
}

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

String? requiredField(String? value) =>
    value == null || value.trim().isEmpty ? 'Enter a value' : null;
