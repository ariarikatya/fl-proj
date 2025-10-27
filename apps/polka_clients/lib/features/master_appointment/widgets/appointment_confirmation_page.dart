import 'package:flutter/material.dart';
import 'package:polka_clients/features/master_appointment/widgets/about_info.dart';
import 'package:polka_clients/features/master_appointment/widgets/master_appointment_info.dart';
import 'package:shared/shared.dart';

class AppointmentConfirmationPage extends StatelessWidget {
  const AppointmentConfirmationPage({super.key, required this.slot, required this.master, required this.service});

  final AvailableSlot slot;
  final Master master;
  final Service service;

  void confirm(BuildContext context) => context.ext.pop(true);

  @override
  Widget build(BuildContext context) {
    return AppPage(
      appBar: CustomAppBar(title: 'Подтверждение брони'),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _Header(master: master),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        _Row(left: 'Услуга, ${service.duration.toDurationString()}', right: service.title),
                        SizedBox(height: 16),
                        _Row(left: 'Дата', right: slot.datetime.formatFull()),
                        SizedBox(height: 16),
                        _Row(left: 'Локация', right: '${master.address}, ${service.location.label.toLowerCase()}'),
                        SizedBox(height: 24),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(24, 16, 24, 16),
                    decoration: BoxDecoration(
                      border: Border.symmetric(
                        horizontal: BorderSide(color: context.ext.theme.backgroundHover, width: 1),
                      ),
                    ),
                    child: Row(
                      children: [
                        AppText('Итого'),
                        Spacer(),
                        AppText('₽${service.price}', style: AppTextStyles.headingSmall),
                      ],
                    ),
                  ),
                  MasterAppointmentInfo(master: master),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              spacing: 8,
              children: [
                AppTextButton.large(onTap: () => confirm(context), text: 'Подтвердить запись'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: AppText(
                    'Записываясь, вы подтверждаете свое согласие с обработкой персональных данных',
                    style: AppTextStyles.bodySmall.copyWith(color: context.ext.theme.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.left, required this.right});

  final String left, right;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: AppText(left)),
        SizedBox(width: 16),
        Flexible(child: AppText(right, textAlign: TextAlign.end)),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.master});

  final Master master;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.all(24),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          BlotAvatar(avatarUrl: master.avatarUrl),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  '${master.firstName} ${master.lastName}',
                  style: AppTextStyles.headingSmall.copyWith(height: 1),
                ),
                SizedBox(height: 4),
                AppText(
                  master.profession,
                  style: AppTextStyles.bodyMedium.copyWith(color: context.ext.theme.textSecondary),
                ),
                SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    AboutInfo.reviews(master: master),
                    AboutInfo.experience(master: master, short: true),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
