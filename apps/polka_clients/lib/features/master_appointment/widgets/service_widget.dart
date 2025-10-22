import 'package:flutter/material.dart';
import 'package:polka_clients/features/booking/controller/bookings_cubit.dart';
import 'package:shared/shared.dart';

class ServicesGridView extends StatelessWidget {
  const ServicesGridView({super.key, required this.services, required this.master, this.embedded = false});

  final Master master;
  final List<Service> services;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final cellWidth = (MediaQuery.of(context).size.width - 8) / 2;
    return GridView.builder(
      primary: !embedded,
      shrinkWrap: embedded,
      padding: EdgeInsets.fromLTRB(24, 0, 24, 24),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 24,
        crossAxisSpacing: 8,
        childAspectRatio: cellWidth / (cellWidth + 128),
      ),
      itemCount: services.length,
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
    return DebugWidget(
      model: service,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(aspectRatio: 1, child: ImageClipped(imageUrl: service.resultPhotos.firstOrNull)),
          AppText(
            service.title,
            style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis),
          ),
          Row(
            children: [
              AppEmojis.fromMasterService(service.category).icon(size: Size(14, 14)),
              SizedBox(width: 4),
              Expanded(
                child: AppText(
                  service.category.label,
                  style: AppTextStyles.bodyMedium.copyWith(overflow: TextOverflow.ellipsis),
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Row(
            children: [
              AppIcons.clock.icon(size: 14),
              SizedBox(width: 2),
              Expanded(
                child: AppText(
                  service.duration.toDurationString(),
                  style: AppTextStyles.bodyMedium.copyWith(overflow: TextOverflow.ellipsis),
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          AppTextButton.small(
            text: '₽${service.price} Записаться',
            onTap: () => blocs.get<BookingsCubit>(context).startAppointmentFlow(context, master, service),
            shrinkWrap: false,
          ),
        ],
      ),
    );
  }
}
