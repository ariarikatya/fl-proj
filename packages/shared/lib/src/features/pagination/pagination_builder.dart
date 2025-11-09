import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:shared/shared.dart';

class PaginationBuilder<C extends PaginationCubit<T>, T extends Object> extends StatelessWidget {
  const PaginationBuilder({
    super.key,
    required this.cubit,
    this.reverse = false,
    required this.emptyBuilder,
    required this.itemBuilder,
    this.scrollController,
    this.padding,
    this.separatorBuilder,
    this.invisibleItemsThreshold = 3,
  });

  final C cubit;
  final bool reverse;
  final int invisibleItemsThreshold;
  final EdgeInsets? padding;
  final IndexedWidgetBuilder? separatorBuilder;
  final Widget Function(BuildContext context) emptyBuilder;
  final Widget Function(BuildContext context, int index, T item) itemBuilder;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<C, PagingState<int, T>>(
      bloc: cubit,
      builder: (context, state) => RefreshWidget(
        refresh: cubit.reset,
        child: PagedListView<int, T>.separated(
          state: state,
          fetchNextPage: cubit.load,
          scrollController: scrollController,
          padding: padding,
          separatorBuilder: separatorBuilder ?? (_, __) => SizedBox.shrink(),
          reverse: reverse,
          builderDelegate: PagedChildBuilderDelegate(
            animateTransitions: true,
            invisibleItemsThreshold: invisibleItemsThreshold,
            itemBuilder: (context, item, index) => itemBuilder(context, index, item),
            noItemsFoundIndicatorBuilder: (_) => emptyBuilder(context),
            firstPageProgressIndicatorBuilder: (_) => _buildLoading(),
            newPageProgressIndicatorBuilder: (_) => _buildLoading(),
            firstPageErrorIndicatorBuilder: (_) => _buildError(),
            newPageErrorIndicatorBuilder: (_) => _buildError(),
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() => Center(
    child: Padding(padding: EdgeInsets.all(16), child: LoadingIndicator()),
  );

  Widget _buildError() => Center(
    child: Padding(
      padding: EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          AppText('Что-то пошло не так'),
          AppTextButton.small(text: 'Попробовать снова', onTap: () => cubit.load()),
        ],
      ),
    ),
  );
}
