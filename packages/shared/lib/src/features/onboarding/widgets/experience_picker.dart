import 'package:flutter/material.dart';
import 'package:shared/src/widgets/app_chip.dart';
import 'package:shared/src/widgets/app_text.dart';

class ExperiencePicker extends StatelessWidget {
  const ExperiencePicker({required this.experience});

  final ValueNotifier<String?> experience;

  static const _values = ['до 1 года', '1-3 года', '3-5 лет', 'от 5 лет'];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: experience,
      builder: (context, value, child) {
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _values
              .map(
                (e) => AppChip(
                  enabled: value == e,
                  onTap: () => experience.value = e,
                  onClose: () => experience.value = null,
                  child: AppText(e),
                ),
              )
              .toList(),
        );
      },
    );
  }
}
