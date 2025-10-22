import 'package:flutter/material.dart';
import 'package:shared/src/app_colors.dart';
import 'package:shared/src/app_text_styles.dart';
import 'package:shared/src/extensions/context.dart';
import 'package:shared/src/mbs/mbs_base.dart';
import 'package:shared/src/widgets/app_text.dart';

Future<T?> showListItemPickerBottomSheet<T extends Object?>({
  required BuildContext context,
  required String title,
  required List<T> items,
  required Widget Function(T item) builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    builder: (_) => _ListSheet(title: title, items: items, builder: builder),
  );
}

class _ListSheet<T extends Object?> extends StatelessWidget {
  const _ListSheet({required this.title, required this.items, required this.builder});

  final String title;
  final List<T> items;
  final Widget Function(T item) builder;

  @override
  Widget build(BuildContext context) {
    return MbsBase(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 5,
              decoration: BoxDecoration(color: AppColors.iconsDefault, borderRadius: BorderRadius.circular(4)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: AppText(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.headingSmall.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 24),
          for (var item in items) GestureDetector(onTap: () => context.ext.pop(item), child: builder(item)),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
