import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared/shared.dart';

class SearchBuilder<C extends SearchCubit<T>, T extends Object> extends StatelessWidget {
  const SearchBuilder({
    super.key,
    required this.cubit,
    required this.emptyBuilder,
    required this.itemBuilder,
    this.scrollController,
    this.padding,
    this.separatorBuilder,
  });

  final C cubit;
  final EdgeInsets? padding;
  final IndexedWidgetBuilder? separatorBuilder;
  final Widget Function(BuildContext context) emptyBuilder;
  final Widget Function(BuildContext context, int index, T item) itemBuilder;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<C, SearchState<T>>(
      bloc: cubit,
      builder: (context, state) => switch (state) {
        SearchInitial() => SizedBox.shrink(),
        SearchLoading() => _buildLoading(),
        SearchLoaded(:final data) =>
          data.isEmpty
              ? emptyBuilder(context)
              : ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) => itemBuilder(context, index, data[index]),
                ),
        SearchError(:final error) => _buildError(error),
      },
    );
  }

  Widget _buildLoading() => Center(
    child: Padding(padding: EdgeInsets.all(16), child: LoadingIndicator()),
  );

  Widget _buildError(String error) => Center(
    child: Padding(
      padding: EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          AppText('Что-то пошло не так'),
          AppTextButton.small(text: 'Попробовать снова', onTap: () => cubit.search()),
          if (devMode) AppText('[DEV MODE] $error'),
        ],
      ),
    ),
  );
}
