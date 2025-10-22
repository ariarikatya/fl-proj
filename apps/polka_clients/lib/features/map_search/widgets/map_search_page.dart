import 'package:polka_clients/client_scope.dart';
import 'package:polka_clients/dependencies.dart';
import 'package:polka_clients/features/map_search/controller/map_markers_paginator.dart';
import 'package:polka_clients/features/map_search/controller/map_search_cubit.dart';
import 'package:polka_clients/features/map_search/widgets/masters_bottom_sheet.dart';
import 'package:polka_clients/features/map_search/widgets/map_view.dart';
import 'package:polka_clients/features/search/filters/filters_page.dart';
import 'package:polka_clients/features/search/filters/search_filter.dart';
import 'package:polka_clients/features/search/search_page.dart';
import 'package:shared/shared.dart';
import 'package:flutter/material.dart';

class MapSearchPage extends StatefulWidget {
  const MapSearchPage({super.key});

  @override
  State<MapSearchPage> createState() => _MapSearchPageState();
}

class _MapSearchPageState extends State<MapSearchPage> {
  final mapInit = Dependencies().mapkitInit;

  @override
  void initState() {
    super.initState();

    if (!mapInit.isCompleted) {
      mapInit.future.whenComplete(() {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (mapInit.isCompleted) {
      return _MapSearchPage();
    } else {
      return AppPage(child: Center(child: LoadingIndicator()));
    }
  }
}

class _MapSearchPage extends StatefulWidget {
  const _MapSearchPage();

  @override
  State<_MapSearchPage> createState() => __MapSearchPageState();
}

class __MapSearchPageState extends State<_MapSearchPage> {
  late final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      backgroundColor: AppColors.backgroundHover,
      safeAreaBuilder: (child) => SafeArea(bottom: false, child: child),
      child: Stack(
        children: [
          MapView(),

          Container(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
            color: AppColors.backgroundHover,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                AppText(
                  'г. ${ClientScope.of(context).client.city}',
                  style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
                ),
                MastersSearchBar(controller: _controller),
              ],
            ),
          ),

          Positioned.fill(
            child: MastersBottomSheet(
              onResetFilters: () {
                _controller.clear();
                blocs.get<MapFeedCubit>(context)
                  ..setQuery(null)
                  ..setFilter(SearchFilter());
                blocs.get<MapMarkersPaginator>(context)
                  ..setQuery(null)
                  ..setFilter(SearchFilter());
              },
            ),
          ),
        ],
      ),
    );
  }
}

class MastersSearchBar extends StatefulWidget {
  const MastersSearchBar({super.key, required this.controller});

  final TextEditingController controller;

  @override
  State<MastersSearchBar> createState() => _MastersSearchBarState();
}

class _MastersSearchBarState extends State<MastersSearchBar> {
  late final _filter = blocs.get<MapFeedCubit>(context).filter;

  void _updateQuery() {
    final query = widget.controller.text.trim().isEmpty ? null : widget.controller.text.trim();
    blocs.get<MapFeedCubit>(context).setQuery(query);
    blocs.get<MapMarkersPaginator>(context).setQuery(query);
  }

  @override
  void initState() {
    widget.controller.addListener(_updateQuery);
    super.initState();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateQuery);
    blocs.destroy<MapFeedCubit>();
    blocs.destroy<MapMarkersPaginator>();
    super.dispose();
  }

  void _openFilters() async {
    final filter = await context.ext.push<SearchFilter>(FiltersPage(initFilter: _filter.value, showSorting: false));
    if (filter != null) {
      blocs.get<MapFeedCubit>(context).setFilter(filter);
      blocs.get<MapMarkersPaginator>(context).setFilter(filter);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 8,
      children: [
        Expanded(
          child: DecoratedBox(
            decoration: BoxDecoration(
              boxShadow: [BoxShadow(blurRadius: 4, offset: Offset(0, 1), color: Colors.black.withValues(alpha: 0.1))],
              borderRadius: BorderRadius.circular(14),
            ),
            child: AppTextFormField(
              controller: widget.controller,
              compact: true,
              hintText: 'Например, Airtouch',
              prefixIcon: AppIcons.search.icon(color: AppColors.textPlaceholder),
              fillColor: AppColors.backgroundDefault,
              onFieldSubmitted: (value) {
                blocs.get<MapFeedCubit>(context).reset();
                blocs.get<MapMarkersPaginator>(context).reset();
              },
              onClear: () {
                blocs.get<MapFeedCubit>(context).reset();
                blocs.get<MapMarkersPaginator>(context).reset();
              },
            ),
          ),
        ),
        ValueListenableBuilder(
          valueListenable: _filter,
          builder: (context, filter, child) {
            return FilterButton(onTap: _openFilters, enabled: filter.hasActiveFilters);
          },
        ),
      ],
    );
  }
}
