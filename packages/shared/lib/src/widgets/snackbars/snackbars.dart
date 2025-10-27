import 'package:flutter/material.dart';
import 'package:shared/src/extensions/context.dart';
import 'package:shared/src/app_text_styles.dart';
import 'package:shared/src/initialization.dart';
import 'package:shared/src/widgets/app_text.dart';

SnackBar errorSnackbar(String error) {
  final theme = navigatorKey.currentContext?.ext.theme;
  return SnackBar(
    content: AppText(
      error,
      style: AppTextStyles.bodyLarge.copyWith(color: theme?.backgroundDefault, overflow: TextOverflow.ellipsis),
      maxLines: 20,
    ),
    behavior: SnackBarBehavior.floating,
    duration: Duration(seconds: 3),
    backgroundColor: theme?.error,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
  );
}

SnackBar successSnackbar(String text) {
  final theme = navigatorKey.currentContext?.ext.theme;
  return SnackBar(
    content: AppText(
      text,
      style: AppTextStyles.bodyLarge.copyWith(color: theme?.backgroundDefault, overflow: TextOverflow.ellipsis),
      maxLines: 5,
    ),
    behavior: SnackBarBehavior.floating,
    duration: Duration(seconds: 3),
    backgroundColor: theme?.success,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
  );
}

SnackBar infoSnackbar(Widget child, {double bottom = 24}) {
  double bottomPadding = 24;
  if (navigatorKey.currentContext case BuildContext ctx) bottomPadding = MediaQuery.of(ctx).padding.bottom;
  final theme = navigatorKey.currentContext?.ext.theme;

  return SnackBar(
    content: child,
    behavior: SnackBarBehavior.floating,
    duration: Duration(seconds: 3),
    backgroundColor: theme?.backgroundHover,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    margin: EdgeInsets.only(left: 24, right: 24, bottom: bottomPadding + bottom),
  );
}
