import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class SmallChip extends StatelessWidget {
  const SmallChip({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: context.ext.theme.backgroundHover, borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
      child: AppText.secondary(text, style: AppTextStyles.bodySmall500),
    );
  }
}
