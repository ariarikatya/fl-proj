import 'package:flutter/material.dart';
import 'package:shared/src/extensions/context.dart';

class AppPage extends StatelessWidget {
  const AppPage({super.key, required this.child, this.safeAreaBuilder, this.appBar, this.backgroundColor});

  final Widget child;
  final SafeArea Function(Widget child)? safeAreaBuilder;
  final PreferredSizeWidget? appBar;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      backgroundColor: backgroundColor ?? context.ext.theme.backgroundDefault,
      body: safeAreaBuilder?.call(child) ?? SafeArea(child: child),
    );
  }
}
