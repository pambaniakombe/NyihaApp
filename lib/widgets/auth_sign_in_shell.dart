import 'package:flutter/material.dart';

import '../theme/nyiha_colors.dart';

/// Vertically and horizontally centers sign-in content; caps width on wide screens.
class AuthSignInShell extends StatelessWidget {
  const AuthSignInShell({
    super.key,
    required this.child,
    this.maxWidth = 420,
    this.horizontalPadding = 24,
  });

  final Widget child;
  final double maxWidth;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(horizontalPadding, 20, horizontalPadding, 36),
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Shared filled outline style for auth fields (user + admin).
InputDecoration authInputDecoration(
  BuildContext context, {
  String? hintText,
  Widget? prefixIcon,
  Widget? suffixIcon,
  bool dense = false,
}) {
  final ax = NyihaColors.accent(context);
  final dark = Theme.of(context).brightness == Brightness.dark;
  final fill = dark ? Colors.white.withOpacity(0.06) : Colors.white.withOpacity(0.92);
  return InputDecoration(
    hintText: hintText,
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: fill,
    contentPadding: EdgeInsets.symmetric(
      horizontal: 16,
      vertical: dense ? 14 : 16,
    ),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: ax.withOpacity(0.18)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: ax.withOpacity(0.55), width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: Colors.redAccent.withOpacity(0.6)),
    ),
  );
}

/// Full-width primary / secondary actions in a column with consistent gaps.
class AuthButtonColumn extends StatelessWidget {
  const AuthButtonColumn({
    super.key,
    required this.children,
    this.gap = 12,
  });

  final List<Widget> children;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) SizedBox(height: gap),
          children[i],
        ],
      ],
    );
  }
}
