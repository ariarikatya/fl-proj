import 'package:flutter/material.dart';
import 'package:polka_clients/widgets/master_card.dart';
import 'package:shared/shared.dart';

class MastersView extends StatelessWidget {
  const MastersView({super.key, required this.masters, this.embedded = false});

  final List<Master> masters;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      primary: !embedded,
      shrinkWrap: embedded,
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 4,
        mainAxisExtent: 394,
      ),
      itemCount: masters.length,
      itemBuilder: (context, index) => MasterCard(master: masters[index]),
    );
  }
}
