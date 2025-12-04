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
        border: Border(bottom: BorderSide(color: context.ext.colors.white[300], width: 1)),
      ),
      child: Column(
        spacing: 4,
        children: [
          Row(
            spacing: 4,
            children: [
              FIcons.clock.icon(context),
              AppText(
                'Политика отмены: -',
                style: AppTextStyles.bodyMedium.copyWith(color: context.ext.colors.black[700]),
              ),
            ],
          ),
          Row(
            spacing: 4,
            children: [
              FIcons.lock.icon(context),
              AppText(
                'Требует подтверждения мастера ',
                style: AppTextStyles.bodyMedium.copyWith(color: context.ext.colors.black[700]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
