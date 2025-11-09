import 'package:flutter/material.dart';
import 'package:polka_clients/dependencies.dart';
import 'package:polka_clients/widgets/masters_view.dart';
import 'package:shared/shared.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LoadDataPage(
      title: 'Избранное',
      future: Dependencies().favoritesRepo.getFavoriteMasters,
      builder: (data) => FavoritesView(masters: data),
    );
  }
}

class FavoritesView extends StatelessWidget {
  const FavoritesView({super.key, required this.masters});

  final List<Master> masters;

  @override
  Widget build(BuildContext context) {
    final content = switch (masters.length) {
      > 0 => MastersView(masters: masters),
      _ => const Padding(
        padding: EdgeInsetsGeometry.all(24),
        child: Center(child: AppText('Пока у тебя нет сохраненных мастеров')),
      ),
    };

    return AppPage(
      appBar: const CustomAppBar(title: 'Избранное'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 12, 24, 12),
            child: AppText('Твои мастера', style: AppTextStyles.headingSmall),
          ),
          Expanded(child: content),
        ],
      ),
    );
  }
}
