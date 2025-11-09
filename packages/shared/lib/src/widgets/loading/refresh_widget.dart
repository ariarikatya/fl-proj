import 'package:flutter/material.dart';
import 'package:shared/src/extensions/context.dart';

class RefreshWidget extends StatelessWidget {
  const RefreshWidget({super.key, required this.refresh, required this.child});

  final Widget child;
  final Future<void> Function() refresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: refresh,
      color: context.ext.theme.accent,
      backgroundColor: context.ext.theme.accentLight,
      child: child,
    );
  }
}
