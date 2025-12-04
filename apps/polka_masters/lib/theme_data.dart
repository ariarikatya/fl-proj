import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

final mastersTheme = ThemeData(
  extensions: [polkaMastersThemeExtension],
  textTheme: polkaTextTheme,
  radioTheme: RadioThemeData(
    backgroundColor: WidgetStateColor.resolveWith((_) => Colors.transparent),
    fillColor: WidgetStateColor.resolveWith(
      (state) => switch (state.firstOrNull) {
        WidgetState.selected => polkaMastersThemeExtension.black[900],
        _ => polkaMastersThemeExtension.black[500],
      },
    ),
    visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
  ),
);
