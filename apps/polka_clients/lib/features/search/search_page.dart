import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polka_clients/features/search/controller/feed_search_cubit.dart';
import 'package:polka_clients/features/search/filters/filters_page.dart';
import 'package:polka_clients/features/search/filters/search_filter.dart';
import 'package:polka_clients/widgets/masters_view.dart';
import 'package:shared/shared.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key, this.initFilter});

  final SearchFilter? initFilter;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late var _filter = widget.initFilter ?? const SearchFilter();
  late final _controller = TextEditingController();
  late final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _openFilters() async {
    final filter = await context.ext.push(FiltersPage(initFilter: _filter));
    if (filter != null) {
      setState(() => _filter = filter);
      _search();
    }
  }

  void _resetFilters() {
    setState(() => _filter = const SearchFilter());
    _search();
  }

  void _search() {
    context.read<FeedSearchCubit>().search(_controller.text.trim(), _filter);
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      appBar: const CustomAppBar(title: 'Поиск'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
            child: Row(
              spacing: 8,
              children: [
                Expanded(
                  child: AppTextFormField(
                    fillColor: context.ext.colors.white[200],
                    hintText: 'Например, Airtouch',
                    compact: true,
                    prefixIcon: FIcons.search.icon(context, color: context.ext.colors.black[500]),
                    controller: _controller,
                    focusNode: _focusNode,
                    onFieldSubmitted: (value) => _search(),
                  ),
                ),
                FilterButton(onTap: _openFilters, enabled: _filter.hasActiveFilters),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 12, 24, 12),
            child: AppText('Нашли для тебя', style: AppTextStyles.headingSmall),
          ),
          Expanded(
            child: BlocBuilder<FeedSearchCubit, FeedSearchState>(
              builder: (context, state) => switch (state) {
                FeedSearchInitial() => const SizedBox.shrink(),
                FeedSearchLoading() => const Center(child: LoadingIndicator()),
                FeedSearchError(:final error) => Center(child: AppText(error)),
                FeedSearchLoaded(:final data) =>
                  data.isEmpty
                      ? EmptySearchView(onResetFilters: _filter.hasActiveFilters ? _resetFilters : null)
                      : MastersView(masters: data),
              },
            ),
          ),
        ],
      ),
    );
  }
}

class FilterButton extends StatelessWidget {
  const FilterButton({super.key, required this.onTap, required this.enabled});

  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: enabled ? context.ext.colors.pink[100] : context.ext.colors.white[200],
              borderRadius: BorderRadius.circular(14),
              border: enabled ? Border.all(color: context.ext.colors.pink[500], width: 1) : null,
            ),
            child: FIcons.filter.icon(context),
          ),
          if (enabled)
            Positioned(
              top: -3,
              right: 7,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: context.ext.colors.pink[500],
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: context.ext.colors.white[100], width: 1),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
