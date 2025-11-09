import 'package:flutter/material.dart';
import 'package:shared/src/app_text_styles.dart';
import 'package:shared/src/emojis.dart';
import 'package:shared/src/models/service/service_categories.dart';
import 'package:shared/src/widgets/app_chip.dart';
import 'package:shared/src/widgets/app_text.dart';

class ServiceCategoryPicker extends StatelessWidget {
  const ServiceCategoryPicker({required this.category});

  final ValueNotifier<ServiceCategories?> category;

  static const _values = ServiceCategories.categories;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: category,
      builder: (context, value, child) {
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _values
              .map(
                (e) => AppChip(
                  enabled: value == e,
                  onTap: () => category.value = e,
                  onClose: () => category.value = null,
                  child: Row(
                    children: [
                      AppEmojis.fromMasterService(e).icon(size: const Size(14, 14)),
                      const SizedBox(width: 4),
                      AppText(e.label, style: AppTextStyles.bodyMedium),
                    ],
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}
