import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class ProfileButton extends StatelessWidget {
  const ProfileButton({super.key, required this.icon, required this.title, required this.onTap});

  final AppIcons icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: context.ext.theme.backgroundHover)),
        ),
        child: Row(
          spacing: 8,
          children: [
            icon.icon(context),
            Expanded(child: AppText(title, overflow: TextOverflow.ellipsis)),
            AppIcons.chevronForward.icon(context),
          ],
        ),
      ),
    );
  }
}
