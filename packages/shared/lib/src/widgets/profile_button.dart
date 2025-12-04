import 'package:flutter/material.dart';
import 'package:shared/src/extensions/context.dart';
import 'package:shared/src/feather_icons.dart';
import 'package:shared/src/widgets/app_text.dart';

class ProfileButton extends StatelessWidget {
  const ProfileButton({super.key, required this.icon, required this.title, required this.onTap});

  final FIcons icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border(bottom: BorderSide(color: context.ext.colors.white[300])),
        ),
        child: Row(
          spacing: 8,
          children: [
            icon.icon(context),
            Expanded(child: AppText(title, overflow: TextOverflow.ellipsis)),
            FIcons.arrow_right.icon(context),
          ],
        ),
      ),
    );
  }
}
