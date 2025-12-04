import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polka_clients/client_scope.dart';
import 'package:polka_clients/dependencies.dart';
import 'package:polka_clients/features/map_search/controller/map_markers_paginator.dart';
import 'package:polka_clients/features/map_search/controller/map_search_cubit.dart';
import 'package:polka_clients/features/map_search/widgets/masters_bottom_sheet.dart';
import 'package:polka_clients/features/map_search/widgets/map_view.dart';
import 'package:polka_clients/features/map_search/widgets/mock_map_view.dart';
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
      return const _MapSearchPage();
    } else {
      return const AppPage(child: Center(child: LoadingIndicator()));
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
      backgroundColor: context.ext.colors.white[300],
      safeAreaBuilder: (child) => SafeArea(bottom: false, child: child),
      child: Stack(
        children: [
          if (Platform.isAndroid || Platform.isIOS) const MapView() else const MockMapView(),

          Container(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
            color: context.ext.colors.white[300],
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                AppText(
                  'г. ${context.watch<ClientViewModel>().client.city}',
                  style: AppTextStyles.bodyLarge.copyWith(color: context.ext.colors.black[700]),
                ),
                MastersSearchBar(controller: _controller),
              ],
            ),
          ),

          Positioned.fill(
            child: MastersBottomSheet(
              onResetFilters: () {
                _controller.clear();
                context.read<MapFeedCubit>()
                  ..setQuery(null)
                  ..setFilter(const SearchFilter());
                context.read<MapMarkersPaginator>()
                  ..setQuery(null)
                  ..setFilter(const SearchFilter());
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
  late final _filter = context.read<MapFeedCubit>().filter;

  void _updateQuery() {
    final query = widget.controller.text.trim().isEmpty ? null : widget.controller.text.trim();
    context.read<MapFeedCubit>().setQuery(query);
    context.read<MapMarkersPaginator>().setQuery(query);
  }

  @override
  void initState() {
    widget.controller.addListener(_updateQuery);
    super.initState();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateQuery);
    super.dispose();
  }

  void _openFilters() async {
    final filter = await context.ext.push<SearchFilter>(FiltersPage(initFilter: _filter.value, showSorting: false));
    if (filter != null && mounted) {
      context.read<MapFeedCubit>().setFilter(filter);
      context.read<MapMarkersPaginator>().setFilter(filter);
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
              boxShadow: [
                BoxShadow(blurRadius: 4, offset: const Offset(0, 1), color: Colors.black.withValues(alpha: 0.1)),
              ],
              borderRadius: BorderRadius.circular(14),
            ),
            child: AppTextFormField(
              controller: widget.controller,
              compact: true,
              hintText: 'Например, Airtouch',
              prefixIcon: FIcons.search.icon(context, color: context.ext.colors.black[500]),
              fillColor: context.ext.colors.white[100],
              onFieldSubmitted: (value) {
                context.read<MapFeedCubit>().reset();
                context.read<MapMarkersPaginator>().reset();
              },
              onClear: () {
                context.read<MapFeedCubit>().reset();
                context.read<MapMarkersPaginator>().reset();
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
