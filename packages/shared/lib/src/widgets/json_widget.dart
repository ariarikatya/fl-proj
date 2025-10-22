import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared/src/app_colors.dart';
import 'package:shared/src/app_text_styles.dart';
import 'package:shared/src/widgets/app_text.dart';

class JsonWidget extends StatelessWidget {
  const JsonWidget({super.key, required this.json});

  final Map<String, Object?> json;

  @override
  Widget build(BuildContext context) {
    final body = JsonEncoder.withIndent('  ').convert(json);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.backgroundHover, borderRadius: BorderRadius.circular(14)),
      child: AppText(body, selectable: true, style: AppTextStyles.bodyMedium),
    );
  }
}
