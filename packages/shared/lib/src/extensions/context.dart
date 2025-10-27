import 'package:flutter/material.dart';
import 'package:shared/src/features/theme/app_theme.dart';
import 'package:shared/src/features/theme/app_theme_widget.dart';

extension type ContextExt(BuildContext self) {
  Future<T?> push<T>(Widget page) async {
    return await Navigator.push<T?>(self, MaterialPageRoute(builder: (_) => page));
  }

  Future<T?> replace<T extends Object?, TO extends Object?>(Widget page) {
    return Navigator.pushReplacement<T, TO>(self, MaterialPageRoute(builder: (_) => page), result: null);
  }

  void pop<T extends Object?>([T? result]) => Navigator.pop(self, result);

  AppTheme get theme => AppThemeWidget.of(self).theme;
}

extension ContextX on BuildContext {
  ContextExt get ext => ContextExt(this);
}
