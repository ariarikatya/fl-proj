import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class ServiceCategoryPickerV2 extends StatelessWidget {
  const ServiceCategoryPickerV2({required this.category});

  final ValueNotifier<ServiceCategories?> category;

  static const _values = ServiceCategories.values;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: category,
      builder: (context, value, child) {
        return Column(
          children: [
            for (final e in _values)
              GestureDetector(
                onTap: () => category.value = e,
                child: Container(
                  padding: EdgeInsets.all(8),
                  margin: EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: value == e ? context.ext.colors.pink[100] : context.ext.colors.white[100],
                    border: Border.all(
                      color: value == e ? context.ext.colors.pink[300] : context.ext.colors.white[300],
                    ),
                  ),
                  child: Row(
                    children: [
                      Image.asset(e.imagePath, package: 'shared', width: 56, height: 56),
                      const SizedBox(width: 4),
                      AppText(e.label, style: AppTextStyles.bodyMedium),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
