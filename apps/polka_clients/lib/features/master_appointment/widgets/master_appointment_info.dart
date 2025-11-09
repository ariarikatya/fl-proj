import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class MasterAppointmentInfo extends StatelessWidget {
  const MasterAppointmentInfo({super.key, required this.master});

  final Master master;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: context.ext.theme.backgroundHover, width: 1)),
      ),
      child: Column(
        spacing: 4,
        children: [
          Row(
            spacing: 4,
            children: [
              AppIcons.clock.icon(context),
              AppText(
                'Политика отмены: -',
                style: AppTextStyles.bodyMedium.copyWith(color: context.ext.theme.textSecondary),
              ),
            ],
          ),
          Row(
            spacing: 4,
            children: [
              AppIcons.lock.icon(context),
              AppText(
                'Требует подтверждения мастера ',
                style: AppTextStyles.bodyMedium.copyWith(color: context.ext.theme.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
