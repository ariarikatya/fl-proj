import 'package:flutter/material.dart';
import 'package:shared/src/extensions/context.dart';
import 'package:shared/src/app_text_styles.dart';
import 'package:shared/src/mbs/mbs_base.dart';
import 'package:shared/src/widgets/app_link_button.dart';
import 'package:shared/src/widgets/app_text.dart';
import 'package:shared/src/widgets/app_text_button.dart';

Future<bool?> showConfirmBottomSheet({
  required BuildContext context,
  required String title,
  required String acceptText,
  required String declineText,
  String? description,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    backgroundColor: context.ext.theme.backgroundDefault,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    builder: (_) =>
        _ConfirmSheet(title: title, acceptText: acceptText, declineText: declineText, description: description),
  );
}

class _ConfirmSheet extends StatelessWidget {
  const _ConfirmSheet({required this.title, required this.acceptText, required this.declineText, this.description});

  final String title;
  final String acceptText;
  final String declineText;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return MbsBase(
      expandContent: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (description == null)
            Padding(
              padding: const EdgeInsets.all(10),
              child: AppText(
                title,
                textAlign: TextAlign.center,
                style: AppTextStyles.headingSmall.copyWith(fontWeight: FontWeight.w600),
              ),
            )
          else ...[
            AppText(title, style: AppTextStyles.headingLarge),
            SizedBox(height: 16),
            AppText.secondary(description!, style: AppTextStyles.bodyLarge),
          ],
          const SizedBox(height: 24),
          AppTextButton.large(text: acceptText, onTap: () => context.ext.pop(true)),
          const SizedBox(height: 10),
          AppLinkButton(text: declineText, onTap: () => context.ext.pop(false)),
        ],
      ),
    );
  }
}
