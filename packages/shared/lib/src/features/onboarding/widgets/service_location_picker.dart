import 'package:flutter/material.dart';
import 'package:shared/src/app_text_styles.dart';
import 'package:shared/src/models/service/service_location.dart';
import 'package:shared/src/widgets/app_chip.dart';
import 'package:shared/src/widgets/app_text.dart';

class ServiceLocationPicker extends StatelessWidget {
  const ServiceLocationPicker({required this.notifier});

  final ValueNotifier<ServiceLocation?> notifier;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: notifier,
      builder: (context, value, child) {
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ServiceLocation.values
              .map(
                (e) => AppChip(
                  onTap: () => notifier.value = e,
                  onClose: () => notifier.value = null,
                  enabled: value == e,
                  child: AppText(e.label, style: AppTextStyles.bodyLarge),
                ),
              )
              .toList(),
        );
      },
    );
  }
}
