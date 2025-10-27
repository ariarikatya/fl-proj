import 'package:polka_clients/features/home/controller/home_navigation_cubit.dart';
import 'package:polka_clients/features/map_search/controller/map_markers_paginator.dart';
import 'package:polka_clients/features/map_search/controller/map_search_cubit.dart';
import 'package:polka_clients/features/search/filters/search_filter.dart';
import 'package:polka_clients/client_scope.dart';
import 'package:polka_clients/widgets/masters_view.dart';
import 'package:shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polka_clients/features/feed/controller/feed_cubit.dart';
import 'package:polka_clients/features/search/search_page.dart';

class HomeFeedPage extends StatelessWidget {
  const HomeFeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final client = ClientScope.of(context).client;

    return AppPage(
      safeAreaBuilder: (child) => SafeArea(bottom: false, child: child),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                AppText(
                  'г. ${client.city}',
                  style: AppTextStyles.bodyLarge.copyWith(color: context.ext.theme.textSecondary),
                ),
                AppSearchBar(),
              ],
            ),
          ),
          Expanded(
            child: SizedBox(
              width: double.infinity,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: AppText('🌿 Привет, ${client.firstName}', style: AppTextStyles.headingLarge),
                    ),
                    SizedBox(height: 16),
                    _Filters(),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: AppText(
                        'Мастера рядом с тобой',
                        style: AppTextStyles.headingSmall.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    _MastersFeed(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MastersFeed extends StatelessWidget {
  const _MastersFeed();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeedCubit, FeedState>(
      bloc: blocs.get<FeedCubit>(context),
      builder: (context, state) => switch (state) {
        FeedInitial() => const SizedBox.shrink(),
        FeedLoading() => SizedBox(height: 200, child: Center(child: LoadingIndicator())),
        FeedLoaded() => Padding(
          padding: const EdgeInsets.only(top: 12),
          child: MastersView(masters: state.data, embedded: true),
        ),
        FeedError() => SizedBox(height: 200, child: Center(child: AppText(state.error))),
      },
    );
  }
}

class _Filters extends StatelessWidget {
  const _Filters();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      scrollDirection: Axis.horizontal,

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          for (var service in ServiceCategories.categories)
            CategoryFilterButton(icon: AppEmojis.fromMasterService(service).icon(), service: service),
        ],
      ),
    );
  }
}

class AppSearchBar extends StatelessWidget {
  const AppSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureOverrideWidget(
      onTap: () => context.ext.push(SearchPage()),
      child: DecoratedBox(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(blurRadius: 4, offset: Offset(0, 1), color: Colors.black.withValues(alpha: 0.1))],
          borderRadius: BorderRadius.circular(14),
        ),
        child: AppTextFormField(
          compact: true,
          hintText: 'Например, Airtouch',
          prefixIcon: AppIcons.search.icon(context, color: context.ext.theme.textPlaceholder),
          fillColor: context.ext.theme.backgroundDefault,
        ),
      ),
    );
  }
}

class CategoryFilterButton extends StatelessWidget {
  const CategoryFilterButton({super.key, required this.icon, required this.service});

  final Widget icon;
  final ServiceCategories service;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        blocs.get<MapFeedCubit>(context).setFilter(SearchFilter(categories: {service}));
        blocs.get<MapMarkersPaginator>(context).setFilter(SearchFilter(categories: {service}));
        blocs.get<HomeNavigationCubit>(context).openMapSearch();
      },
      child: SizedBox(
        width: 60,
        child: Column(
          children: [
            Container(
              width: 60,
              height: 56,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.ext.theme.backgroundHover,
                borderRadius: BorderRadius.circular(14),
              ),
              child: icon,
            ),
            SizedBox(height: 2),
            AppText(service.label, style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
