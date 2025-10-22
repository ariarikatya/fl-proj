import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polka_clients/dependencies.dart';
import 'package:polka_clients/features/search/filters/search_filter.dart';
import 'package:shared/shared.dart';

part 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit() : super(SearchState.initial());

  final clientRepo = Dependencies().clientRepository;
  bool get isLoading => state is SearchLoading;

  void search(String query, SearchFilter? filter) async {
    if (isLoading) return;

    emit(SearchState.loading());
    final result = await clientRepo.searchMasters(query, filter);
    safeEmit(
      result.when(
        ok: (data) => SearchState.loaded(data: data),
        err: (e, st) => SearchState.error(parseError(e, st)),
      ),
    );
  }
}
