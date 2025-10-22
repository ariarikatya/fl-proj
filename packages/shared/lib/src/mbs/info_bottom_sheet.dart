import 'package:flutter/material.dart';
import 'package:shared/src/app_colors.dart';
import 'package:shared/src/app_text_styles.dart';
import 'package:shared/src/extensions/context.dart';
import 'package:shared/src/mbs/mbs_base.dart';
import 'package:shared/src/widgets/app_text.dart';
import 'package:shared/src/widgets/app_text_button.dart';

Future<bool?> showInfoBottomSheet({
  required BuildContext context,
  required String title,
  required String description,
  required String optionLabel,
  required VoidCallback optionCallback,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    builder: (_) => _InfoBottomSheet(
      title: title,
      description: description,
      optionLabel: optionLabel,
      optionCallback: optionCallback,
    ),
  );
}

class _InfoBottomSheet extends StatelessWidget {
  const _InfoBottomSheet({
    required this.title,
    required this.description,
    required this.optionLabel,
    required this.optionCallback,
  });

  final String title;
  final String description;
  final String optionLabel;
  final VoidCallback optionCallback;

  @override
  Widget build(BuildContext context) {
    return MbsBase(
      expandContent: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: AppText(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.headingSmall.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: AppText(
              description,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 24),
          AppTextButton.large(
            text: optionLabel,
            onTap: () {
              optionCallback();
              context.ext.pop();
            },
          ),
        ],
      ),
    );
  }
}
