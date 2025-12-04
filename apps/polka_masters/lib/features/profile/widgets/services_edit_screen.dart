import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polka_masters/features/profile/controller/services_cubit.dart';
import 'package:polka_masters/features/profile/widgets/edit_service_screen.dart';
import 'package:shared/shared.dart';

class ServicesEditScreen extends StatefulWidget {
  const ServicesEditScreen({super.key});

  @override
  State<ServicesEditScreen> createState() => _ServicesEditScreenState();
}

class _ServicesEditScreenState extends State<ServicesEditScreen> {
  void _changeVisibility(int serviceId, bool visible) =>
      context.read<ServicesCubit>().toggleServiceVisibility(serviceId, visible);

  void _changeService(Service service) async {
    final $service = await context.ext.push<Service>(EditServiceScreen(service: service));
    if ($service != null && mounted) context.read<ServicesCubit>().updateService($service);
  }

  void _createService() async {
    final $service = await context.ext.push<Service>(const EditServiceScreen(service: null));
    if ($service != null && mounted) context.read<ServicesCubit>().createService($service);
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      appBar: const CustomAppBar(title: 'Услуги'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(padding: EdgeInsets.symmetric(horizontal: 24), child: AppText.headingLarge('Мои услуги')),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: AppText.secondary(
                'Здесь находятся все твои услуги, по ним клиенты могут найти тебя и записаться',
                style: AppTextStyles.bodyMedium500,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: DataBuilder<ServicesCubit, Map<Service, bool>>(
                dataBuilder: (context, data) => SingleChildScrollView(
                  child: Column(
                    children: [
                      for (final MapEntry(:key, :value) in data.entries)
                        _ServiceCard(
                          service: key,
                          enabled: value,
                          onChange: () => _changeService(key),
                          onToggle: (visible) => _changeVisibility(key.id, visible),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
              child: AppTextButton.large(text: 'Создать новую услугу', onTap: _createService),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.service, required this.enabled, required this.onChange, required this.onToggle});

  final Service service;
  final bool enabled;
  final VoidCallback onChange;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: context.ext.colors.white[300])),
      ),
      child: Row(
        spacing: 16,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: ImageClipped(width: 56, height: 56, borderRadius: 10, imageUrl: service.resultPhotos.firstOrNull),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                Expanded(
                  child: Column(
                    spacing: 8,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(service.title, overflow: TextOverflow.ellipsis, style: AppTextStyles.bodyLarge700),
                      AppText.rich([
                        WidgetSpan(child: FIcons.clock.icon(context, size: 16), alignment: PlaceholderAlignment.middle),
                        TextSpan(
                          text: ' ${service.duration.toDurationStringShort()}  |  ₽ ${service.price}',
                          style: AppTextStyles.bodyMedium500.copyWith(color: context.ext.colors.black[700], height: 1),
                        ),
                      ]),
                      AppLinkButton(text: 'Изменить', padding: EdgeInsets.zero, onTap: onChange),
                    ],
                  ),
                ),

                AppSwitch(value: enabled, onChanged: onToggle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
