import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class AppThemeWidget extends InheritedWidget {
  const AppThemeWidget({
    super.key,
    required this.theme,
    required Map<String, AppTheme> $themes,
    required this.changeTheme,
    required super.child,
  }) : _themes = $themes;

  final AppTheme theme;
  final Map<String, AppTheme> _themes;
  final void Function(AppTheme theme) changeTheme;

  UnmodifiableMapView<String, AppTheme> get themes => UnmodifiableMapView(_themes);

  static AppThemeWidget of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppThemeWidget>()!;
  }

  @override
  bool updateShouldNotify(AppThemeWidget oldWidget) => oldWidget.theme != theme;
}

class AppThemeScope extends StatefulWidget {
  const AppThemeScope({super.key, required this.initialTheme, required this.themes, required this.child});

  final AppTheme initialTheme;
  final Map<String, AppTheme> themes;
  final Widget child;

  @override
  State<AppThemeScope> createState() => _AppThemeScopeState();
}

class _AppThemeScopeState extends State<AppThemeScope> {
  late AppTheme theme = widget.initialTheme;

  void changeTheme(AppTheme $theme) {
    if ($theme != theme) {
      setState(() => theme = $theme);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppThemeWidget(theme: theme, $themes: widget.themes, changeTheme: changeTheme, child: widget.child);
  }
}
