import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polka_clients/features/search/controller/search_cubit.dart';
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
  late var _filter = widget.initFilter ?? SearchFilter();
  late final _controller = TextEditingController();
  late final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    blocs.get<SearchCubit>(context);
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    blocs.destroy<SearchCubit>();
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
    setState(() => _filter = SearchFilter());
    _search();
  }

  void _search() {
    blocs.get<SearchCubit>(context).search(_controller.text.trim(), _filter);
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      appBar: CustomAppBar(title: 'Поиск'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(24, 8, 24, 8),
            child: Row(
              spacing: 8,
              children: [
                Expanded(
                  child: AppTextFormField(
                    fillColor: AppColors.backgroundSubtle,
                    hintText: 'Например, Airtouch',
                    compact: true,
                    prefixIcon: AppIcons.search.icon(color: AppColors.textPlaceholder),
                    controller: _controller,
                    focusNode: _focusNode,
                    onFieldSubmitted: (value) => _search(),
                  ),
                ),
                FilterButton(onTap: _openFilters, enabled: _filter.hasActiveFilters),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
            child: AppText('Нашли для тебя', style: AppTextStyles.headingSmall),
          ),
          Expanded(
            child: BlocBuilder<SearchCubit, SearchState>(
              bloc: blocs.get<SearchCubit>(context),
              builder: (context, state) => switch (state) {
                SearchInitial() => SizedBox.shrink(),
                SearchLoading() => Center(child: LoadingIndicator()),
                SearchError(:final error) => Center(child: AppText(error)),
                SearchLoaded(:final data) =>
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
            padding: EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: enabled ? AppColors.accentLight : AppColors.backgroundSubtle,
              borderRadius: BorderRadius.circular(14),
              border: enabled ? Border.all(color: AppColors.accent, width: 1) : null,
            ),
            child: AppIcons.filter.icon(),
          ),
          if (enabled)
            Positioned(
              top: -3,
              right: 7,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.backgroundDefault, width: 1),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
