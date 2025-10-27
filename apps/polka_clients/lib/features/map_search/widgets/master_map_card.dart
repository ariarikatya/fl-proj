import 'package:flutter/material.dart';
import 'package:polka_clients/features/booking/controller/bookings_cubit.dart';
import 'package:polka_clients/features/master_appointment/widgets/master_page.dart';
import 'package:polka_clients/features/master_appointment/widgets/services_page.dart';
import 'package:shared/shared.dart';

class MasterMapCard extends StatelessWidget {
  const MasterMapCard({super.key, required this.info});

  final MasterMapInfo info;

  @override
  Widget build(BuildContext context) {
    return DebugWidget(
      model: info,
      child: GestureDetector(
        onTap: () => context.ext.push(MasterPage(masterId: info.master.id)),
        child: Container(
          decoration: BoxDecoration(color: context.ext.theme.backgroundHover, borderRadius: BorderRadius.circular(24)),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              _MasterHeader(master: info.master, distanceMeters: info.distanceMeters),
              Divider(height: 1, thickness: 1, color: context.ext.theme.borderSubtle),
              AppText('Услуги', style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
              for (var service in info.services.take(3))
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _ServiceRow(master: info.master, service: service),
                ),
              AppTextButton.medium(
                text: 'Записаться',
                onTap: () => context.ext.push(ServicesPage(masterId: info.master.id)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MasterHeader extends StatelessWidget {
  const _MasterHeader({required this.master, required this.distanceMeters});

  final Master master;
  final int distanceMeters;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 24,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 4),
          child: BlotAvatar(avatarUrl: master.avatarUrl),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              AppText(
                master.fullName,
                style: AppTextStyles.bodyLarge.copyWith(height: 1.25),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Row(
                spacing: 6,
                children: [
                  AppEmojis.fromMasterService(
                    master.categories.firstOrNull ?? ServiceCategories.nailService,
                  ).icon(size: const Size(16, 16)),
                  Flexible(
                    child: AppText(
                      master.profession,
                      style: AppTextStyles.bodyMedium.copyWith(color: context.ext.theme.textSecondary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              AppText(
                '⭐ ${master.ratingFixed}',
                style: AppTextStyles.bodyMedium.copyWith(color: context.ext.theme.textSecondary),
                overflow: TextOverflow.ellipsis,
              ),
              AppText(
                _distanceText(distanceMeters),
                style: AppTextStyles.bodySmall.copyWith(color: context.ext.theme.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _distanceText(int distanceMeters) {
    if (distanceMeters < 1000) {
      return 'В $distanceMeters м от тебя';
    }
    return 'В ${(distanceMeters / 1000).toStringAsFixed(1)} км от тебя';
  }
}

class _ServiceRow extends StatelessWidget {
  const _ServiceRow({required this.master, required this.service});

  final Master master;
  final Service service;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => blocs.get<BookingsCubit>(context).startAppointmentFlow(context, master, service),
      child: Material(
        color: Colors.transparent,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ImageClipped(imageUrl: service.resultPhotos.firstOrNull, width: 64, height: 64, borderRadius: 12),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    service.title,
                    style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700),
                    maxLines: 1,
                  ),
                  AppText(
                    '₽${service.price}',
                    style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500),
                    maxLines: 1,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      AppIcons.clock.icon(context, size: 16),
                      const SizedBox(width: 2),
                      Flexible(
                        child: AppText(
                          '${service.duration.inMinutes} min',
                          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500),
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
