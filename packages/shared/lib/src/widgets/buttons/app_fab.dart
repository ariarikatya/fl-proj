import 'package:flutter/material.dart';
import 'package:shared/src/extensions/context.dart';
import 'package:shared/src/feather_icons.dart';
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
        padding: EdgeInsets.fromLTRB(8, 10, 16, 10),
        decoration: BoxDecoration(color: context.ext.colors.black[900], borderRadius: BorderRadius.circular(10)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 2,
          children: [
            FIcons.plus.icon(context, size: 16, color: context.ext.colors.white[100]),
            AppText(
              text,
              color: context.ext.colors.white[100],
              style: context.ext.textTheme.bodyMedium?.copyWith(
                color: context.ext.colors.white[100],
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
