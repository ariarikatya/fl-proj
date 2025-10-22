import 'package:flutter/material.dart';

class GestureOverrideWidget extends StatelessWidget {
  const GestureOverrideWidget({super.key, required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Material(
        color: Colors.transparent,
        child: IgnorePointer(ignoring: true, child: child),
      ),
    );
  }
}
