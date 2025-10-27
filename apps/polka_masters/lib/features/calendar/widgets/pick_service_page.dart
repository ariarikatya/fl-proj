import 'package:flutter/material.dart';
import 'package:polka_masters/dependencies.dart';
import 'package:polka_masters/features/calendar/widgets/service_card.dart';
import 'package:polka_masters/scopes/master_scope.dart';
import 'package:shared/shared.dart';

class PickServicePage extends StatelessWidget {
  const PickServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return LoadDataPage(
      title: 'Твои услуги',
      future: () => Dependencies().masterRepository.getMasterInfo(MasterScope.of(context).master.id),
      builder: (info) => _View(info.services),
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
  Service? _pickedService;

  @override
  Widget build(BuildContext context) {
    return AppPage(
      appBar: CustomAppBar(title: 'Твои услуги'),
      child: Padding(
        padding: EdgeInsetsGeometry.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText('Выбери услугу', style: AppTextStyles.headingLarge),
            SizedBox(height: 8),
            AppText.secondary('Здесь показываются все созданные тобой услуги', style: AppTextStyles.bodyMedium),
            SizedBox(height: 30),
            Expanded(
              child: ListView.builder(
                itemCount: widget.services.length,
                itemBuilder: (context, index) {
                  final $service = widget.services[index];
                  return GestureDetector(
                    onTap: () => setState(() => _pickedService = $service),
                    child: ServiceCard($service, enabled: _pickedService == $service),
                  );
                },
              ),
            ),
            AppTextButton.large(
              enabled: _pickedService != null,
              text: 'Добавить услугу',
              onTap: () => context.ext.pop(_pickedService),
            ),
          ],
        ),
      ),
    );
  }
}
