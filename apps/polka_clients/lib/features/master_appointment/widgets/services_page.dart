import 'package:flutter/material.dart';
import 'package:polka_clients/dependencies.dart';
import 'package:polka_clients/features/master_appointment/widgets/master_header.dart';
import 'package:polka_clients/features/master_appointment/widgets/service_widget.dart';
import 'package:shared/shared.dart';

class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key, required this.masterId});

  final int masterId;

  @override
  Widget build(BuildContext context) {
    return LoadDataPage(
      future: () => Dependencies().clientRepository.getMasterInfo(masterId),
      builder: (data) => AppPage(
        appBar: const CustomAppBar(title: 'Услуги мастера'),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: MasterHeader(master: data.master),
            ),
            Expanded(
              child: ServicesGridView(services: data.services, master: data.master),
            ),
          ],
        ),
      ),
    );
  }
}
