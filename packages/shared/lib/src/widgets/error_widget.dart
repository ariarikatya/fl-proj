import 'package:flutter/material.dart';
import 'package:shared/src/extensions/context.dart';
import 'package:shared/src/app_text_styles.dart';
import 'package:shared/src/widgets/app_text.dart';

class AppErrorWidget extends StatelessWidget {
  const AppErrorWidget({super.key, required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(24),
        child: AppText(error, style: AppTextStyles.bodyLarge.copyWith(color: context.ext.colors.error)),
      ),
    );
  }
}
