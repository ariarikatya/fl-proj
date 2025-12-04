import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:polka_clients/features/home/controller/home_navigation_cubit.dart';
import 'package:polka_clients/features/map_search/controller/map_markers_paginator.dart';
import 'package:polka_clients/features/map_search/controller/map_search_cubit.dart';
import 'package:polka_clients/features/profile/widgets/categories_page.dart';
import 'package:polka_clients/features/search/filters/search_filter.dart';
import 'package:polka_clients/client_scope.dart';
import 'package:polka_clients/widgets/master_card.dart';
import 'package:shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polka_clients/features/feed/controller/feed_cubit.dart';
import 'package:polka_clients/features/search/search_page.dart';

class HomeFeedPage extends StatelessWidget {
  const HomeFeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final client = context.watch<ClientViewModel>().client;

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
                  style: AppTextStyles.bodyLarge.copyWith(color: context.ext.colors.black[700]),
                ),
                const AppSearchBar(),
              ],
            ),
          ),
          Expanded(
            child: SizedBox(
              width: double.infinity,
              child: RefreshWidget(
                refresh: context.read<FeedCubit>().reset,
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: AppText('🌿 Привет, ${client.firstName}', style: AppTextStyles.headingLarge),
                          ),
                          const SizedBox(height: 16),
                          const _Filters(),
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: AppText(
                              'Мастера рядом с тобой',
                              style: AppTextStyles.headingSmall.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),

                    const SliverPadding(padding: EdgeInsets.fromLTRB(24, 0, 24, 24), sliver: _MastersFeed()),
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
    return BlocBuilder<FeedCubit, PagingState<int, Master>>(
      builder: (context, state) {
        final feed = context.read<FeedCubit>();
        return PagedSliverGrid<int, Master>(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 4,
            mainAxisExtent: 394,
          ),
          state: state,
          fetchNextPage: feed.load,
          builderDelegate: PagedChildBuilderDelegate(
            animateTransitions: true,
            noItemsFoundIndicatorBuilder: (ctx) => _buildNoItemsFound(ctx),
            itemBuilder: (context, item, index) => MasterCard(master: item),
            firstPageProgressIndicatorBuilder: (_) => _buildLoading(),
            newPageProgressIndicatorBuilder: (_) => _buildLoading(),
            firstPageErrorIndicatorBuilder: (_) => _buildError(reload: feed.reset),
            newPageErrorIndicatorBuilder: (_) => _buildError(reload: feed.reset),
          ),
        );
      },
    );
  }

  Widget _buildNoItemsFound(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          const AppText.headingSmall('Ничего нет'),
          const AppText(
            'Мы не нашли подходящих тебе мастеров\nПопробуй изменить категории в профиле',
            textAlign: TextAlign.center,
          ),
          AppTextButton.small(text: 'Изменить', onTap: () => context.ext.push(const CategoriesPage())),
        ],
      ),
    ),
  );

  Widget _buildLoading() => const Center(
    child: Padding(padding: EdgeInsets.all(16), child: LoadingIndicator()),
  );

  Widget _buildError({required VoidCallback reload}) => Center(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          const AppText('Что-то пошло не так'),
          AppTextButton.small(text: 'Попробовать снова', onTap: reload),
        ],
      ),
    ),
  );
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
      onTap: () => context.ext.push(const SearchPage()),
      child: DecoratedBox(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(blurRadius: 4, offset: const Offset(0, 1), color: Colors.black.withValues(alpha: 0.1))],
          borderRadius: BorderRadius.circular(14),
        ),
        child: AppTextFormField(
          compact: true,
          hintText: 'Например, Airtouch',
          prefixIcon: FIcons.search.icon(context, color: context.ext.colors.black[500]),
          fillColor: context.ext.colors.white[100],
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
        context.read<MapFeedCubit>().setFilter(SearchFilter(categories: {service}));
        context.read<MapMarkersPaginator>().setFilter(SearchFilter(categories: {service}));
        context.read<HomeNavigationCubit>().openMapSearch();
      },
      child: SizedBox(
        width: 60,
        child: Column(
          children: [
            Container(
              width: 60,
              height: 56,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: context.ext.colors.white[300], borderRadius: BorderRadius.circular(14)),
              child: icon,
            ),
            const SizedBox(height: 2),
            AppText(service.label, style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
