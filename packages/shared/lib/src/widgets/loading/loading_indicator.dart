import 'package:flutter/material.dart';
import 'package:shared/src/app_colors.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key, this.constraints, this.value});

  final BoxConstraints? constraints;
  final double? value;

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
      constraints: constraints,
      color: AppColors.accent,
      strokeCap: StrokeCap.round,
      backgroundColor: AppColors.accentLight,
      value: value,
    );
  }
}
