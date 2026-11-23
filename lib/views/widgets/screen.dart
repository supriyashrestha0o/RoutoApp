import 'package:flutter/material.dart';

import 'package:routo/core/theme/app_colors.dart';

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