import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polka_clients/features/booking/controller/old_bookings_cubit.dart';
import 'package:polka_clients/features/master_appointment/widgets/service_screen.dart';
import 'package:shared/shared.dart';

class ServicesGridView extends StatelessWidget {
  const ServicesGridView({super.key, required this.services, required this.master, this.embedded = false});

  final Master master;
  final List<Service> services;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      primary: !embedded,
      shrinkWrap: embedded,
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      itemCount: services.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) => ServiceWidget(service: services[index], master: master),
    );
  }
}

class ServiceWidget extends StatelessWidget {
  const ServiceWidget({super.key, required this.service, required this.master});

  final Master master;
  final Service service;

  @override
  Widget build(BuildContext context) {
    final colors = context.ext.colors;
    final textTheme = context.ext.textTheme;

    return GestureDetector(
      onTap: () => context.ext.push(ServiceScreen(service: service, master: master)),
      child: Material(
        color: Colors.transparent,
        child: Row(
          spacing: 40,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    service.title,
                    style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, height: 1.2),
                  ),
                  const SizedBox(height: 8),
                  AppText.rich([
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: ClipRRect(
                          borderRadius: BorderRadiusGeometry.circular(16),
                          child: Image.asset(
                            service.category.imagePath,
                            width: 16,
                            height: 16,
                            fit: BoxFit.cover,
                            package: 'shared',
                          ),
                        ),
                      ),
                    ),
                    TextSpan(
                      text: service.category.label,
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.black[500],
                        fontWeight: FontWeight.w600,
                        height: 1,
                      ),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  AppText(
                    '${service.duration.toDurationString()} | ₽${service.price}',
                    style: TextStyle(color: colors.black[700], height: 1),
                  ),
                  const SizedBox(height: 12),
                  AppTextButton.small(
                    text: 'Записаться',
                    onTap: () => context.read<OldBookingsCubit>().startAppointmentFlow(context, master, service),
                    shrinkWrap: false,
                  ),
                ],
              ),
            ),
            ImageClipped(imageUrl: service.resultPhotos.firstOrNull, width: 136, height: 136, borderRadius: 14),
          ],
        ),
      ),
    );
  }
}
