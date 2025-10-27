import 'package:flutter/material.dart';
import 'package:shared/src/extensions/context.dart';

class AppSwitch extends StatelessWidget {
  const AppSwitch({super.key, required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Switch(
      padding: EdgeInsets.zero,
      value: value,
      onChanged: onChanged,
      activeThumbColor: context.ext.theme.backgroundDefault,
      inactiveThumbColor: context.ext.theme.iconsMuted,
      activeTrackColor: context.ext.theme.accent,
      inactiveTrackColor: context.ext.theme.backgroundHover,
    );
  }
}
