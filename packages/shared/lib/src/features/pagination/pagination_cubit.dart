import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:shared/shared.dart';

abstract class PaginationCubit<T> extends Cubit<PagingState<int, T>> {
  PaginationCubit({this.limit = 10}) : super(PagingState<int, T>());

  final int limit;

  Future<Result<List<T>>> loadItems(int page, int limit);

  Future<void> reset() {
    emit(state.reset());
    return load();
  }

  Future<void> load() async {
    if (state.isLoading) return;

    emit(state.copyWith(isLoading: true, error: null));

    final newKey = (state.keys?.last ?? 0) + 1;
    final newItems = await loadItems(newKey, limit);

    final newState = newItems.when(
      ok: (data) => state.copyWith(
        pages: [...?state.pages, data],
        keys: [...?state.keys, newKey],
        hasNextPage: data.isNotEmpty && data.length == limit,
        isLoading: false,
      ),
      err: (e, st) => state.copyWith(error: parseError(e, st), isLoading: false),
    );

    safeEmit(newState);
  }

  int? get count => items?.length;

  List<T>? get items => state.pages != null ? List.unmodifiable(state.pages!.expand((e) => e)) : null;
}
