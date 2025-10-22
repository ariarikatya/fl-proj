import 'package:flutter/material.dart';
import 'package:shared/src/app_colors.dart';
import 'package:shared/src/app_text_styles.dart';
import 'package:shared/src/dev/json_equatable.dart';
import 'package:shared/src/dev/debug_model_mbs.dart';
import 'package:shared/src/utils.dart';
import 'package:shared/src/widgets/app_text.dart';

class DebugWidget extends StatelessWidget {
  const DebugWidget({super.key, required this.model, required this.child});

  final JsonEquatable model;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (devMode) {
      final widget = Stack(
        alignment: Alignment.center,
        children: [
          child,
          Positioned(
            right: 8,
            top: 4,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.4,
                child: Container(
                  padding: EdgeInsets.fromLTRB(4, 2, 4, 2),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: AppColors.accentLight),
                  child: AppText('debug', style: AppTextStyles.bodySmall.copyWith(color: AppColors.accent)),
                ),
              ),
            ),
          ),
        ],
      );

      return GestureDetector(onLongPress: () => showDebugModel(context, model), child: widget);
    }

    return child;
  }
}
