import 'package:flutter/material.dart';
import 'package:polka_clients/features/map_search/controller/map_search_cubit.dart';
import 'package:polka_clients/features/map_search/widgets/master_map_card.dart';
import 'package:shared/shared.dart';

class MastersBottomSheet extends StatefulWidget {
  const MastersBottomSheet({super.key, required this.onResetFilters});

  final VoidCallback onResetFilters;

  @override
  State<MastersBottomSheet> createState() => _MastersBottomSheetState();
}

class _MastersBottomSheetState extends State<MastersBottomSheet> {
  final _controller = DraggableScrollableController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.2,
      maxChildSize: 0.8,
      controller: _controller,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: context.ext.theme.backgroundDefault,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              Grabber(
                controller: _controller,
                builder: (context, grabber) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    grabber,
                    const Padding(
                      padding: EdgeInsets.only(top: 8, bottom: 10, left: 24, right: 24),
                      child: AppText('Мастера рядом с тобой', style: AppTextStyles.headingSmall),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PaginationBuilder<MapFeedCubit, MasterMapInfo>(
                  cubit: blocs.get<MapFeedCubit>(context),
                  scrollController: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemBuilder: (context, index, item) => MasterMapCard(info: item),
                  emptyBuilder: (_) => EmptySearchView(onResetFilters: widget.onResetFilters),
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
