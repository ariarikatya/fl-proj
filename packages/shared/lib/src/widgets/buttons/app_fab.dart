import 'package:flutter/material.dart';
import 'package:shared/src/extensions/context.dart';
import 'package:shared/src/icons.dart';
import 'package:shared/src/widgets/app_text.dart';

class AppFloatingActionButton$Add extends StatelessWidget {
  const AppFloatingActionButton$Add({super.key, required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 8),
        padding: EdgeInsets.fromLTRB(8, 12, 16, 12),
        decoration: BoxDecoration(color: context.ext.theme.buttonPrimary, borderRadius: BorderRadius.circular(16)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 4,
          children: [
            AppIcons.add.icon(context, color: context.ext.theme.backgroundDefault),
            AppText(text, color: context.ext.theme.backgroundDefault),
          ],
        ),
      ),
    );
  }
}
