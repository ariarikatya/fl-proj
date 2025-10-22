import 'package:flutter/material.dart';
import 'package:shared/src/app_colors.dart';
import 'package:shared/src/app_text_styles.dart';
import 'package:shared/src/widgets/app_text.dart';

SnackBar errorSnackbar(String error) {
  return SnackBar(
    content: AppText(
      error,
      style: AppTextStyles.bodyLarge.copyWith(
        color: AppColors.backgroundDefault,
        overflow: TextOverflow.ellipsis,
      ),
      maxLines: 20,
    ),
    behavior: SnackBarBehavior.floating,
    duration: Duration(seconds: 3),
    backgroundColor: AppColors.error,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
  );
}

SnackBar successSnackbar(String text) {
  return SnackBar(
    content: AppText(
      text,
      style: AppTextStyles.bodyLarge.copyWith(
        color: AppColors.backgroundDefault,
        overflow: TextOverflow.ellipsis,
      ),
      maxLines: 5,
    ),
    behavior: SnackBarBehavior.floating,
    duration: Duration(seconds: 3),
    backgroundColor: AppColors.success,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
  );
}
