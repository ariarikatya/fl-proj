import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polka_clients/features/booking/booking_utils.dart';
import 'package:polka_clients/features/booking/controller/old_bookings_cubit.dart';
import 'package:shared/shared.dart';

class ServiceScreen extends StatelessWidget {
  const ServiceScreen({super.key, required this.service, required this.master});

  final Master master;
  final Service service;

  @override
  Widget build(BuildContext context) {
    final colors = context.ext.colors;
    final styles = context.ext.textTheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: context.ext.colors.white[100],
      appBar: CustomAppBar(title: '', simplified: true, backButtonColor: colors.white[100]),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadiusGeometry.vertical(bottom: Radius.circular(24)),
                    child: AspectRatio(
                      aspectRatio: 0.9,
                      child: ImageClipped(imageUrl: service.resultPhotos.firstOrNull, borderRadius: 0),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                    child: SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(service.title, style: styles.headlineMedium),
                          const SizedBox(height: 16),
                          AppText.rich([
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: ClipRRect(
                                  borderRadius: BorderRadiusGeometry.circular(16),
                                  child: Image.asset(
                                    service.category.imagePath,
                                    width: 24,
                                    height: 24,
                                    fit: BoxFit.cover,
                                    package: 'shared',
                                  ),
                                ),
                              ),
                            ),
                            TextSpan(
                              text: service.category.label,
                              style: styles.bodyMedium?.copyWith(
                                color: colors.black[500],
                                fontWeight: FontWeight.w600,
                                height: 1,
                              ),
                            ),
                          ]),
                          const SizedBox(height: 32),
                          AppText('Твой мастер', style: styles.headlineSmall),
                          const SizedBox(height: 16),
                          _MasterHeader(master),
                          const SizedBox(height: 16),
                          Divider(color: colors.white[200]),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              AppText('Где?', style: styles.headlineSmall),
                              AppLinkButton(
                                text: 'Показать на карте',
                                onTap: () =>
                                    showOnExternalMap(context, master.latitude, master.longitude, service.title),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          AppText(master.location.label, style: styles.bodyLarge, textAlign: TextAlign.center),
                          AppText(master.address, style: styles.bodyLarge, textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: colors.white[200])),
            ),
            child: SafeArea(
              top: false,
              right: false,
              left: false,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          '₽${service.price}',
                          style: styles.bodyLarge?.copyWith(height: 1.1, fontWeight: FontWeight.bold),
                        ),
                        AppText(
                          service.duration.toDurationString(),
                          style: styles.bodyMedium?.copyWith(color: colors.black[500], height: 1.1),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: AppTextButton.medium(
                      text: 'Записаться',
                      onTap: () => context.read<OldBookingsCubit>().startAppointmentFlow(context, master, service),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MasterHeader extends StatelessWidget {
  const _MasterHeader(this.master);

  final Master master;

  @override
  Widget build(BuildContext context) {
    final colors = context.ext.colors;
    final styles = context.ext.textTheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        BlotAvatar(avatarUrl: master.avatarUrl, size: 64),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText('${master.firstName} ${master.lastName}', style: styles.headlineSmall?.copyWith(fontSize: 16)),
              AppText(master.profession, style: styles.bodyMedium?.copyWith(color: context.ext.colors.black[700])),
              const SizedBox(height: 8),
              AppText.rich(style: styles.bodySmall?.copyWith(color: colors.black[500]), [
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: FIcons.star_filled.icon(context, size: 16),
                  ),
                ),
                TextSpan(text: '${master.ratingFixed} (${master.reviewsCount.pluralMasculine('отзыв')})  '),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: FIcons.scissors.icon(context, size: 16),
                  ),
                ),
                TextSpan(text: 'опыт: ${master.experience}'),
              ]),
            ],
          ),
        ),
      ],
    );
  }
}
