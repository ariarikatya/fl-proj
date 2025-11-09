import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polka_masters/dependencies.dart';
import 'package:polka_masters/features/profile/widgets/edit_service_screen.dart';
import 'package:polka_masters/scopes/master_scope.dart';
import 'package:shared/shared.dart';

const _title = 'Услуги';

class ServicesEditScreen extends StatelessWidget {
  const ServicesEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LoadDataPage(
      title: _title,
      future: () => Dependencies().masterRepository.getMasterInfo(context.read<MasterScope>().master.id),
      builder: (data) => _View(data.services),
    );
  }
}

class _View extends StatefulWidget {
  const _View(this.services);

  final List<Service> services;

  @override
  State<_View> createState() => _ViewState();
}

class _ViewState extends State<_View> {
  late final _services = List<Service>.from(widget.services);

  void _changeService(Service service) async {
    final index = _services.indexOf(service);
    if (index == -1) return;

    final $service = await context.ext.push<Service>(EditServiceScreen(service: service));
    if ($service != null) {
      setState(() {
        _services[index] = $service;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      appBar: const CustomAppBar(title: _title),
      child: SingleChildScrollView(
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
            for (var service in widget.services)
              _ServiceCard(
                service: service,
                enabled: true,
                onChange: () => _changeService(service),
                onToggle: (value) {},
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
        border: Border(bottom: BorderSide(color: context.ext.theme.backgroundHover)),
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
                        WidgetSpan(
                          child: AppIcons.clock.icon(context, size: 16),
                          alignment: PlaceholderAlignment.middle,
                        ),
                        TextSpan(
                          text: ' ${service.duration.toDurationStringShort()}  |  ₽ ${service.price}',
                          style: AppTextStyles.bodyMedium500.copyWith(
                            color: context.ext.theme.textSecondary,
                            height: 1,
                          ),
                        ),
                      ]),
                      AppLinkButton(text: 'Изменить', padding: EdgeInsets.zero, onTap: onChange),
                    ],
                  ),
                ),

                AppSwitch(value: true, onChanged: onToggle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
