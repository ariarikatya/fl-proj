import 'package:flutter/material.dart';
import 'package:shared/src/app_colors.dart';
import 'package:shared/src/app_text_styles.dart';
import 'package:shared/src/widgets/app_text.dart';

class AppPlaceholder extends StatelessWidget {
  const AppPlaceholder({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24),
      padding: EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.backgroundSubtle,
        borderRadius: BorderRadius.circular(14),
      ),
      child: AppText(text, style: AppTextStyles.bodyLarge, textAlign: TextAlign.center),
    );
  }
}
