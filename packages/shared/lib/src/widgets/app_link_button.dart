import 'package:flutter/material.dart';
import 'package:shared/src/app_text_styles.dart';
import 'package:shared/src/widgets/app_text.dart';

class AppLinkButton extends StatelessWidget {
  const AppLinkButton({super.key, required this.text, this.onTap, this.style});

  final String text;
  final VoidCallback? onTap;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null;
    return GestureDetector(
      onTap: onTap,
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: EdgeInsets.fromLTRB(6, 4, 6, 4),
          child: AppText(
            text,
            style: (style ?? AppTextStyles.bodyLarge).copyWith(
              decoration: TextDecoration.underline,
              fontWeight: FontWeight.bold,
              color: isDisabled ? Colors.grey : null,
            ),
          ),
        ),
      ),
    );
  }
}
